#!/usr/bin/env python3
"""
Redis Coordinator - Agent coordination and distributed state management

This module provides:
1. Pub/Sub for agent events
2. Agent pool management
3. Result caching (TTL-based)
4. Task queue for async operations

Architecture:
- Redis channels for event broadcasting
- Agent lifecycle tracking
- Result caching to avoid redundant expensive operations
- Task queue with priority support

Pattern Source: Comprehensive Claude Code Management System Design - Phase 1
"""

import json
import hashlib
import time
from typing import Dict, Any, Optional, List
from datetime import datetime
from dataclasses import dataclass


# Redis connection settings
REDIS_HOST = 'localhost'
REDIS_PORT = 6379
REDIS_DB = 0

# Redis channel definitions (8 channels for comprehensive event broadcasting)
REDIS_CHANNELS = {
    # Agent coordination
    'agent:lifecycle': 'Agent start/stop/error events',
    'agent:work_request': 'Task delegation requests',
    'agent:work_complete': 'Task completion notifications',

    # Session management
    'session:lifecycle': 'Session start/end events',
    'session:health': 'Health warnings (🟡/🔴 thresholds)',

    # Planning and context
    'planning:update': 'Plan file change notifications',
    'context:warning': 'Context threshold alerts',
    'decision:recorded': 'High-impact decision events',
}

# Cache TTL (seconds)
DEFAULT_CACHE_TTL = 3600  # 1 hour


# Graceful degradation: Redis is optional
try:
    import redis  # type: ignore
    REDIS_AVAILABLE = True
except ImportError:
    redis = None  # type: ignore
    REDIS_AVAILABLE = False


@dataclass
class AgentInfo:
    """Agent metadata"""
    agent_id: str
    agent_type: str
    status: str
    started_at: float
    finished_at: Optional[float] = None
    result: Optional[Dict[str, Any]] = None


