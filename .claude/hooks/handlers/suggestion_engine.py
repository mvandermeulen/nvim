#!/usr/bin/env python3
"""
Suggestion Engine Handler - Code Quality Validation

Provides:
1. Pre-tool validation (non-blocking advisory)
2. Post-tool validation with warnings + auto-fix
3. External tool integration (ruff, eslint, basedpyright, tsc)
4. LSP preview framework (future MCP integration)
5. Quality metrics logging

Strategy:
- External tools PRIMARY (work today)
- LSP supplementary (future enhancement via MCP)
- Advisory warnings ONLY (no blocking)
- Auto-fix when safe and configured

Pattern Source: Phase 2.8 - Code Quality Validation
"""

import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, Any, List, Optional
from datetime import datetime

# Add hooks directory to path
HOOKS_DIR = Path(__file__).parent.parent
sys.path.insert(0, str(HOOKS_DIR))

try:
    from lsp_client import LSPClient  # type: ignore
    HAS_LSP = True
except ImportError:
    LSPClient = None  # type: ignore
    HAS_LSP = False

try:
    from repositories.event_repository import EventRepository  # type: ignore
    HAS_REPO = True
except ImportError:
    EventRepository = None  # type: ignore
    HAS_REPO = False

try:
    from config import (  # type: ignore
        QUALITY_GATE_CONFIG,
        is_auto_fix_enabled,
        get_quality_config
    )
    HAS_CONFIG = True
except ImportError:
    # Fallback configuration if config.py not available
    QUALITY_GATE_CONFIG = {
        'python': {'linter': 'ruff', 'type_checker': 'basedpyright', 'auto_fix': True},
        'typescript': {'linter': 'eslint', 'type_checker': 'tsc', 'auto_fix': True},
        'javascript': {'linter': 'eslint', 'type_checker': None, 'auto_fix': True}
    }
    HAS_CONFIG = False

    def is_auto_fix_enabled(language: str) -> bool:  # type: ignore
        return QUALITY_GATE_CONFIG.get(language, {}).get('auto_fix', False)

    def get_quality_config(language: str) -> Dict[str, Any]:  # type: ignore
        return QUALITY_GATE_CONFIG.get(language, {})


