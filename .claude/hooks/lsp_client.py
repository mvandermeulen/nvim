#!/usr/bin/env python3
"""
LSP Client Wrapper - Real-time code verification and intelligent refactoring

This module provides:
1. Real-time diagnostics (errors/warnings)
2. Symbol navigation (definitions, references)
3. Code actions (quick fixes, refactoring)
4. Type checking
5. Safe refactoring operations

Architecture:
- Wraps LSP client for different languages
- Provides validation hooks for Edit/Write operations
- Supports preview mode for safe changes
- Integrates with quality gates

Pattern Source: Comprehensive Claude Code Management System Design - Phase 1
"""

import json
import subprocess
from pathlib import Path
from typing import Dict, Any, List, Optional, Literal
from dataclasses import dataclass
from enum import Enum


class DiagnosticSeverity(Enum):
    """LSP diagnostic severity levels"""
    ERROR = 1
    WARNING = 2
    INFORMATION = 3
    HINT = 4


@dataclass
class Diagnostic:
    """LSP diagnostic"""
    severity: DiagnosticSeverity
    message: str
    line: int
    character: int
    source: str = ''
    code: Optional[str] = None


@dataclass
class EditPreview:
    """Preview of an edit operation"""
    file_path: str
    old_content: str
    new_content: str
    has_errors: bool
    errors: List[Diagnostic]
    warnings: List[Diagnostic]