class RedisCoordinator:
    """
    Redis-based agent coordination and caching

    Provides:
    - Agent pool management
    - Result caching
    - Event pub/sub
    - Task queue
    """

    def __init__(self, host: str = REDIS_HOST, port: int = REDIS_PORT, db: int = REDIS_DB):
        """Initialize Redis connection (if available)"""
        self.redis_client = None
        self.pubsub = None

        if not REDIS_AVAILABLE:
            print("⚠️  Redis not available - running without coordination features", flush=True)
            return

        try:
            self.redis_client = redis.Redis(host=host, port=port, db=db, decode_responses=True)
            self.redis_client.ping()
            self.pubsub = self.redis_client.pubsub()
            print("✅ Redis connected", flush=True)
        except Exception as e:
            print(f"⚠️  Redis connection failed: {e} - running without coordination", flush=True)
            self.redis_client = None

    def is_available(self) -> bool:
        """Check if Redis is available"""
        return self.redis_client is not None

    # Agent Pool Management

    def register_agent(self, agent_id: str, agent_type: str) -> bool:
        """Register agent in pool"""
        if not self.is_available():
            return False

        try:
            agent_info = {
                'type': agent_type,
                'status': 'starting',
                'started_at': time.time()
            }
            if self.redis_client:
                self.redis_client.hset(f'agent:{agent_id}', mapping=agent_info)  # type: ignore
                self._publish('agent:status', {
                    'event': 'agent_started',
                    'agent_id': agent_id,
                    'agent_type': agent_type,
                    'timestamp': datetime.now().isoformat()
                })
            return True
        except Exception as e:
            print(f"⚠️  Failed to register agent: {e}", flush=True)
            return False

    def update_agent_status(self, agent_id: str, status: str) -> bool:
        """Update agent status"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                self.redis_client.hset(f'agent:{agent_id}', 'status', status)
            return True
        except Exception as e:
            print(f"⚠️  Failed to update agent status: {e}", flush=True)
            return False

    def complete_agent(self, agent_id: str, result: Dict[str, Any]) -> bool:
        """Mark agent as completed with result"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                self.redis_client.hset(f'agent:{agent_id}', mapping={
                    'status': 'completed',
                    'finished_at': time.time(),
                    'result': json.dumps(result)
                })
                self._publish('agent:results', {
                    'event': 'agent_completed',
                    'agent_id': agent_id,
                    'timestamp': datetime.now().isoformat()
                })
            return True
        except Exception as e:
            print(f"⚠️  Failed to complete agent: {e}", flush=True)
            return False

    def get_agent_info(self, agent_id: str) -> Optional[AgentInfo]:
        """Get agent information"""
        if not self.is_available():
            return None

        try:
            if self.redis_client:
                data = self.redis_client.hgetall(f'agent:{agent_id}')
                if data:
                    return AgentInfo(
                        agent_id=agent_id,
                        agent_type=data.get('type', 'unknown'),
                        status=data.get('status', 'unknown'),
                        started_at=float(data.get('started_at', 0)),
                        finished_at=float(data['finished_at']) if 'finished_at' in data else None,
                        result=json.loads(data['result']) if 'result' in data else None
                    )
            return None
        except Exception as e:
            print(f"⚠️  Failed to get agent info: {e}", flush=True)
            return None

    def cleanup_agent(self, agent_id: str) -> bool:
        """Remove agent from pool"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                self.redis_client.delete(f'agent:{agent_id}')
            return True
        except Exception as e:
            print(f"⚠️  Failed to cleanup agent: {e}", flush=True)
            return False

    # Work Queue Management

    def enqueue_work(self, work_item: Dict[str, Any], priority: int = 1) -> bool:
        """
        Enqueue work item for agent processing

        Args:
            work_item: Work specification (type, payload, etc.)
            priority: 0=urgent, 1=high, 2=normal, 3=low

        Returns:
            True if enqueued successfully
        """
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                queue_name = f'work:queue:{priority}'
                work_data = json.dumps({
                    **work_item,
                    'enqueued_at': time.time(),
                    'priority': priority
                })
                self.redis_client.lpush(queue_name, work_data)

                # Broadcast work availability
                self._publish('agent:work_request', {
                    'event': 'work_enqueued',
                    'priority': priority,
                    'work_type': work_item.get('type', 'unknown'),
                    'timestamp': datetime.now().isoformat()
                })
            return True
        except Exception as e:
            print(f"⚠️  Failed to enqueue work: {e}", flush=True)
            return False

    def dequeue_work(self, priority: int = 1, timeout: int = 1) -> Optional[Dict[str, Any]]:
        """
        Dequeue work item (blocking with timeout)

        Args:
            priority: Priority queue to check (0-3)
            timeout: Seconds to wait for work

        Returns:
            Work item dict or None if no work available
        """
        if not self.is_available():
            return None

        try:
            if self.redis_client:
                # Try high priority queues first (0, 1, 2, 3)
                for p in range(priority + 1):
                    queue_name = f'work:queue:{p}'
                    result = self.redis_client.brpop(queue_name, timeout=timeout)
                    if result:
                        _, work_data = result
                        return json.loads(work_data)
            return None
        except Exception as e:
            print(f"⚠️  Failed to dequeue work: {e}", flush=True)
            return None

    def complete_work(self, work_id: str, result: Dict[str, Any]) -> bool:
        """Mark work as completed and broadcast result"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                # Store completion record
                completion_data = {
                    'work_id': work_id,
                    'result': json.dumps(result),
                    'completed_at': time.time()
                }
                self.redis_client.hset(f'work:completed:{work_id}', mapping=completion_data)
                self.redis_client.expire(f'work:completed:{work_id}', 3600)  # 1 hour TTL

                # Broadcast completion
                self._publish('agent:work_complete', {
                    'event': 'work_completed',
                    'work_id': work_id,
                    'timestamp': datetime.now().isoformat()
                })
            return True
        except Exception as e:
            print(f"⚠️  Failed to complete work: {e}", flush=True)
            return False

    def requeue_work(self, work_item: Dict[str, Any], priority: int = 2) -> bool:
        """Re-queue failed work (lower priority to avoid tight loops)"""
        if not self.is_available():
            return False

        try:
            # Increment retry count
            retry_count = work_item.get('retry_count', 0) + 1
            if retry_count > 3:
                print(f"⚠️  Work item exceeded max retries: {work_item.get('type')}", flush=True)
                return False

            work_item['retry_count'] = retry_count
            return self.enqueue_work(work_item, priority)
        except Exception as e:
            print(f"⚠️  Failed to requeue work: {e}", flush=True)
            return False

    def get_work_queue_depth(self, priority: int = 1) -> int:
        """Get number of items in work queue"""
        if not self.is_available():
            return 0

        try:
            if self.redis_client:
                queue_name = f'work:queue:{priority}'
                return self.redis_client.llen(queue_name) or 0
            return 0
        except Exception as e:
            print(f"⚠️  Failed to get queue depth: {e}", flush=True)
            return 0

    # Enhanced Event Broadcasting

    def broadcast_session_event(self, event_type: str, session_data: Dict[str, Any]) -> bool:
        """Broadcast session lifecycle event"""
        return self._publish('session:lifecycle', {
            'event': event_type,
            **session_data,
            'timestamp': datetime.now().isoformat()
        })

    def broadcast_health_warning(self, health_status: str, session_data: Dict[str, Any]) -> bool:
        """Broadcast session health warning"""
        return self._publish('session:health', {
            'event': 'health_warning',
            'health_status': health_status,
            **session_data,
            'timestamp': datetime.now().isoformat()
        })

    def broadcast_decision(self, decision_data: Dict[str, Any]) -> bool:
        """Broadcast high-impact decision"""
        return self._publish('decision:recorded', {
            'event': 'decision_made',
            **decision_data,
            'timestamp': datetime.now().isoformat()
        })

    def broadcast_context_warning(self, context_data: Dict[str, Any]) -> bool:
        """Broadcast context threshold warning"""
        return self._publish('context:warning', {
            'event': 'context_threshold',
            **context_data,
            'timestamp': datetime.now().isoformat()
        })

    def broadcast_planning_update(self, plan_data: Dict[str, Any]) -> bool:
        """Broadcast planning document update"""
        return self._publish('planning:update', {
            'event': 'plan_updated',
            **plan_data,
            'timestamp': datetime.now().isoformat()
        })

    # Result Caching

    def cache_result(self, cache_key: str, result: Any, ttl: int = DEFAULT_CACHE_TTL) -> bool:
        """Cache expensive operation result"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                self.redis_client.setex(
                    f'cache:{cache_key}',
                    ttl,
                    json.dumps(result)
                )
            return True
        except Exception as e:
            print(f"⚠️  Failed to cache result: {e}", flush=True)
            return False

    def get_cached_result(self, cache_key: str) -> Optional[Any]:
        """Retrieve cached result if exists"""
        if not self.is_available():
            return None

        try:
            if self.redis_client:
                cached = self.redis_client.get(f'cache:{cache_key}')
                if cached:
                    return json.loads(cached)
            return None
        except Exception as e:
            print(f"⚠️  Failed to get cached result: {e}", flush=True)
            return None

    def invalidate_cache(self, cache_key: str) -> bool:
        """Invalidate cached result"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                self.redis_client.delete(f'cache:{cache_key}')
            return True
        except Exception as e:
            print(f"⚠️  Failed to invalidate cache: {e}", flush=True)
            return False

    # Pub/Sub Events

    def _publish(self, channel: str, message: Dict[str, Any]) -> bool:
        """Publish event to channel"""
        if not self.is_available():
            return False

        try:
            if self.redis_client:
                self.redis_client.publish(channel, json.dumps(message))
            return True
        except Exception as e:
            print(f"⚠️  Failed to publish to {channel}: {e}", flush=True)
            return False

    def subscribe(self, *channels: str) -> bool:
        """Subscribe to channels"""
        if not self.is_available() or not self.pubsub:
            return False

        try:
            self.pubsub.subscribe(*channels)
            return True
        except Exception as e:
            print(f"⚠️  Failed to subscribe: {e}", flush=True)
            return False

    def get_message(self, timeout: float = 1.0) -> Optional[Dict[str, Any]]:
        """Get message from subscribed channels"""
        if not self.is_available() or not self.pubsub:
            return None

        try:
            message = self.pubsub.get_message(timeout=timeout)
            if message and message['type'] == 'message':
                return {
                    'channel': message['channel'],
                    'data': json.loads(message['data'])
                }
            return None
        except Exception as e:
            print(f"⚠️  Failed to get message: {e}", flush=True)
            return None

    # Utility

    @staticmethod
    def generate_cache_key(prefix: str, *args: Any) -> str:
        """Generate deterministic cache key from arguments"""
        content = json.dumps([prefix, *args], sort_keys=True)
        hash_value = hashlib.sha256(content.encode()).hexdigest()[:16]
        return f"{prefix}:{hash_value}"


