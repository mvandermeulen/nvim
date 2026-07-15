#!/bin/bash
# Session start hook: Warm tldr cache and build semantic index
# Uses tldr warm for incremental indexing (P0-P4)
# Builds semantic index (P5) after warm completes

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TLDR_DIR="${PROJECT_DIR}/.tldr"
CACHE_DIR="${TLDR_DIR}/cache"

# Run tldr warm in background if call graph missing
if [ ! -f "$CACHE_DIR/call_graph.json" ]; then
  nohup tldr warm "$PROJECT_DIR" --background >/dev/null 2>&1 &
  echo '{"status": "tldr_warming"}'
  exit 0
fi

# Build semantic index after warm completes (in background)
if [ -f "$CACHE_DIR/call_graph.json" ] && [ ! -f "$CACHE_DIR/semantic/index.faiss" ]; then
  nohup tldr semantic index "$PROJECT_DIR" > "$TLDR_DIR/semantic_indexing.log" 2>&1 &
  echo '{"status": "tldr_semantic_indexing"}'
  exit 0
fi

# Everything ready
echo '{"status": "tldr_ready"}'
