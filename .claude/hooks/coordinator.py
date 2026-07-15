#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "redis>=4.0",
#   "pyyaml>=6.0",
# ]
# ///
"""
Hook Coordinator - Central dispatcher for all Claude Code hook events

This coordinator:
1. Receives hook events from Claude Code
2. Routes to appropriate handlers based on event type
3. Executes handlers in correct order
4. Aggregates and returns results
5. Handles errors gracefully

Architecture:
- Receives events via CLI (command line arguments)
- Loads handler modules dynamically
- Executes handlers in sequence or parallel
- Returns structured results to Claude Code

Pattern Source: Comprehensive Claude Code Management System Design
"""

import sys
import json
from typing import Any, Callable
from datetime import datetime
import traceback
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access
HOOKS_DIR = D.hooks  # Directory for hook modules
REPO_DIR = D.repo  # Root directory of the repository
CLAUDE_DIR = D.claude  # Root directory for Claude session files
RHINO_SHARE_DIR = D.rhino['share']  # Shared directory for Rhino agent
RHINO_LOGS_DIR = D.rhino['logs']  # Directory for Rhino logs
RHINO_STATE_DIR = D.rhino['state']  # Directory for persistent state files
CLAUDE_DOCS_DIR = D.docs  # Directory for documentation files
CLAUDE_SESSION_DIR = D.session  # Directory for session files
CLAUDE_PLANNING_DIR = D.planning  # Directory for planning files
D.db_path = D.db_path  # Path to SQLite database for event logging and session tracking
CURRENT_STATE_FILE = D.state_files['current']  # Path to current state JSON file
LEGACY_STATE_FILE = D.state_files['legacy']  # Path to legacy state JSON file
DECISIONS_FILE = D.decisions_file  # Path to DECISIONS.md
ADR_DIR = D.adrs  # Directory for Architectural Decision Records (ADRs)
PLANS_DIR = D.plans  # Directory for plan documents
CURRENT_SESSION_FILE = D.current_session_file  # Path to current session YAML file
HANDOVER_DIR = D.handover  # Directory for handover files



# Import existing hook modules (when they exist)
try:
    import state_manager  # type: ignore
    HAS_STATE_MANAGER = True
except ImportError:
    state_manager = None  # type: ignore
    HAS_STATE_MANAGER = False
    print("⚠️  state_manager not available", file=sys.stderr)

try:
    import context_monitor  # type: ignore
    HAS_CONTEXT_MONITOR = True
except ImportError:
    context_monitor = None  # type: ignore
    HAS_CONTEXT_MONITOR = False

try:
    import project_manager_triggers  # type: ignore
    HAS_PM_TRIGGERS = True
except ImportError:
    project_manager_triggers = None  # type: ignore
    HAS_PM_TRIGGERS = False

try:
    from redis_coordinator import get_coordinator  # type: ignore
    HAS_REDIS = True
except ImportError:
    get_coordinator = None  # type: ignore
    HAS_REDIS = False

try:
    from handlers.suggestion_engine import handle_pre_tool_use, handle_post_tool_use  # type: ignore
    HAS_SUGGESTION_ENGINE = True
except ImportError:
    handle_pre_tool_use = None  # type: ignore
    handle_post_tool_use = None  # type: ignore
    HAS_SUGGESTION_ENGINE = False

try:
    from repositories.event import EventRepository  # type: ignore
    from repositories.session import SessionRepository  # type: ignore
    HAS_REPOSITORIES = True
except ImportError:
    EventRepository = None  # type: ignore
    SessionRepository = None  # type: ignore
    HAS_REPOSITORIES = False

try:
    from intelligence.smart_resume import load_session_context  # type: ignore
    HAS_SMART_RESUME = True
except ImportError:
    load_session_context = None  # type: ignore
    HAS_SMART_RESUME = False


# Hook Handler Registry
# Maps hook events to handler functions
# Each handler returns a dict with status, data, and optional reminders
HOOK_HANDLERS: dict[str, list[Callable]] = {}


