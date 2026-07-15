#!/usr/bin/env python3
# scripts/auto_test.py

import os
import subprocess
import json

def handle_file_change():
    tool_name = os.environ.get('TOOL_NAME', '')
    file_path = os.environ.get('TOOL_FILE_PATH', '')

    if tool_name not in ['Edit', 'Write']:
        return

    # TypeScript file changed? Run type checking
    if file_path.endswith('.ts') or file_path.endswith('.tsx'):
        print("🔍 Running TypeScript checks...")
        subprocess.run(['npm', 'run', 'typecheck'], capture_output=True)

    # Test file changed? Run related tests
    if 'test' in file_path or 'spec' in file_path:
        print("🧪 Running tests...")
        subprocess.run(['npm', 'test', file_path], capture_output=True)

    # Component changed? Run component tests
    if '/components/' in file_path:
        test_file = file_path.replace('.tsx', '.test.tsx')
        if os.path.exists(test_file):
            print(f"🎯 Running component tests for {os.path.basename(file_path)}")
            subprocess.run(['npm', 'test', test_file])

if __name__ == "__main__":
    handle_file_change()