# Global instance (singleton pattern)
_redis_coordinator: Optional[RedisCoordinator] = None


def get_coordinator() -> RedisCoordinator:
    """Get global Redis coordinator instance"""
    global _redis_coordinator
    if _redis_coordinator is None:
        _redis_coordinator = RedisCoordinator()
    return _redis_coordinator


# Convenience functions

def cache_agent_result(agent_type: str, input_data: Any, result: Any, ttl: int = DEFAULT_CACHE_TTL) -> bool:
    """Cache agent result with automatic key generation"""
    coordinator = get_coordinator()
    cache_key = RedisCoordinator.generate_cache_key(f'agent:{agent_type}', input_data)
    return coordinator.cache_result(cache_key, result, ttl)


def get_cached_agent_result(agent_type: str, input_data: Any) -> Optional[Any]:
    """Get cached agent result with automatic key generation"""
    coordinator = get_coordinator()
    cache_key = RedisCoordinator.generate_cache_key(f'agent:{agent_type}', input_data)
    return coordinator.get_cached_result(cache_key)


# Convenience functions for work queue
def enqueue_agent_work(work_type: str, payload: Dict[str, Any], priority: int = 1) -> bool:
    """Convenience function to enqueue agent work"""
    coordinator = get_coordinator()
    return coordinator.enqueue_work({
        'type': work_type,
        'payload': payload,
        'work_id': f"{work_type}-{int(time.time() * 1000)}"
    }, priority)