def register_handlers():
    """Register handlers for each hook type"""

    # SessionStart handlers
    if HAS_STATE_MANAGER:
        HOOK_HANDLERS['session-start'] = [
            session_manager_initialize,
            # planning_manager_load will be added in Phase 3
            # journal_manager_load will be added in Phase 4
        ]

    # UserPromptSubmit handlers
    HOOK_HANDLERS['user-prompt-submit'] = [
        context_manager_update,
        # skill_detector_check will integrate existing user-prompt-submit.py
        # planning_manager_check_updates will be added in Phase 3
        # journal_manager_capture will be added in Phase 4
    ]

    # PreToolUse handlers
    pre_tool_handlers = [context_manager_check_threshold]
    if HAS_SUGGESTION_ENGINE and handle_pre_tool_use:
        pre_tool_handlers.append(handle_pre_tool_use)
    HOOK_HANDLERS['pre-tool-use'] = pre_tool_handlers

    # PostToolUse handlers
    post_tool_handlers = [session_manager_update_state]
    if HAS_SUGGESTION_ENGINE and handle_post_tool_use:
        post_tool_handlers.append(handle_post_tool_use)
    HOOK_HANDLERS['post-tool-use'] = post_tool_handlers

    # SessionEnd handlers
    HOOK_HANDLERS['session-end'] = [
        session_manager_finalize,
        # planning_manager_update_backlog will be added in Phase 3
        # journal_manager_summarize will be added in Phase 4
    ]

    # Notification handlers
    HOOK_HANDLERS['notification'] = [
        notification_handler,
    ]

    # Stop handlers (agent stopped working)
    HOOK_HANDLERS['stop'] = [
        stop_handler,
    ]

    # SubagentStop handlers
    HOOK_HANDLERS['subagent-stop'] = [
        subagent_stop_handler,
    ]


# Message Counting

def increment_message_count() -> int:
    """Increment and return message count"""
    D.message_count_file.parent.mkdir(parents=True, exist_ok=True)

    # Read current count
    try:
        if D.message_count_file.exists():
            with D.message_count_file.open('r') as f:
                current_count = int(f.read().strip())
        else:
            current_count = 0
    except (ValueError, IOError):
        current_count = 0

    # Increment
    new_count = current_count + 1

    # Save
    with D.message_count_file.open('w') as f:
        f.write(str(new_count))

    return new_count


# Handler Functions (delegating to existing modules)

def session_manager_initialize(_event: dict[str, Any]) -> dict[str, Any]:
    """Initialize session state with smart resume"""
    if not HAS_STATE_MANAGER or state_manager is None:
        return {'status': 'skipped', 'reason': 'state_manager not available'}

    try:
        state = state_manager.load_state()
        result_data = {
            'session_initialized': True,
            'current_skill': state.get('currentSkill'),
            'current_research': state.get('currentResearch')
        }

        # Create/update session in database for tracking
        if HAS_REPOSITORIES and SessionRepository:
            try:
                session_repo = SessionRepository(D.db_path)
                if D.current_session_file.exists():
                    import yaml
                    with open(D.current_session_file) as f:
                        session_yaml = yaml.safe_load(f)

                    session_data = session_yaml.get('session', {})
                    task_data = session_yaml.get('task', {})
                    session_id = session_data.get('id')

                    if session_id:
                        # Upsert session record
                        existing = session_repo.get(session_id)
                        if not existing:
                            session_repo.create({
                                'id': session_id,
                                'health_status': session_data.get('health', '🟢'),
                                'message_count': session_data.get('message_count', 0),
                                'mode': session_yaml.get('mode', 'BUILD'),
                                'scope': session_yaml.get('scope', 'MEDIUM'),
                                'task_title': task_data.get('title', ''),
                                'task_reference': task_data.get('reference', ''),
                                'task_phase': task_data.get('phase', 'planning'),
                                'task_progress': task_data.get('progress', 0),
                                'branch': session_yaml.get('context', {}).get('branch', 'main'),
                                'started_at': session_data.get('started_at', datetime.now().isoformat()),
                            })
                            result_data['session_created'] = True
            except Exception as db_error:
                result_data['session_db_error'] = str(db_error)

        # Smart resume: Load context from previous session
        session_id = state.get('session', {}).get('id')
        if HAS_SMART_RESUME and session_id and load_session_context:
            try:
                context = load_session_context(session_id, max_tokens=400000)
                result_data['smart_resume'] = {
                    'loaded': True,
                    'token_count': context['token_count'],
                    'load_time_ms': context['load_time_ms'],
                    'summary': context['summary']
                }

                # Write context to file for CLAUDE.md inclusion
                D.resume_context_file.parent.mkdir(parents=True, exist_ok=True)
                with open(D.resume_context_file, 'w') as f:
                    f.write('# Auto-Generated Session Context\n\n')
                    f.write(context['summary'])
                    f.write(f"\n\n---\n_Token usage: {context['token_count']}/4000 | Load time: {context['load_time_ms']}ms_\n")

                return {
                    'status': 'success',
                    'data': result_data,
                    'reminders': [
                        f"📋 Session Context Resume:\n{context['summary']}\n\n"
                        f"Token usage: {context['token_count']}/4000 | Load time: {context['load_time_ms']}ms"
                    ]
                }
            except Exception as resume_error:
                # Smart resume failed, but session still initializes
                result_data['smart_resume'] = {
                    'loaded': False,
                    'error': str(resume_error)
                }

        return {
            'status': 'success',
            'data': result_data
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e),
            'traceback': traceback.format_exc()
        }


