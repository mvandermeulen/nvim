
## Core Development Principles

**CRITICAL RULES:**
- NEVER EVER WRITE CODE COMMENTS unless explicitly requested
- Always use the vim-expert agent when users ask to open files
- Prioritize concise, direct responses (fewer than 8 lines unless detail requested)
- Minimize output tokens while maintaining helpfulness

### Language-Specific Preferences
- **Python**: 2-space indentation, type hints, pytest for testing
- **JavaScript/TypeScript**: 2-space indentation, modern ES6+, jest/vitest
- **Go**: gofmt compliance, table-driven tests
- **Rust**: cargo fmt, clippy warnings addressed
- **Shell scripts**: POSIX compatibility where possible
- **Lua**: 2-space indentation