class LSPClient:
    """
    LSP client wrapper for code verification

    Provides:
    - Diagnostics retrieval
    - Edit previewing
    - Safe refactoring
    - Symbol navigation
    """

    def __init__(self):
        """Initialize LSP client"""
        self.lsp_available = self._check_lsp_availability()

    def _check_lsp_availability(self) -> bool:
        """Check if LSP is available (Claude Code IDE integration)"""
        # Check if Claude Code IDE LSP integration is available
        # This is a placeholder - actual implementation depends on Claude Code's MCP
        try:
            # For now, we'll assume LSP is not directly available from hooks
            # Future: integrate with Claude Code's LSP via MCP
            return False
        except Exception:
            return False

    def is_available(self) -> bool:
        """Check if LSP is available"""
        return self.lsp_available

    # Diagnostics

    def get_diagnostics(self, file_path: str) -> List[Diagnostic]:
        """
        Get diagnostics for file

        Note: Currently returns empty list - future integration with Claude Code LSP
        """
        if not self.is_available():
            return []

        # Future: call Claude Code's LSP via MCP
        return []

    def has_errors(self, file_path: str) -> bool:
        """Check if file has errors"""
        diagnostics = self.get_diagnostics(file_path)
        return any(d.severity == DiagnosticSeverity.ERROR for d in diagnostics)

    def get_errors(self, file_path: str) -> List[Diagnostic]:
        """Get only errors"""
        diagnostics = self.get_diagnostics(file_path)
        return [d for d in diagnostics if d.severity == DiagnosticSeverity.ERROR]

    def get_warnings(self, file_path: str) -> List[Diagnostic]:
        """Get only warnings"""
        diagnostics = self.get_diagnostics(file_path)
        return [d for d in diagnostics if d.severity == DiagnosticSeverity.WARNING]

    # Edit Validation

    def preview_edit(self, file_path: str, old_string: str, new_string: str) -> EditPreview:
        """
        Preview edit operation

        Simulates the edit and checks for errors before applying
        """
        # Read current content
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                old_content = f.read()
        except Exception as e:
            return EditPreview(
                file_path=file_path,
                old_content='',
                new_content='',
                has_errors=True,
                errors=[Diagnostic(
                    severity=DiagnosticSeverity.ERROR,
                    message=f"Failed to read file: {e}",
                    line=0,
                    character=0
                )],
                warnings=[]
            )

        # Apply edit in memory
        if old_string not in old_content:
            return EditPreview(
                file_path=file_path,
                old_content=old_content,
                new_content=old_content,
                has_errors=True,
                errors=[Diagnostic(
                    severity=DiagnosticSeverity.ERROR,
                    message=f"String not found: {old_string[:50]}...",
                    line=0,
                    character=0
                )],
                warnings=[]
            )

        new_content = old_content.replace(old_string, new_string, 1)

        # Future: Write to temp file and get diagnostics
        # For now, basic validation
        errors: List[Diagnostic] = []
        warnings: List[Diagnostic] = []

        return EditPreview(
            file_path=file_path,
            old_content=old_content,
            new_content=new_content,
            has_errors=len(errors) > 0,
            errors=errors,
            warnings=warnings
        )

    # Validation Hooks

    def pre_tool_use_validation(self, tool: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Validate before tool execution

        Checks if operation would introduce errors
        """
        if not self.is_available():
            return {'status': 'ok', 'note': 'LSP not available'}

        if tool in ['Edit', 'Write']:
            file_path = params.get('file_path', '')

            # For Edit, preview the change
            if tool == 'Edit':
                old_string = params.get('old_string', '')
                new_string = params.get('new_string', '')

                preview = self.preview_edit(file_path, old_string, new_string)

                if preview.has_errors:
                    return {
                        'status': 'warning',
                        'message': 'Edit would introduce errors',
                        'errors': [
                            {
                                'severity': e.severity.name,
                                'message': e.message,
                                'line': e.line
                            }
                            for e in preview.errors
                        ]
                    }

        return {'status': 'ok'}

    def post_tool_use_verification(self, tool: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Verify after tool execution

        Checks if operation introduced errors
        """
        if not self.is_available():
            return {'status': 'ok', 'note': 'LSP not available'}

        if tool in ['Edit', 'Write']:
            file_path = params.get('file_path', '')

            # Get diagnostics for the modified file
            diagnostics = self.get_diagnostics(file_path)
            errors = [d for d in diagnostics if d.severity == DiagnosticSeverity.ERROR]
            warnings = [d for d in diagnostics if d.severity == DiagnosticSeverity.WARNING]

            if errors:
                return {
                    'status': 'failed',
                    'errors': [
                        {
                            'severity': e.severity.name,
                            'message': e.message,
                            'line': e.line,
                            'character': e.character
                        }
                        for e in errors
                    ],
                    'action': 'revert_changes'
                }

            if warnings:
                return {
                    'status': 'passed_with_warnings',
                    'warnings': [
                        {
                            'severity': w.severity.name,
                            'message': w.message,
                            'line': w.line,
                            'character': w.character
                        }
                        for w in warnings
                    ]
                }

            return {'status': 'passed'}

        return {'status': 'ok'}

    # Future: Symbol navigation, refactoring, etc.


# Global instance (singleton pattern)
_lsp_client: Optional[LSPClient] = None


def get_lsp_client() -> LSPClient:
    """Get global LSP client instance"""
    global _lsp_client
    if _lsp_client is None:
        _lsp_client = LSPClient()
    return _lsp_client


# Convenience functions for quality gates

def validate_edit(file_path: str, old_string: str, new_string: str) -> Dict[str, Any]:
    """Validate edit operation"""
    client = get_lsp_client()
    preview = client.preview_edit(file_path, old_string, new_string)

    return {
        'valid': not preview.has_errors,
        'errors': [
            {
                'severity': e.severity.name,
                'message': e.message,
                'line': e.line
            }
            for e in preview.errors
        ],
        'warnings': [
            {
                'severity': w.severity.name,
                'message': w.message,
                'line': w.line
            }
            for w in preview.warnings
        ]
    }


# Example usage
if __name__ == '__main__':
    client = get_lsp_client()

    if client.is_available():
        print("\n✅ LSP Client Test\n")
        print("LSP integration active")
    else:
        print("\n⚠️  LSP not available")
        print("Future: Will integrate with Claude Code's LSP via MCP")
        print("Current: Basic validation only")
