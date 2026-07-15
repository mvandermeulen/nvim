#!/bin/bash
set -e
cd "$CLAUDE_PROJECT_DIR/.claude/hooks"
cat | npx tsx src/path-rules.ts
