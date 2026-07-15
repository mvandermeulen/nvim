#!/usr/bin/env python3
"""
Unit tests for Redis Coordinator

Tests cover:
1. Work queue operations (enqueue, dequeue, complete, requeue)
2. Event broadcasting (all 8 channels)
3. Agent pool management
4. Result caching
5. Graceful degradation (works without Redis)
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
from unittest.mock import Mock, patch, MagicMock
import json
import time
from redis_coordinator import (
    RedisCoordinator,
    get_coordinator,
    enqueue_agent_work,
    get_next_work,
    REDIS_CHANNELS
)


class TestRedisCoordinator(unittest.TestCase):
    """Test Redis Coordinator functionality"""

    def setUp(self):
        """Setup test fixtures"""
        self.coordinator = RedisCoordinator()

    @patch('redis_coordinator.redis')
    def test_graceful_degradation_no_redis(self, mock_redis):
        """Test that coordinator works without Redis"""
        mock_redis.Redis.side_effect = Exception("Connection failed")

        coordinator = RedisCoordinator()
        self.assertFalse(coordinator.is_available())

        # All operations should return False/None gracefully
        self.assertFalse(coordinator.register_agent('agent-1', 'test'))
        self.assertIsNone(coordinator.get_agent_info('agent-1'))
        self.assertFalse(coordinator.enqueue_work({'type': 'test'}, priority=1))
        self.assertIsNone(coordinator.dequeue_work())

    @patch('redis_coordinator.redis')
    def test_agent_registration(self, mock_redis):
        """Test agent pool management"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Register agent
        result = coordinator.register_agent('agent-001', 'test-worker')
        self.assertTrue(result)

        # Verify hset called with correct data
        mock_client.hset.assert_called()
        call_args = mock_client.hset.call_args
        self.assertEqual(call_args[0][0], 'agent:agent-001')

    @patch('redis_coordinator.redis')
    def test_work_queue_operations(self, mock_redis):
        """Test work queue enqueue/dequeue/complete"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Enqueue work
        work_item = {'type': 'analyze', 'file': 'test.py'}
        result = coordinator.enqueue_work(work_item, priority=1)
        self.assertTrue(result)

        # Verify lpush called
        mock_client.lpush.assert_called()
        call_args = mock_client.lpush.call_args
        self.assertEqual(call_args[0][0], 'work:queue:1')

        # Work data should be JSON with added fields
        work_data = json.loads(call_args[0][1])
        self.assertEqual(work_data['type'], 'analyze')
        self.assertEqual(work_data['priority'], 1)
        self.assertIn('enqueued_at', work_data)

    @patch('redis_coordinator.redis')
    def test_work_queue_priority(self, mock_redis):
        """Test priority-based dequeuing"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Mock dequeue from urgent queue
        urgent_work = json.dumps({'type': 'urgent_task', 'priority': 0})
        mock_client.brpop.return_value = ('work:queue:0', urgent_work)

        # Dequeue should check high priority queues first
        work = coordinator.dequeue_work(priority=2, timeout=1)
        self.assertIsNotNone(work)
        self.assertEqual(work['type'], 'urgent_task')

    @patch('redis_coordinator.redis')
    def test_work_requeue_retry_limit(self, mock_redis):
        """Test requeue with retry limit"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Work item with max retries
        work_item = {'type': 'failing_task', 'retry_count': 3}

        # Should fail to requeue (exceeded max retries)
        result = coordinator.requeue_work(work_item, priority=2)
        self.assertFalse(result)

        # lpush should NOT be called
        mock_client.lpush.assert_not_called()

    @patch('redis_coordinator.redis')
    def test_work_completion(self, mock_redis):
        """Test work completion tracking"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Complete work
        result = coordinator.complete_work('work-123', {'status': 'success', 'output': 'done'})
        self.assertTrue(result)

        # Verify hset called with completion data
        mock_client.hset.assert_called()
        call_args = mock_client.hset.call_args
        self.assertEqual(call_args[0][0], 'work:completed:work-123')

        # Verify expire set (TTL)
        mock_client.expire.assert_called_with('work:completed:work-123', 3600)

    @patch('redis_coordinator.redis')
    def test_event_broadcasting_session(self, mock_redis):
        """Test session lifecycle event broadcasting"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Broadcast session start
        result = coordinator.broadcast_session_event('session_started', {'session_id': 'test-001'})
        self.assertTrue(result)

        # Verify publish called
        mock_client.publish.assert_called()
        call_args = mock_client.publish.call_args
        self.assertEqual(call_args[0][0], 'session:lifecycle')

        # Verify event data
        event_data = json.loads(call_args[0][1])
        self.assertEqual(event_data['event'], 'session_started')
        self.assertEqual(event_data['session_id'], 'test-001')

    @patch('redis_coordinator.redis')
    def test_event_broadcasting_health(self, mock_redis):
        """Test health warning broadcasting"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Broadcast health warning
        result = coordinator.broadcast_health_warning('🟡', {'message_count': 35})
        self.assertTrue(result)

        # Verify publish to correct channel
        mock_client.publish.assert_called()
        call_args = mock_client.publish.call_args
        self.assertEqual(call_args[0][0], 'session:health')

        # Verify event data
        event_data = json.loads(call_args[0][1])
        self.assertEqual(event_data['health_status'], '🟡')

    @patch('redis_coordinator.redis')
    def test_event_broadcasting_decision(self, mock_redis):
        """Test decision recording broadcast"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Broadcast decision
        result = coordinator.broadcast_decision({
            'decision': 'Use Redis for coordination',
            'rationale': 'Enables multi-agent patterns'
        })
        self.assertTrue(result)

        # Verify publish to correct channel
        mock_client.publish.assert_called()
        call_args = mock_client.publish.call_args
        self.assertEqual(call_args[0][0], 'decision:recorded')

    @patch('redis_coordinator.redis')
    def test_result_caching(self, mock_redis):
        """Test result caching with TTL"""
        mock_client = MagicMock()
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Cache result
        result = coordinator.cache_result('test-key', {'foo': 'bar'}, ttl=300)
        self.assertTrue(result)

        # Verify setex called with TTL
        mock_client.setex.assert_called()
        call_args = mock_client.setex.call_args
        self.assertEqual(call_args[0][0], 'cache:test-key')
        self.assertEqual(call_args[0][1], 300)  # TTL

    @patch('redis_coordinator.redis')
    def test_cache_key_generation(self, mock_redis):
        """Test deterministic cache key generation"""
        key1 = RedisCoordinator.generate_cache_key('agent:test', 'input1', 'input2')
        key2 = RedisCoordinator.generate_cache_key('agent:test', 'input1', 'input2')
        key3 = RedisCoordinator.generate_cache_key('agent:test', 'input2', 'input1')

        # Same inputs should produce same key
        self.assertEqual(key1, key2)

        # Different order should produce different key
        self.assertNotEqual(key1, key3)

        # Key should have prefix
        self.assertTrue(key1.startswith('agent:test:'))

    def test_redis_channels_defined(self):
        """Test that all required channels are defined"""
        expected_channels = [
            'agent:lifecycle',
            'agent:work_request',
            'agent:work_complete',
            'session:lifecycle',
            'session:health',
            'planning:update',
            'context:warning',
            'decision:recorded'
        ]

        for channel in expected_channels:
            self.assertIn(channel, REDIS_CHANNELS)

    @patch('redis_coordinator.get_coordinator')
    def test_convenience_functions(self, mock_get_coordinator):
        """Test convenience wrapper functions"""
        mock_coordinator = MagicMock()
        mock_coordinator.enqueue_work.return_value = True
        mock_get_coordinator.return_value = mock_coordinator

        # Test enqueue_agent_work
        result = enqueue_agent_work('analyze', {'file': 'test.py'}, priority=1)
        self.assertTrue(result)

        # Verify enqueue_work called with correct structure
        mock_coordinator.enqueue_work.assert_called_once()
        call_args = mock_coordinator.enqueue_work.call_args
        work_item = call_args[0][0]
        self.assertEqual(work_item['type'], 'analyze')
        self.assertIn('work_id', work_item)
        self.assertTrue(work_item['work_id'].startswith('analyze-'))


class TestCoordinatorIntegration(unittest.TestCase):
    """Test coordinator integration with other modules"""

    def test_singleton_pattern(self):
        """Test that get_coordinator returns same instance"""
        coord1 = get_coordinator()
        coord2 = get_coordinator()
        self.assertIs(coord1, coord2)

    @patch('redis_coordinator.redis')
    def test_error_handling_graceful(self, mock_redis):
        """Test graceful error handling"""
        mock_client = MagicMock()
        mock_client.hset.side_effect = Exception("Redis error")
        mock_redis.Redis.return_value = mock_client

        coordinator = RedisCoordinator()

        # Should not raise, just return False
        result = coordinator.register_agent('agent-1', 'test')
        self.assertFalse(result)


if __name__ == '__main__':
    print("\n✅ Running Redis Coordinator Test Suite\n")
    unittest.main(verbosity=2)
