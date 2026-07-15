#!/usr/bin/env python3
"""
Hook System Configuration

Central configuration for all hook components:
- Quality gate thresholds
- Tool preferences per language
- Auto-fix settings
- Redis settings
- Feature flags
"""

from typing import Dict, Any


# Quality Gate Configuration
QUALITY_GATE_CONFIG: Dict[str, Dict[str, Any]] = {
    'python': {
        'linter': 'ruff',
        'type_checker': 'basedpyright',
        'auto_fix': True,
        'timeout': 5,  # seconds
    },
    'typescript': {
        'linter': 'eslint',
        'type_checker': 'tsc',
        'auto_fix': True,
        'timeout': 5,
    },
    'javascript': {
        'linter': 'eslint',
        'type_checker': None,
        'auto_fix': True,
        'timeout': 5,
    },
}

# Auto-fix global toggle
AUTO_FIX_ENABLED = True

# Enforcement levels
ENFORCEMENT_LEVEL = 'advisory'  # 'advisory', 'warning', 'blocking'
# User chose: advisory warnings + auto-fix only (no blocking)

# Quality thresholds
QUALITY_THRESHOLDS = {
    'max_warnings_advisory': 100,  # Just report, don't block
    'max_errors_advisory': 50,
}

# Redis Configuration
REDIS_CONFIG = {
    'host': 'localhost',
    'port': 6379,
    'db': 0,
    'enabled': True,  # Graceful degradation if unavailable
}

# Context Management
CONTEXT_THRESHOLDS = {
    'warning': 31,  # 🟡 Approaching
    'critical': 46,  # 🔴 Handover now
}

# Session Health
SESSION_HEALTH_CONFIG = {
    'message_count_thresholds': CONTEXT_THRESHOLDS,
    'auto_handover': True,  # Auto-generate handover at critical threshold
}

# Feature Flags
FEATURE_FLAGS = {
    'redis_coordination': True,
    'code_quality_validation': True,
    'smart_resume': False,  # Phase 2.7
    'decision_learning': False,  # Phase 2.7
    'pattern_recognition': False,  # Phase 2.7
}

# Logging
LOGGING_CONFIG = {
    'level': 'INFO',
    'format': 'json',
    'file': '.claude/hooks/data/hooks.log',
}

# External Tool Paths (optional overrides)
TOOL_PATHS = {
    'ruff': 'ruff',
    'basedpyright': 'basedpyright',
    'eslint': 'npx eslint',
    'tsc': 'tsc',
}


def get_quality_config(language: str) -> Dict[str, Any]:
    """Get quality gate configuration for a language"""
    return QUALITY_GATE_CONFIG.get(language, {})


def is_auto_fix_enabled(language: str) -> bool:
    """Check if auto-fix is enabled for a language"""
    if not AUTO_FIX_ENABLED:
        return False
    config = get_quality_config(language)
    return config.get('auto_fix', False)


def get_enforcement_level() -> str:
    """Get current enforcement level"""
    return ENFORCEMENT_LEVEL


def is_feature_enabled(feature: str) -> bool:
    """Check if a feature is enabled"""
    return FEATURE_FLAGS.get(feature, False)
