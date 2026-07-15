#!/usr/bin/env python3
# save as: ~/.claude/hooks/pre-tool-use

import sys
import json

# Read the event data
event = json.loads(sys.stdin.read())

# Check if it's a dangerous command
if event['tool_name'] == 'bash':
    command = event.get('arguments', {}).get('command', '')
    dangerous_patterns = ['rm -rf', 'rm -r /', 'format', 'dd if=']
    
    for pattern in dangerous_patterns:
        if pattern in command:
            print(f"BLOCKED: Dangerous command attempted: {command}")
            sys.exit(1)  # Block the tool use

# Allow safe commands
sys.exit(0)