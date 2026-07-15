#!/usr/bin/env python3
"""Integration test for auto-handover system"""

import os
import sys
import yaml
from pathlib import Path
import tempfile
import shutil

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))


def test_auto_handover_flow():
    """Test complete flow from threshold to handover generation"""

    print("🧪 Testing auto-handover integration flow...")

    # Setup: Create temp session file
    session_file = Path('.claude/session/current-session.yaml')
    session_file.parent.mkdir(parents=True, exist_ok=True)

    session_data = {
        'session': {
            'id': 'test-session',
            'health': '🟢',
            'message_count': 0,
            'mode': 'BUILD',
            'scope': 'MEDIUM'
        },
        'task': {
            'title': 'Test Task',
            'progress': 50,
            'phase': 'implementation'
        },
        'todos': {
            'completed': ['Task 1', 'Task 2'],
            'pending': ['Task 3', 'Task 4'],
            'in_progress': ['Current Task']
        },
        'context': {
            'current_file': 'test_file.py'
        }
    }

    with open(session_file, 'w') as f:
        yaml.dump(session_data, f)

    # Test: Increment to threshold
    counter_file = Path('.claude/session/.message_count')
    counter_file.write_text('46')

    # Trigger handover
    from handlers.handover_generator import generate_handover
    result = generate_handover()

    # Verify status
    assert result['status'] == 'success', f"Failed: {result}"
    print(f"✓ Handover generation successful")

    # Verify file created
    handover_file = Path(result['data']['handover_file'])
    assert handover_file.exists(), "Handover file not created"
    print(f"✓ Handover file created: {handover_file}")

    # Verify content
    content = handover_file.read_text()

    # Check session data populated
    assert 'test-session' in content, "Session ID not in handover"
    assert 'Test Task' in content, "Task title not in handover"
    assert '🔴' in content, "Health status not in handover"
    assert '46' in content, "Message count not in handover"
    print(f"✓ Session data populated correctly")

    # Check todos populated
    assert '✅ Task 1' in content, "Completed todos not in handover"
    assert '⏸️ Task 3' in content, "Pending todos not in handover"
    assert '🔄 Current Task' in content, "In-progress todos not in handover"
    print(f"✓ Todos formatted correctly")

    # Check no unpopulated placeholders remain
    unpopulated = [line for line in content.split('\n') if '{{' in line and '}}' in line]
    assert len(unpopulated) == 0, f"Found unpopulated placeholders: {unpopulated}"
    print(f"✓ All placeholders populated")

    # Verify last-handover pointer
    last_handover = Path('.claude/session/last-handover.md')
    assert last_handover.exists(), "last-handover.md not created"
    assert last_handover.read_text() == content, "last-handover.md content mismatch"
    print(f"✓ Last-handover pointer updated")

    print("\n✅ Auto-handover integration test PASSED")

    # Cleanup
    if handover_file.parent.exists():
        shutil.rmtree(handover_file.parent)
    counter_file.unlink(missing_ok=True)
    session_file.unlink(missing_ok=True)
    last_handover.unlink(missing_ok=True)
    print("✓ Cleanup complete")

    return True


def test_handover_without_session_file():
    """Test handover generation works WITHOUT session file (resilient mode)"""

    print("\n🧪 Testing resilient handover (no session file)...")

    # Setup: Ensure NO session file exists
    session_file = Path('.claude/session/current-session.yaml')
    if session_file.exists():
        session_file.unlink()

    # Set message count
    counter_file = Path('.claude/session/.message_count')
    counter_file.parent.mkdir(parents=True, exist_ok=True)
    counter_file.write_text('46')

    # Trigger handover WITHOUT session file
    from handlers.handover_generator import generate_handover
    result = generate_handover()

    # Verify success despite missing session file
    assert result['status'] == 'success', f"Failed without session file: {result}"
    print(f"✓ Generated handover without session file")

    handover_file = Path(result['data']['handover_file'])
    assert handover_file.exists(), "Handover file not created"
    print(f"✓ Handover file created")

    content = handover_file.read_text()

    # Verify fallback values used
    assert 'Auto-handover (no active task tracked)' in content, "Fallback task title not used"
    assert '46' in content, "Message count not in handover"
    assert '🔴' in content, "Health status not in handover"
    print(f"✓ Fallback values populated correctly")

    # Verify no unpopulated placeholders
    unpopulated = [line for line in content.split('\n') if '{{' in line and '}}' in line]
    assert len(unpopulated) == 0, f"Found unpopulated placeholders: {unpopulated}"
    print(f"✓ All placeholders populated with fallbacks")

    print("\n✅ Resilient handover test PASSED")

    # Cleanup
    if handover_file.parent.exists():
        shutil.rmtree(handover_file.parent)
    counter_file.unlink(missing_ok=True)
    print("✓ Cleanup complete")

    return True


if __name__ == '__main__':
    try:
        success1 = test_auto_handover_flow()
        success2 = test_handover_without_session_file()

        if success1 and success2:
            print("\n" + "="*60)
            print("✅ ALL TESTS PASSED")
            print("="*60)
            sys.exit(0)
        else:
            sys.exit(1)
    except Exception as e:
        print(f"\n❌ Test FAILED: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