class SuggestionEngine:
    """Code quality validation engine"""

    def __init__(self):
        """Initialize suggestion engine"""
        self.lsp_client = LSPClient() if HAS_LSP else None
        self.event_repo = EventRepository() if HAS_REPO else None

    def handle_pre_tool(self, tool: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Pre-tool validation (non-blocking advisory)

        Args:
            tool: Tool name (e.g., 'Edit', 'Write')
            params: Tool parameters

        Returns:
            Validation result with warnings (never blocks)
        """
        # Only validate file edit/write operations
        if tool not in ('Edit', 'Write', 'MultiEdit'):
            return {'status': 'skipped', 'reason': 'Not a file edit operation'}

        file_path = params.get('file_path')
        if not file_path:
            return {'status': 'skipped', 'reason': 'No file path provided'}

        try:
            # Check file type and run appropriate validators
            language = self._detect_language(file_path)
            if not language:
                return {'status': 'skipped', 'reason': f'Unsupported file type: {file_path}'}

            # Run LSP preview if available (future: MCP integration)
            lsp_warnings = self._run_lsp_preview(file_path, params) if self.lsp_client else []

            # Run external tools (primary validation)
            external_warnings = self._run_external_tools(file_path, language, auto_fix=False)

            # Combine warnings
            all_warnings = lsp_warnings + external_warnings

            if all_warnings:
                return {
                    'status': 'warnings',
                    'file': file_path,
                    'language': language,
                    'warnings': all_warnings,
                    'reminder': self._format_warning_reminder(all_warnings, file_path)
                }

            return {'status': 'success', 'file': file_path, 'warnings': []}

        except Exception as e:
            return {
                'status': 'error',
                'error': str(e),
                'message': 'Pre-tool validation failed (non-critical)'
            }

    def handle_post_tool(self, tool: str, params: Dict[str, Any], result: Any) -> Dict[str, Any]:
        """
        Post-tool validation with advisory warnings + auto-fix

        Args:
            tool: Tool name
            params: Tool parameters
            result: Tool execution result

        Returns:
            Validation result with warnings and auto-fix info
        """
        # Only validate file edit/write operations
        if tool not in ('Edit', 'Write', 'MultiEdit'):
            return {'status': 'skipped'}

        file_path = params.get('file_path')
        if not file_path:
            return {'status': 'skipped'}

        try:
            language = self._detect_language(file_path)
            if not language:
                return {'status': 'skipped'}

            # Run external tools with auto-fix
            auto_fix = is_auto_fix_enabled(language)
            warnings = self._run_external_tools(file_path, language, auto_fix=auto_fix)

            # Log quality metrics
            self._log_quality_metrics(file_path, language, warnings)

            if warnings:
                return {
                    'status': 'warnings',
                    'file': file_path,
                    'language': language,
                    'warnings': warnings,
                    'auto_fix_applied': any(w.get('fixed') for w in warnings),
                    'reminder': self._format_post_tool_reminder(warnings, file_path)
                }

            return {'status': 'success', 'file': file_path, 'quality': 'good'}

        except Exception as e:
            return {
                'status': 'error',
                'error': str(e),
                'message': 'Post-tool validation failed (non-critical)'
            }

    def _detect_language(self, file_path: str) -> Optional[str]:
        """Detect programming language from file extension"""
        path = Path(file_path)
        ext_map = {
            '.py': 'python',
            '.ts': 'typescript',
            '.tsx': 'typescript',
            '.js': 'javascript',
            '.jsx': 'javascript',
        }
        return ext_map.get(path.suffix)

    def _run_lsp_preview(self, file_path: str, params: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Run LSP preview (future: MCP integration)

        Currently returns empty list until MCP is integrated.
        Framework ready for future enhancement.
        """
        if not self.lsp_client:
            return []

        try:
            # Future: Use Claude Code's MCP for real-time diagnostics
            # diagnostics = self.lsp_client.get_diagnostics(file_path)
            # For now, LSP not fully integrated
            return []
        except Exception as e:
            print(f"⚠️  LSP preview failed: {e}", file=sys.stderr)
            return []

    def _run_external_tools(
        self,
        file_path: str,
        language: str,
        auto_fix: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Run external validation tools

        Args:
            file_path: File to validate
            language: Programming language
            auto_fix: Whether to apply auto-fixes

        Returns:
            List of warnings (with 'fixed' flag if auto-fix applied)
        """
        config = get_quality_config(language)
        if not config:
            return []

        warnings = []

        # Run linter
        if config.get('linter'):
            linter_warnings = self._run_linter(
                file_path,
                language,
                config['linter'],
                auto_fix=auto_fix and config.get('auto_fix', False)
            )
            warnings.extend(linter_warnings)

        # Run type checker
        if config.get('type_checker'):
            type_warnings = self._run_type_checker(file_path, language, config['type_checker'])
            warnings.extend(type_warnings)

        return warnings

    def _run_linter(
        self,
        file_path: str,
        language: str,
        linter: str,
        auto_fix: bool = False
    ) -> List[Dict[str, Any]]:
        """Run linter and optionally apply fixes"""
        warnings = []

        try:
            if linter == 'ruff':
                warnings = self._run_ruff(file_path, auto_fix=auto_fix)
            elif linter == 'eslint':
                warnings = self._run_eslint(file_path, auto_fix=auto_fix)

        except Exception as e:
            print(f"⚠️  Linter {linter} failed: {e}", file=sys.stderr)

        return warnings

    def _run_type_checker(self, file_path: str, language: str, checker: str) -> List[Dict[str, Any]]:
        """Run type checker"""
        warnings = []

        try:
            if checker == 'basedpyright':
                warnings = self._run_basedpyright(file_path)
            elif checker == 'tsc':
                warnings = self._run_tsc(file_path)

        except Exception as e:
            print(f"⚠️  Type checker {checker} failed: {e}", file=sys.stderr)

        return warnings

    def _run_ruff(self, file_path: str, auto_fix: bool = False) -> List[Dict[str, Any]]:
        """Run ruff linter (Python)"""
        try:
            # Run ruff check (with --fix if auto_fix enabled)
            cmd = ['ruff', 'check', file_path]
            if auto_fix:
                cmd.append('--fix')
            cmd.append('--output-format=json')

            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)

            # Parse JSON output
            if result.stdout:
                issues = json.loads(result.stdout)
                return [
                    {
                        'tool': 'ruff',
                        'line': issue.get('location', {}).get('row'),
                        'column': issue.get('location', {}).get('column'),
                        'message': issue.get('message'),
                        'code': issue.get('code'),
                        'severity': 'warning',
                        'fixed': auto_fix and issue.get('fix_available', False)
                    }
                    for issue in issues
                ]

            return []

        except subprocess.TimeoutExpired:
            print(f"⚠️  ruff timed out on {file_path}", file=sys.stderr)
            return []
        except FileNotFoundError:
            # ruff not installed
            return []
        except Exception as e:
            print(f"⚠️  ruff execution failed: {e}", file=sys.stderr)
            return []

    def _run_eslint(self, file_path: str, auto_fix: bool = False) -> List[Dict[str, Any]]:
        """Run eslint linter (JavaScript/TypeScript)"""
        try:
            cmd = ['npx', 'eslint', file_path, '--format=json']
            if auto_fix:
                cmd.append('--fix')

            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)

            # Parse JSON output
            if result.stdout:
                output = json.loads(result.stdout)
                if output and len(output) > 0:
                    messages = output[0].get('messages', [])
                    return [
                        {
                            'tool': 'eslint',
                            'line': msg.get('line'),
                            'column': msg.get('column'),
                            'message': msg.get('message'),
                            'rule': msg.get('ruleId'),
                            'severity': msg.get('severity'),
                            'fixed': auto_fix and msg.get('fix') is not None
                        }
                        for msg in messages
                    ]

            return []

        except subprocess.TimeoutExpired:
            print(f"⚠️  eslint timed out on {file_path}", file=sys.stderr)
            return []
        except FileNotFoundError:
            # eslint not installed
            return []
        except Exception as e:
            print(f"⚠️  eslint execution failed: {e}", file=sys.stderr)
            return []

    def _run_basedpyright(self, file_path: str) -> List[Dict[str, Any]]:
        """Run basedpyright type checker (Python)"""
        try:
            cmd = ['basedpyright', '--outputjson', file_path]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)

            # Parse JSON output
            if result.stdout:
                output = json.loads(result.stdout)
                diagnostics = output.get('generalDiagnostics', [])
                return [
                    {
                        'tool': 'basedpyright',
                        'line': diag.get('range', {}).get('start', {}).get('line'),
                        'column': diag.get('range', {}).get('start', {}).get('character'),
                        'message': diag.get('message'),
                        'severity': diag.get('severity', 'warning'),
                        'rule': diag.get('rule'),
                        'fixed': False  # Type checkers don't auto-fix
                    }
                    for diag in diagnostics
                ]

            return []

        except subprocess.TimeoutExpired:
            print(f"⚠️  basedpyright timed out on {file_path}", file=sys.stderr)
            return []
        except FileNotFoundError:
            # basedpyright not installed
            return []
        except Exception as e:
            print(f"⚠️  basedpyright execution failed: {e}", file=sys.stderr)
            return []

    def _run_tsc(self, file_path: str) -> List[Dict[str, Any]]:
        """Run TypeScript compiler type checker"""
        try:
            cmd = ['tsc', '--noEmit', file_path]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)

            # Parse tsc output (not JSON, just text)
            if result.stderr:
                warnings = []
                for line in result.stderr.splitlines():
                    if file_path in line and '(' in line:
                        # Parse: file.ts(line,col): error TS####: message
                        parts = line.split(':', 2)
                        if len(parts) >= 3:
                            location = parts[0].split('(')[1].rstrip(')')
                            line_num, col_num = location.split(',')
                            warnings.append({
                                'tool': 'tsc',
                                'line': int(line_num),
                                'column': int(col_num),
                                'message': parts[2].strip(),
                                'severity': 'error' if 'error' in parts[1] else 'warning',
                                'fixed': False
                            })
                return warnings

            return []

        except subprocess.TimeoutExpired:
            print(f"⚠️  tsc timed out on {file_path}", file=sys.stderr)
            return []
        except FileNotFoundError:
            # tsc not installed
            return []
        except Exception as e:
            print(f"⚠️  tsc execution failed: {e}", file=sys.stderr)
            return []

    def _format_warning_reminder(self, warnings: List[Dict[str, Any]], file_path: str) -> str:
        """Format pre-tool warning reminder"""
        if not warnings:
            return ""

        summary = f"⚠️  Quality check: {len(warnings)} issue(s) found in {file_path}"
        details = []
        for w in warnings[:3]:  # Show first 3
            line = f"  - Line {w.get('line', '?')}: {w.get('message', 'Unknown issue')}"
            details.append(line)

        if len(warnings) > 3:
            details.append(f"  ... and {len(warnings) - 3} more")

        return '\n'.join([summary] + details)

    def _format_post_tool_reminder(self, warnings: List[Dict[str, Any]], file_path: str) -> str:
        """Format post-tool warning reminder with auto-fix info"""
        if not warnings:
            return ""

        fixed_count = sum(1 for w in warnings if w.get('fixed'))
        remaining_count = len(warnings) - fixed_count

        lines = []
        if fixed_count > 0:
            lines.append(f"✅ Auto-fixed {fixed_count} issue(s) in {file_path}")

        if remaining_count > 0:
            lines.append(f"⚠️  {remaining_count} issue(s) require manual review:")
            for w in [w for w in warnings if not w.get('fixed')][:3]:
                lines.append(f"  - Line {w.get('line', '?')}: {w.get('message', 'Unknown')}")

        return '\n'.join(lines)

    def _log_quality_metrics(self, file_path: str, language: str, warnings: List[Dict[str, Any]]) -> None:
        """Log quality metrics to database"""
        if not self.event_repo:
            return

        try:
            self.event_repo.log_event(
                'quality_check',
                {
                    'file': file_path,
                    'language': language,
                    'warning_count': len(warnings),
                    'fixed_count': sum(1 for w in warnings if w.get('fixed')),
                    'timestamp': datetime.now().isoformat()
                }
            )
        except Exception as e:
            print(f"⚠️  Failed to log quality metrics: {e}", file=sys.stderr)


# Global instance
_suggestion_engine: Optional[SuggestionEngine] = None


def get_engine() -> SuggestionEngine:
    """Get global suggestion engine instance"""
    global _suggestion_engine
    if _suggestion_engine is None:
        _suggestion_engine = SuggestionEngine()
    return _suggestion_engine


def handle_pre_tool_use(event: Dict[str, Any]) -> Dict[str, Any]:
    """Handler for pre-tool-use hook"""
    engine = get_engine()
    tool = event.get('tool', 'unknown')
    params = event.get('params', {})
    return engine.handle_pre_tool(tool, params)


def handle_post_tool_use(event: Dict[str, Any]) -> Dict[str, Any]:
    """Handler for post-tool-use hook"""
    engine = get_engine()
    tool = event.get('tool', 'unknown')
    params = event.get('params', {})
    result = event.get('result')
    return engine.handle_post_tool(tool, params, result)


if __name__ == '__main__':
    # Test with sample file
    print("\n✅ Suggestion Engine Test\n")

    engine = get_engine()

    # Test Python file
    test_file = Path(__file__)
    print(f"Testing: {test_file}")

    result = engine.handle_post_tool('Write', {'file_path': str(test_file)}, None)
    print(f"\nResult: {result['status']}")
    if result.get('warnings'):
        print(f"Warnings: {len(result['warnings'])}")
