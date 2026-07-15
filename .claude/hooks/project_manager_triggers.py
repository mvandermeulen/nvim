#!/usr/bin/env python3
"""
Project Manager Auto-Trigger System

Automatically detects when to trigger the project-manager agent based on:
1. Task completion events
2. Architectural decisions
3. Blocker encountered/resolved
4. Milestone reached
5. Knowledge refinements
6. File changes in planning docs

This ensures project-manager is NEVER missed by mistake.
"""

import re
from typing import Dict, Any, List, Optional
from pathlib import Path
import subprocess


# Trigger condition patterns
TRIGGER_PATTERNS = {
    'task_completion': [
        r'(?i)completed?.*task',
        r'(?i)finished?.*implementing',
        r'(?i)done with',
        r'(?i)✅.*complete',
    ],
    'architectural_decision': [
        r'(?i)DECISION:',
        r'(?i)ADR:',
        r'(?i)architectural.*decision',
        r'(?i)decided to use',
        r'(?i)choosing.*approach',
    ],
    'blocker_encountered': [
        r'(?i)BLOCKER:',
        r'(?i)BLOCKED:',
        r'(?i)cannot proceed',
        r'(?i)stuck on',
        r'(?i)blocked by',
    ],
    'blocker_resolved': [
        r'(?i)blocker.*resolved',
        r'(?i)unblocked',
        r'(?i)can now proceed',
    ],
    'milestone_reached': [
        r'(?i)milestone.*reached',
        r'(?i)phase.*complete',
        r'(?i)sprint.*complete',
    ],
    'knowledge_refinement': [
        r'(?i)verified that',
        r'(?i)confirmed that',
        r'(?i)discovered that',
        r'(?i)learned that',
    ],
}


class ProjectManagerTrigger:
    """Automatic project-manager trigger detection and execution"""

    def __init__(self):
        """Initialize trigger detector"""
        self.last_trigger_type: Optional[str] = None
        self.triggers_this_session = 0

    def should_trigger(self, event_type: str, event_data: Dict[str, Any]) -> Optional[str]:
        """
        Determine if project-manager should be triggered

        Returns trigger reason if should trigger, None otherwise
        """
        # Check for explicit trigger requests
        if event_data.get('trigger_project_manager'):
            return event_data.get('trigger_reason', 'explicit_request')

        # Check for pattern matches
        text_to_check = self._get_text_from_event(event_data)
        if not text_to_check:
            return None

        for trigger_type, patterns in TRIGGER_PATTERNS.items():
            if self._matches_any_pattern(text_to_check, patterns):
                return trigger_type

        # Check for file changes in planning docs
        if event_type == 'post-tool-use':
            tool = event_data.get('tool', '')
            if tool in ['Write', 'Edit']:
                file_path = event_data.get('file_path', '')
                if self._is_planning_file(file_path):
                    return 'planning_file_changed'

        return None

    def trigger_project_manager(self, trigger_type: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Trigger project-manager agent

        Returns result from project-manager execution
        """
        self.last_trigger_type = trigger_type
        self.triggers_this_session += 1

        # Prepare trigger message
        trigger_message = self._format_trigger_message(trigger_type, context)

        # Execute project-manager via Task tool
        # Note: This would need to be called from coordinator which has access to Claude Code
        return {
            'triggered': True,
            'trigger_type': trigger_type,
            'trigger_count': self.triggers_this_session,
            'message': trigger_message,
            'action': 'call_task_tool',
            'task_params': {
                'subagent_type': 'project-manager',
                'description': f'Auto-trigger: {trigger_type}',
                'prompt': trigger_message
            }
        }

    def _get_text_from_event(self, event_data: Dict[str, Any]) -> str:
        """Extract text content from event data"""
        # Try various text fields
        for field in ['prompt', 'message', 'content', 'description', 'text']:
            if field in event_data:
                return str(event_data[field])

        # Check tool parameters
        if 'tool_params' in event_data:
            params = event_data['tool_params']
            for field in ['content', 'new_string', 'message']:
                if field in params:
                    return str(params[field])

        return ''

    def _matches_any_pattern(self, text: str, patterns: List[str]) -> bool:
        """Check if text matches any pattern"""
        for pattern in patterns:
            if re.search(pattern, text, re.IGNORECASE):
                return True
        return False

    def _is_planning_file(self, file_path: str) -> bool:
        """Check if file is a planning document"""
        planning_paths = [
            '.claude/docs/planning/',
            '.claude/docs/specs/',
            '.claude/journal/',
        ]
        return any(path in file_path for path in planning_paths)

    def _format_trigger_message(self, trigger_type: str, context: Dict[str, Any]) -> str:
        """Format message for project-manager"""
        messages = {
            'task_completion': 'Task completion detected. Please update SESSION_STATE.md, archive completed work, and refresh backlogs.',
            'architectural_decision': 'Architectural decision detected. Please update DECISIONS.md and ARCHITECTURE.md.',
            'blocker_encountered': 'Blocker encountered. Please log in SESSION_STATE.md and suggest alternative tasks.',
            'blocker_resolved': 'Blocker resolved. Please update estimates and clear blocker status.',
            'milestone_reached': 'Milestone reached. Please archive phase and update PROJECT_OVERVIEW.md.',
            'knowledge_refinement': 'Knowledge refinement detected. Please update documentation with verified facts.',
            'planning_file_changed': 'Planning file changed. Please sync documentation and update indices.',
            'explicit_request': 'Explicit trigger request.',
        }

        base_message = messages.get(trigger_type, f'Auto-trigger: {trigger_type}')

        # Add context
        context_info = []
        if 'file_path' in context:
            context_info.append(f"File: {context['file_path']}")
        if 'prompt' in context:
            prompt = context['prompt'][:200]
            context_info.append(f"Context: {prompt}")

        if context_info:
            base_message += '\n\n' + '\n'.join(context_info)

        return base_message


# Global instance
_trigger_detector: Optional[ProjectManagerTrigger] = None


def get_trigger_detector() -> ProjectManagerTrigger:
    """Get global trigger detector instance"""
    global _trigger_detector
    if _trigger_detector is None:
        _trigger_detector = ProjectManagerTrigger()
    return _trigger_detector


# Convenience function for coordinator integration
def check_and_trigger(event_type: str, event_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """
    Check if project-manager should be triggered and return trigger info

    To be called from coordinator after each event
    """
    detector = get_trigger_detector()
    trigger_reason = detector.should_trigger(event_type, event_data)

    if trigger_reason:
        return detector.trigger_project_manager(trigger_reason, event_data)

    return None


# Example usage
if __name__ == '__main__':
    detector = get_trigger_detector()

    # Test patterns
    test_cases = [
        ('Completed implementing Phase 1', 'task_completion'),
        ('DECISION: Using Python-first architecture', 'architectural_decision'),
        ('BLOCKER: Redis connection failed', 'blocker_encountered'),
        ('Verified that SQLite handles 100K records', 'knowledge_refinement'),
    ]

    print("\n🔍 Testing Project Manager Trigger Detection\n")

    for text, expected_type in test_cases:
        result = detector.should_trigger('user-prompt-submit', {'prompt': text})
        status = '✅' if result == expected_type else '❌'
        print(f"{status} '{text[:50]}...' → {result}")

    print("\n✅ Test complete")
