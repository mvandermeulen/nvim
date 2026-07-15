#!/home/vandem/.claude/data/venv/bin/python3
"""
Custom handler generator.

Creates a new handler from the template with your specified configuration.

Usage:
    python scripts/create_handler.py my_handler --tools Bash Edit --event pre
    
Examples:
    python scripts/create_handler.py security_checker --tools Bash --event pre
    python scripts/create_handler.py output_analyzer --tools Grep Read --event post
    python scripts/create_handler.py file_tracker --tools Edit Write --event both
"""
import argparse
import re
import sys
from pathlib import Path

CUSTOM_HANDLERS_DIR = Path(__file__).parent.parent / "handlers" / "custom"
TEMPLATE_FILE = CUSTOM_HANDLERS_DIR / "handler_template.py"


def validate_handler_name(name: str) -> bool:
    """Validate handler name is a valid Python identifier."""
    return bool(re.match(r'^[a-z][a-z0-9_]*$', name))


def generate_handler(
    name: str,
    tools: list[str],
    event_type: str,
    description: str = None,
) -> str:
    """Generate handler code from template."""
    
    # Read template
    template = TEMPLATE_FILE.read_text()
    
    # Customize the docstring
    custom_docstring = f'''"""
Custom handler: {name}

{description or f"Custom handler for {', '.join(tools)} tool{'s' if len(tools) > 1 else ''}."}

Event type: {event_type}
"""'''
    
    # Replace the template docstring
    template = re.sub(
        r'"""[\s\S]*?Usage:[\s\S]*?"""',
        custom_docstring,
        template,
        count=1
    )
    
    # Update APPLIES_TO
    tools_str = "[" + ", ".join(f'"{t}"' for t in tools) + "]"
    template = re.sub(
        r'APPLIES_TO = \[.*?\]',
        f'APPLIES_TO = {tools_str}',
        template
    )
    
    # Update state name
    template = template.replace(
        '"my_custom_handler"',
        f'"{name}"'
    )
    
    # Update log event names
    template = template.replace(
        '"custom_handler"',
        f'"{name}"'
    )
    
    # Update message prefix
    template = template.replace(
        '[Custom Handler]',
        f'[{name.replace("_", " ").title()}]'
    )
    
    # If event type is 'pre' only, remove PostToolUse handler
    if event_type == 'pre':
        # Keep PreToolUse, simplify PostToolUse to pass-through
        template = re.sub(
            r'def handle_post_tool\(raw: dict\)[\s\S]*?return None\n\n',
            '''def handle_post_tool(raw: dict) -> dict | None:
    """PostToolUse handler - not used for this handler."""
    return None


''',
            template
        )
    
    # If event type is 'post' only, simplify PreToolUse
    elif event_type == 'post':
        template = re.sub(
            r'def handle_pre_tool\(raw: dict\)[\s\S]*?return None\n\n',
            '''def handle_pre_tool(raw: dict) -> dict | None:
    """PreToolUse handler - not used for this handler."""
    return None


''',
            template
        )
    
    return template


def create_handler(
    name: str,
    tools: list[str],
    event_type: str,
    description: str = None,
    force: bool = False,
) -> Path:
    """Create a new handler file."""
    
    # Validate name
    if not validate_handler_name(name):
        raise ValueError(
            f"Invalid handler name '{name}'. "
            "Use lowercase letters, numbers, and underscores. "
            "Must start with a letter."
        )
    
    # Check if file exists
    output_path = CUSTOM_HANDLERS_DIR / f"{name}.py"
    if output_path.exists() and not force:
        raise FileExistsError(
            f"Handler '{name}' already exists at {output_path}. "
            "Use --force to overwrite."
        )
    
    # Generate and write
    code = generate_handler(name, tools, event_type, description)
    output_path.write_text(code)
    
    return output_path


def print_registration_instructions(name: str, tools: list[str], event_type: str) -> None:
    """Print instructions for registering the handler."""
    print("\n--- REGISTRATION INSTRUCTIONS ---")
    print("\nTo enable your handler, add it to the appropriate dispatcher.")
    print(f"\nFor {event_type.upper()} events on {', '.join(tools)}:")
    
    if event_type in ('pre', 'both'):
        print(f"\n1. Edit hooks/dispatchers/pre_tool.py:")
        print(f"   - Add '{name}' to ALL_HANDLERS list")
        print(f"   - Add to TOOL_HANDLERS for specific tools:")
        for tool in tools:
            print(f'       "{tool}": [..., "{name}"],')
    
    if event_type in ('post', 'both'):
        print(f"\n2. Edit hooks/dispatchers/post_tool.py:")
        print(f"   - Add '{name}' to ALL_HANDLERS list")
        print(f"   - Add to TOOL_HANDLERS for specific tools:")
        for tool in tools:
            print(f'       "{tool}": [..., "{name}"],')
    
    print(f"\n3. Import the handler in the dispatcher:")
    print(f'   from hooks.handlers.custom.{name} import handle_pre_tool, handle_post_tool')
    
    print("\nAlternatively, use settings.json for direct hook registration:")
    print(f'  "hooks": {{')
    print(f'    "PreToolUse": [')
    print(f'      {{')
    print(f'        "matcher": "tool_name in {tools}",')
    print(f'        "hooks": ["~/.claude/hooks/handlers/custom/{name}.py"]')
    print(f'      }}')
    print(f'    ]')
    print(f'  }}')


def main():
    parser = argparse.ArgumentParser(
        description='Create a new custom hook handler',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
    %(prog)s my_checker --tools Bash --event pre
    %(prog)s file_tracker --tools Edit Write --event both
    %(prog)s output_monitor --tools Grep Read --event post --desc "Monitor search results"
'''
    )
    
    parser.add_argument('name', help='Handler name (lowercase, underscores ok)')
    parser.add_argument('--tools', '-t', nargs='+', required=True,
                        help='Tools to handle (e.g., Bash Edit Write)')
    parser.add_argument('--event', '-e', choices=['pre', 'post', 'both'], default='both',
                        help='Event type: pre (PreToolUse), post (PostToolUse), or both')
    parser.add_argument('--desc', '-d', help='Handler description')
    parser.add_argument('--force', '-f', action='store_true',
                        help='Overwrite existing handler')
    
    args = parser.parse_args()
    
    try:
        output_path = create_handler(
            args.name,
            args.tools,
            args.event,
            args.desc,
            args.force,
        )
        print(f"✓ Created handler: {output_path}")
        print_registration_instructions(args.name, args.tools, args.event)
        
    except (ValueError, FileExistsError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