def context_manager_update(_event: dict[str, Any]) -> dict[str, Any]:
    """Update context usage tracking"""
    try:
        # Increment message count
        message_count = increment_message_count()

        # Update session YAML
        health = '🟢'  # Default

        if D.current_session_file.exists():
            import yaml
            with open(D.current_session_file) as f:
                session_data = yaml.safe_load(f) or {}

            # Ensure structure exists
            if 'session' not in session_data:
                session_data['session'] = {}

            # Update message count
            session_data['session']['message_count'] = message_count

            # Calculate health status
            if message_count >= 46:
                health = '🔴'
            elif message_count >= 31:
                health = '🟡'
            else:
                health = '🟢'

            session_data['session']['health'] = health

            with open(D.current_session_file, 'w') as f:
                yaml.dump(session_data, f, default_flow_style=False)

        return {
            'status': 'success',
            'data': {
                'message_count': message_count,
                'health_status': health,
                'context_updated': True
            }
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def context_manager_check_threshold(_event: dict[str, Any]) -> dict[str, Any]:
    """Check if context threshold exceeded"""
    try:
        if not D.message_count_file.exists():
            return {'status': 'skipped', 'reason': 'No message count file'}

        message_count = int(D.message_count_file.read_text().strip())

        # Check thresholds
        if message_count >= 46:
            return {
                'status': 'warning',
                'data': {
                    'threshold_exceeded': True,
                    'level': 'critical',
                    'message_count': message_count,
                    'recommendation': 'HANDOVER NOW - Context exhaustion imminent'
                },
                'reminder': f"🔴 Session health CRITICAL ({message_count} messages). Use /handover to continue work in fresh session."
            }
        elif message_count >= 31:
            return {
                'status': 'warning',
                'data': {
                    'threshold_exceeded': True,
                    'level': 'approaching',
                    'message_count': message_count,
                    'recommendation': 'Plan for handover after completing current task'
                },
                'reminder': f"🟡 Session health APPROACHING limit ({message_count} messages). Plan handover soon."
            }
        else:
            return {
                'status': 'success',
                'data': {
                    'threshold_ok': True,
                    'message_count': message_count
                }
            }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def session_manager_update_state(_event: dict[str, Any]) -> dict[str, Any]:
    """Update session state after tool use"""
    if not HAS_STATE_MANAGER:
        return {'status': 'skipped'}

    try:
        # Future: update state based on tool use
        return {'status': 'success', 'data': {'state_updated': True}}
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def session_manager_finalize(_event: dict[str, Any]) -> dict[str, Any]:
    """Finalize session on end"""
    if not HAS_STATE_MANAGER:
        return {'status': 'skipped'}

    try:
        # Update session end time in database
        if HAS_REPOSITORIES and SessionRepository:
            try:
                if D.current_session_file.exists():
                    import yaml
                    with open(D.current_session_file) as f:
                        session_yaml = yaml.safe_load(f)
                    session_id = session_yaml.get('session', {}).get('id')
                    if session_id:
                        session_repo = SessionRepository(D.db_path)
                        session_repo.update(session_id, {
                            'ended_at': datetime.now().isoformat(),
                            'message_count': session_yaml.get('session', {}).get('message_count', 0)
                        })
            except Exception:
                pass  # Graceful degradation
        return {'status': 'success', 'data': {'session_finalized': True}}
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def notification_handler(event: dict[str, Any]) -> dict[str, Any]:
    """Handle notification events - log to database for tracking"""
    try:
        # Log notification event
        return {
            'status': 'success',
            'data': {
                'notification_logged': True,
                'event_type': event.get('type', 'unknown')
            }
        }
    except Exception as e:
        return {'status': 'error', 'error': str(e)}


def stop_handler(event: dict[str, Any]) -> dict[str, Any]:
    """Handle stop events - agent stopped working"""
    try:
        # Update session state to reflect stop
        if HAS_STATE_MANAGER:
            # Could update session metrics here
            pass
        return {
            'status': 'success',
            'data': {
                'stop_logged': True,
                'reason': event.get('reason', 'user_initiated')
            }
        }
    except Exception as e:
        return {'status': 'error', 'error': str(e)}


def subagent_stop_handler(event: dict[str, Any]) -> dict[str, Any]:
    """Handle subagent stop events - track subagent lifecycle"""
    try:
        # Log subagent completion for analytics
        return {
            'status': 'success',
            'data': {
                'subagent_stop_logged': True,
                'agent_id': event.get('agent_id', 'unknown'),
                'agent_type': event.get('agent_type', 'unknown')
            }
        }
    except Exception as e:
        return {'status': 'error', 'error': str(e)}


def broadcast_event(hook_name: str, event_data: dict[str, Any], results: list[dict[str, Any]]) -> None:
    """
    Broadcast high-impact events to Redis for agent coordination

    Only broadcasts events that need cross-agent awareness:
    - Session lifecycle (start/end)
    - Health warnings (🟡/🔴)
    - Decision recording (high-impact only)
    """
    if not HAS_REDIS or not get_coordinator:
        return

    try:
        coordinator = get_coordinator()
        if not coordinator.is_available():
            return

        # Session lifecycle events
        if hook_name == 'session-start':
            coordinator.broadcast_session_event('session_started', {
                'session_id': event_data.get('session_id', 'unknown'),
                'timestamp': datetime.now().isoformat()
            })
        elif hook_name == 'session-end':
            coordinator.broadcast_session_event('session_ended', {
                'session_id': event_data.get('session_id', 'unknown'),
                'timestamp': datetime.now().isoformat()
            })

        # Health warnings (when message count reaches thresholds)
        if hook_name == 'user-prompt-submit':
            if D.message_count_file.exists():
                try:
                    count = int(D.message_count_file.read_text().strip())
                    if count == 31:  # 🟡 threshold
                        coordinator.broadcast_health_warning('🟡', {
                            'message_count': count,
                            'threshold': 'approaching',
                            'recommendation': 'Plan for handover'
                        })
                    elif count == 46:  # 🔴 threshold
                        coordinator.broadcast_health_warning('🔴', {
                            'message_count': count,
                            'threshold': 'critical',
                            'recommendation': 'Handover now'
                        })

                        # Auto-generate handover at critical threshold
                        try:
                            from handlers.handover_generator import generate_handover
                            handover_result = generate_handover()
                            if handover_result['status'] == 'success':
                                print(f"\n🔴 AUTO-HANDOVER GENERATED: {handover_result['data']['handover_file']}")
                                print("Load this file in your next session to continue work.\n")
                        except Exception as gen_error:
                            print(f"⚠️  Failed to generate handover: {gen_error}", file=sys.stderr)

                except (ValueError, IOError):
                    pass

        # Note: Decision broadcasting will be added in Phase 2.6 (decision_manager.py)
        # Context warnings will be added when context_monitor is implemented

    except Exception as e:
        # Graceful degradation: don't let Redis failures break hooks
        print(f"⚠️  Redis broadcast failed: {e}", file=sys.stderr)


def _log_event_to_database(
    hook_name: str,
    event_data: dict[str, Any],
    result: dict[str, Any],
    execution_time_ms: int
) -> None:
    """
    Log hook event to database (audit trail)

    Args:
        hook_name: Hook name
        event_data: Original event data
        result: Handler execution result
        execution_time_ms: Execution time in milliseconds
    """
    if not HAS_REPOSITORIES or not EventRepository:
        return

    try:
        event_repo = EventRepository(D.db_path)
        event_repo.create({
            'hook_name': hook_name,
            'session_id': event_data.get('session_id'),
            'event_data': json.dumps(event_data),
            'handler_results': json.dumps(result.get('results', [])),
            'status': result.get('status', 'success'),
            'error_message': json.dumps(result.get('errors', [])) if result.get('errors') else None,
            'handlers_executed': result.get('handlers_executed', 0),
            'execution_time_ms': execution_time_ms,
        })
    except Exception as e:
        # Graceful degradation: don't let logging failures break hooks
        print(f"⚠️  Failed to log event to database: {e}", file=sys.stderr)


def execute_handlers(hook_name: str, event_data: dict[str, Any]) -> dict[str, Any]:
    """
    Execute all handlers for a given hook event

    Args:
        hook_name: Name of the hook event (e.g., 'session-start')
        event_data: Event data from Claude Code

    Returns:
        Aggregated results from all handlers
    """
    import time
    start_time = time.time()

    handlers = HOOK_HANDLERS.get(hook_name, [])

    if not handlers:
        return {
            'status': 'no_handlers',
            'hook': hook_name,
            'timestamp': datetime.now().isoformat()
        }

    results = []
    errors = []
    reminders = []

    # Handle message counting for user-prompt-submit
    if hook_name == 'user-prompt-submit':
        try:
            count = increment_message_count()
            reminders.append(f"💬 Message #{count} in this session")
        except Exception as e:
            print(f"⚠️  Failed to update message count: {e}", file=sys.stderr)

    for handler in handlers:
        try:
            result = handler(event_data)
            results.append({
                'handler': handler.__name__,
                'result': result
            })

            # Collect errors and reminders
            if result.get('status') == 'error':
                errors.append({
                    'handler': handler.__name__,
                    'error': result.get('error')
                })

            if 'reminder' in result:
                reminders.append(result['reminder'])

        except Exception as e:
            errors.append({
                'handler': handler.__name__,
                'error': str(e),
                'traceback': traceback.format_exc()
            })

    # Check for project-manager triggers
    if HAS_PM_TRIGGERS and project_manager_triggers:
        trigger_info = project_manager_triggers.check_and_trigger(hook_name, event_data)
        if trigger_info:
            reminders.append(
                f"🤖 AUTO-TRIGGER: {trigger_info['trigger_type']}\n"
                f"   Please invoke: Task tool with subagent_type='project-manager'\n"
                f"   Reason: {trigger_info['message']}"
            )

    # Broadcast high-impact events to Redis (for agent coordination)
    broadcast_event(hook_name, event_data, results)

    # Build result dict
    result = {
        'status': 'error' if errors else 'success',
        'hook': hook_name,
        'timestamp': datetime.now().isoformat(),
        'handlers_executed': len(results),
        'results': results,
        'errors': errors if errors else None,
        'reminders': reminders if reminders else None
    }

    # Log to database (audit trail)
    execution_time_ms = int((time.time() - start_time) * 1000)
    _log_event_to_database(hook_name, event_data, result, execution_time_ms)

    return result


def load_event_data() -> dict[str, Any]:
    """Load event data from stdin (JSON)"""
    try:
        if not sys.stdin.isatty():
            data = sys.stdin.read()
            if data.strip():
                return json.loads(data)
        return {}
    except json.JSONDecodeError as e:
        print(f"⚠️  Invalid JSON from stdin: {e}", file=sys.stderr)
        return {}


def format_output(result: dict[str, Any], verbose: bool = False) -> str:
    """Format output for Claude Code"""
    if verbose:
        return json.dumps(result, indent=2)

    # Concise output by default
    hook = result.get('hook', 'unknown')

    # Show errors prominently
    if result.get('errors'):
        error_lines = [
            f"❌ {hook} errors:",
            *[f"  - {e['handler']}: {e['error']}" for e in result['errors']]
        ]
        return '\n'.join(error_lines)

    # Show reminders if any
    if result.get('reminders'):
        reminder_lines = [
            *[f"💡 {r}" for r in result['reminders']]
        ]
        return '\n'.join(reminder_lines)

    # Default: silent success
    return ''


def main():
    """Main entry point for hook coordinator"""
    if len(sys.argv) < 2:
        print("Usage: coordinator.py <hook-name> [--verbose]", file=sys.stderr)
        print("Hook names: session-start, user-prompt-submit, pre-tool-use, post-tool-use, session-end", file=sys.stderr)
        sys.exit(1)

    hook_name = sys.argv[1]
    verbose = '--verbose' in sys.argv

    # Register handlers
    register_handlers()

    # Load event data from stdin
    event_data = load_event_data()

    # Execute handlers
    result = execute_handlers(hook_name, event_data)

    # Output result
    output = format_output(result, verbose=verbose)
    if output:
        print(output)

    # Exit with error code if errors occurred
    sys.exit(1 if result.get('status') == 'error' else 0)


if __name__ == '__main__':
    main()
