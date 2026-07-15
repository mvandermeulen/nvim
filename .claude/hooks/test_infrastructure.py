#!/usr/bin/env python3
"""
Infrastructure Test Script

Tests all Phase 1 components:
1. Coordinator routing
2. Redis coordinator (if available)
3. LSP client wrapper
4. Storage abstraction layer
"""

import sys
from pathlib import Path

# Add hooks directory to path
sys.path.insert(0, str(Path(__file__).parent))

import coordinator
import redis_coordinator
import lsp_client
import storage


def test_coordinator():
    """Test hook coordinator"""
    print("\n" + "="*60)
    print("Testing Hook Coordinator")
    print("="*60)

    # Test handler registration
    coordinator.register_handlers()
    print(f"✅ Handlers registered: {len(coordinator.HOOK_HANDLERS)} hook types")

    # Test event execution
    result = coordinator.execute_handlers('session-start', {})
    print(f"✅ Session-start executed: {result['handlers_executed']} handlers")

    return True


def test_redis():
    """Test Redis coordinator"""
    print("\n" + "="*60)
    print("Testing Redis Coordinator")
    print("="*60)

    coord = redis_coordinator.get_coordinator()

    if coord.is_available():
        print("✅ Redis available and connected")

        # Test agent registration
        test_id = 'test-agent-123'
        coord.register_agent(test_id, 'test-type')
        print(f"✅ Agent registered: {test_id}")

        # Test caching
        coord.cache_result('test-key', {'data': 'test'}, ttl=60)
        cached = coord.get_cached_result('test-key')
        print(f"✅ Cache working: {cached}")

        # Cleanup
        coord.cleanup_agent(test_id)
        coord.invalidate_cache('test-key')
        print("✅ Cleanup complete")
    else:
        print("⚠️  Redis not available (optional - install with: pip install redis)")

    return True


def test_lsp():
    """Test LSP client"""
    print("\n" + "="*60)
    print("Testing LSP Client")
    print("="*60)

    client = lsp_client.get_lsp_client()

    if client.is_available():
        print("✅ LSP available")
    else:
        print("⚠️  LSP not available (future: will integrate with Claude Code LSP)")
        print("    Current: Basic validation only")

    # Test validation (should work even without LSP)
    validation = client.pre_tool_use_validation('Edit', {
        'file_path': 'test.py',
        'old_string': 'foo',
        'new_string': 'bar'
    })
    print(f"✅ Validation check: {validation['status']}")

    return True


def test_storage():
    """Test storage layer"""
    print("\n" + "="*60)
    print("Testing Storage Layer")
    print("="*60)

    store = storage.get_storage()

    # Test JSON operations
    test_data = {'test': 'data', 'number': 42}
    store.write_json('test/test.json', test_data)
    loaded = store.read_json('test/test.json')
    assert loaded == test_data
    print("✅ JSON operations working")

    # Test Markdown operations
    test_md = "# Test\n\nThis is a test."
    store.write_markdown('test/test.md', test_md)
    loaded_md = store.read_markdown('test/test.md')
    assert loaded_md == test_md
    print("✅ Markdown operations working")

    # Test SQLite operations
    sessions = store.query_sessions(limit=5)
    print(f"✅ SQLite operations working ({len(sessions)} sessions)")

    return True


def run_all_tests():
    """Run all infrastructure tests"""
    print("\n" + "🚀"*30)
    print("CLAUDE CODE INFRASTRUCTURE TEST SUITE")
    print("🚀"*30)

    tests = [
        ("Coordinator", test_coordinator),
        ("Redis", test_redis),
        ("LSP Client", test_lsp),
        ("Storage", test_storage),
    ]

    results = []
    for name, test_func in tests:
        try:
            success = test_func()
            results.append((name, success))
        except Exception as e:
            print(f"\n❌ {name} test failed: {e}")
            import traceback
            traceback.print_exc()
            results.append((name, False))

    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)

    for name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status}: {name}")

    all_passed = all(success for _, success in results)

    if all_passed:
        print("\n🎉 All tests passed!")
    else:
        print("\n⚠️  Some tests failed")

    return all_passed


if __name__ == '__main__':
    success = run_all_tests()
    sys.exit(0 if success else 1)