def get_next_work(priority: int = 1, timeout: int = 1) -> Optional[Dict[str, Any]]:
    """Convenience function to get next work item"""
    coordinator = get_coordinator()
    return coordinator.dequeue_work(priority, timeout)


# Example usage
if __name__ == '__main__':
    import sys
    coordinator = get_coordinator()

    if not coordinator.is_available():
        print("\n⚠️  Redis not available - install with: pip install redis")
        sys.exit(1)

    print("\n✅ Redis Coordinator Test Suite\n")

    # Test 1: Agent registration
    print("Test 1: Agent Registration")
    agent_id = 'test-agent-001'
    coordinator.register_agent(agent_id, 'test-worker')
    coordinator.update_agent_status(agent_id, 'active')
    info = coordinator.get_agent_info(agent_id)
    print(f"  Agent {agent_id}: {info.status if info else 'not found'}")

    # Test 2: Work queue
    print("\nTest 2: Work Queue Operations")
    coordinator.enqueue_work({'type': 'analyze', 'file': 'test.py'}, priority=1)
    coordinator.enqueue_work({'type': 'test', 'suite': 'unit'}, priority=0)  # Urgent
    print(f"  Queue depth (priority 1): {coordinator.get_work_queue_depth(1)}")
    print(f"  Queue depth (priority 0): {coordinator.get_work_queue_depth(0)}")

    work = coordinator.dequeue_work(priority=1, timeout=1)
    if work:
        print(f"  Dequeued: {work['type']} (priority: {work['priority']})")
        coordinator.complete_work(work.get('work_id', 'unknown'), {'status': 'success'})

    # Test 3: Event broadcasting
    print("\nTest 3: Event Broadcasting")
    coordinator.broadcast_session_event('session_started', {'session_id': 'test-001'})
    coordinator.broadcast_health_warning('🟡', {'message_count': 35})
    coordinator.broadcast_decision({'decision': 'Use Redis for coordination'})
    print("  Events broadcast successfully")

    # Test 4: Caching
    print("\nTest 4: Result Caching")
    coordinator.cache_result('test-key', {'foo': 'bar'}, ttl=60)
    cached = coordinator.get_cached_result('test-key')
    print(f"  Cached result: {cached}")

    # Cleanup
    coordinator.cleanup_agent(agent_id)
    print("\n✅ All tests complete")
