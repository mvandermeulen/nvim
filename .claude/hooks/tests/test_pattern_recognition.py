#!/usr/bin/env python3
"""
Unit tests for Pattern Recognition intelligence module

Tests cover:
1. find_similar_sessions() - multi-factor scoring (40/30/20/10)
2. estimate_task_duration() - historical matching, confidence levels
3. get_common_blockers() - classification (7 types)
4. _calculate_session_similarity() - weight verification
5. _percentile() - p50, p90 calculations
6. _default_estimate_by_scope() - fallback values
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
from unittest.mock import patch, MagicMock
from datetime import datetime, timedelta


class TestFindSimilarSessions(unittest.TestCase):
    """Test find_similar_sessions() function"""

    @patch('intelligence.pattern_recognition.SessionRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_multi_factor_scoring(self, mock_session_repo):
        """Test similarity scoring with all factors"""
        from intelligence.pattern_recognition import find_similar_sessions

        mock_instance = MagicMock()
        mock_instance.get.return_value = {
            'id': 'ref-session',
            'task_title': 'Implement Redis caching',
            'scope': 'LARGE',
            'mode': 'BUILD',
            'health_status': '🟢'
        }
        mock_instance.list.return_value = [
            {'id': 'ref-session', 'task_title': 'Implement Redis caching', 'scope': 'LARGE', 'mode': 'BUILD', 'health_status': '🟢'},
            {'id': 'similar-session', 'task_title': 'Implement Redis queue', 'scope': 'LARGE', 'mode': 'BUILD', 'health_status': '🟢'},
            {'id': 'different-session', 'task_title': 'Fix login bug', 'scope': 'SMALL', 'mode': 'DEBUG', 'health_status': '🔴'},
        ]
        mock_session_repo.return_value = mock_instance

        result = find_similar_sessions('ref-session', limit=5, min_similarity=0.1)

        self.assertIsInstance(result, list)
        if result:
            self.assertIn('similarity_score', result[0])
            self.assertGreater(result[0]['similarity_score'], 0)

    @patch('intelligence.pattern_recognition.SessionRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_min_similarity_cutoff(self, mock_session_repo):
        """Test minimum similarity threshold"""
        from intelligence.pattern_recognition import find_similar_sessions

        mock_instance = MagicMock()
        mock_instance.get.return_value = {
            'id': 'ref-session',
            'task_title': 'Very specific unique task',
            'scope': 'EPIC',
            'mode': 'BUILD',
            'health_status': '🟢'
        }
        mock_instance.list.return_value = [
            {'id': 'ref-session', 'task_title': 'Very specific unique task', 'scope': 'EPIC', 'mode': 'BUILD', 'health_status': '🟢'},
            {'id': 'low-sim', 'task_title': 'Completely different xyz', 'scope': 'MICRO', 'mode': 'DEBUG', 'health_status': '🔴'},
        ]
        mock_session_repo.return_value = mock_instance

        result = find_similar_sessions('ref-session', min_similarity=0.8)

        for session in result:
            self.assertGreaterEqual(session['similarity_score'], 0.8)

    @patch('intelligence.pattern_recognition.SessionRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_excludes_self(self, mock_session_repo):
        """Test that reference session is excluded from results"""
        from intelligence.pattern_recognition import find_similar_sessions

        mock_instance = MagicMock()
        mock_instance.get.return_value = {
            'id': 'ref-session',
            'task_title': 'Test task',
            'scope': 'MEDIUM',
            'mode': 'BUILD',
            'health_status': '🟢'
        }
        mock_instance.list.return_value = [
            {'id': 'ref-session', 'task_title': 'Test task', 'scope': 'MEDIUM', 'mode': 'BUILD', 'health_status': '🟢'},
            {'id': 'other-session', 'task_title': 'Test task similar', 'scope': 'MEDIUM', 'mode': 'BUILD', 'health_status': '🟢'},
        ]
        mock_session_repo.return_value = mock_instance

        result = find_similar_sessions('ref-session', limit=10)

        session_ids = [s['id'] for s in result]
        self.assertNotIn('ref-session', session_ids)

    @patch('intelligence.pattern_recognition.HAS_REPOS', False)
    def test_no_repos_returns_empty(self):
        """Test empty list when repositories unavailable"""
        from intelligence.pattern_recognition import find_similar_sessions

        result = find_similar_sessions('any-session')

        self.assertEqual(result, [])


class TestEstimateTaskDuration(unittest.TestCase):
    """Test estimate_task_duration() function"""

    @patch('intelligence.pattern_recognition.TaskRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_historical_data_matching(self, mock_task_repo):
        """Test duration estimation from similar historical tasks"""
        from intelligence.pattern_recognition import estimate_task_duration

        now = datetime.now()
        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {
                'title': 'Implement Redis caching layer',
                'status': 'completed',
                'created_at': (now - timedelta(hours=2)).isoformat(),
                'completed_at': now.isoformat()
            },
            {
                'title': 'Setup Redis connection',
                'status': 'completed',
                'created_at': (now - timedelta(hours=1, minutes=30)).isoformat(),
                'completed_at': now.isoformat()
            }
        ]
        mock_task_repo.return_value = mock_instance

        result = estimate_task_duration(
            title='Implement Redis queue',
            scope='MEDIUM',
            complexity='medium'
        )

        self.assertIn('estimated_minutes', result)
        self.assertIn('confidence', result)
        self.assertIn('similar_tasks_count', result)

    @patch('intelligence.pattern_recognition.HAS_REPOS', False)
    def test_default_fallback_by_scope(self):
        """Test default estimates when no historical data"""
        from intelligence.pattern_recognition import estimate_task_duration

        result = estimate_task_duration('New task', scope='LARGE')

        self.assertEqual(result['estimated_minutes'], 240)
        self.assertEqual(result['confidence'], 'low')
        self.assertEqual(result['similar_tasks_count'], 0)

    def test_default_estimate_by_scope_values(self):
        """Test all scope default values"""
        from intelligence.pattern_recognition import _default_estimate_by_scope

        self.assertEqual(_default_estimate_by_scope('MICRO'), 15)
        self.assertEqual(_default_estimate_by_scope('SMALL'), 45)
        self.assertEqual(_default_estimate_by_scope('MEDIUM'), 120)
        self.assertEqual(_default_estimate_by_scope('LARGE'), 240)
        self.assertEqual(_default_estimate_by_scope('EPIC'), 480)
        self.assertEqual(_default_estimate_by_scope('UNKNOWN'), 120)

    @patch('intelligence.pattern_recognition.TaskRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_confidence_levels(self, mock_task_repo):
        """Test confidence level assignment based on sample size"""
        from intelligence.pattern_recognition import estimate_task_duration

        now = datetime.now()

        def create_mock_tasks(count):
            return [
                {
                    'title': 'Similar task keyword',
                    'status': 'completed',
                    'created_at': (now - timedelta(hours=1)).isoformat(),
                    'completed_at': now.isoformat()
                }
                for _ in range(count)
            ]

        mock_instance = MagicMock()
        mock_task_repo.return_value = mock_instance

        mock_instance.list.return_value = create_mock_tasks(2)
        result_low = estimate_task_duration('task keyword')
        self.assertEqual(result_low['confidence'], 'low')

        mock_instance.list.return_value = create_mock_tasks(5)
        result_medium = estimate_task_duration('task keyword')
        self.assertEqual(result_medium['confidence'], 'medium')

        mock_instance.list.return_value = create_mock_tasks(15)
        result_high = estimate_task_duration('task keyword')
        self.assertEqual(result_high['confidence'], 'high')


class TestGetCommonBlockers(unittest.TestCase):
    """Test get_common_blockers() function"""

    @patch('intelligence.pattern_recognition.EventRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_blocker_classification(self, mock_event_repo):
        """Test classification into 7 blocker types"""
        from intelligence.pattern_recognition import get_common_blockers

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'hook_name': 'dependency_error', 'event_data': 'package not found', 'status': 'error', 'execution_time_ms': 1000},
            {'hook_name': 'permission_check', 'event_data': 'access denied', 'status': 'error', 'execution_time_ms': 500},
            {'hook_name': 'network_call', 'event_data': 'connection refused', 'status': 'error', 'execution_time_ms': 2000},
            {'hook_name': 'database_query', 'event_data': 'timeout', 'status': 'error', 'execution_time_ms': 3000},
            {'hook_name': 'blocker_detected', 'event_data': 'syntax error in code', 'status': 'error', 'execution_time_ms': 100},
        ]
        mock_event_repo.return_value = mock_instance

        result = get_common_blockers(limit=10)

        self.assertIsInstance(result, list)
        if result:
            blocker_types = [b['blocker_type'] for b in result]
            valid_types = ['dependency_issue', 'permission_error', 'network_issue',
                          'database_error', 'timeout', 'syntax_error', 'unknown_blocker']
            for bt in blocker_types:
                self.assertIn(bt, valid_types)

    @patch('intelligence.pattern_recognition.EventRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_task_pattern_filter(self, mock_event_repo):
        """Test filtering by task pattern"""
        from intelligence.pattern_recognition import get_common_blockers

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'hook_name': 'error', 'event_data': 'redis connection failed', 'status': 'error', 'execution_time_ms': 1000},
            {'hook_name': 'error', 'event_data': 'postgres query timeout', 'status': 'error', 'execution_time_ms': 2000},
        ]
        mock_event_repo.return_value = mock_instance

        result = get_common_blockers(task_pattern='redis', limit=10)

        self.assertIsInstance(result, list)

    @patch('intelligence.pattern_recognition.EventRepository')
    @patch('intelligence.pattern_recognition.HAS_REPOS', True)
    def test_frequency_counting(self, mock_event_repo):
        """Test frequency counting for blockers"""
        from intelligence.pattern_recognition import get_common_blockers

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'hook_name': 'error', 'event_data': 'dependency issue', 'status': 'error', 'execution_time_ms': 1000},
            {'hook_name': 'blocker', 'event_data': 'dependency problem', 'status': 'error', 'execution_time_ms': 1000},
            {'hook_name': 'error', 'event_data': 'network failure', 'status': 'error', 'execution_time_ms': 2000},
        ]
        mock_event_repo.return_value = mock_instance

        result = get_common_blockers()

        for blocker in result:
            self.assertIn('frequency', blocker)
            self.assertIn('avg_resolution_minutes', blocker)
            self.assertIn('common_resolutions', blocker)

    @patch('intelligence.pattern_recognition.HAS_REPOS', False)
    def test_no_repos_returns_empty(self):
        """Test empty list when repositories unavailable"""
        from intelligence.pattern_recognition import get_common_blockers

        result = get_common_blockers()

        self.assertEqual(result, [])


class TestCalculateSessionSimilarity(unittest.TestCase):
    """Test _calculate_session_similarity() function"""

    def test_weight_verification(self):
        """Test similarity weights sum to 1.0"""
        from intelligence.pattern_recognition import _calculate_session_similarity

        session1 = {
            'task_title': 'Implement Redis caching',
            'scope': 'LARGE',
            'mode': 'BUILD',
            'health_status': '🟢'
        }

        session2_identical = {
            'task_title': 'Implement Redis caching',
            'scope': 'LARGE',
            'mode': 'BUILD',
            'health_status': '🟢'
        }

        score = _calculate_session_similarity(session1, session2_identical)

        self.assertLessEqual(score, 1.0)
        self.assertGreater(score, 0.9)

    def test_title_weight_40_percent(self):
        """Test task title contributes 40% to score"""
        from intelligence.pattern_recognition import _calculate_session_similarity

        base = {'task_title': 'Same keywords here', 'scope': 'MEDIUM', 'mode': 'BUILD', 'health_status': '🟢'}
        similar_title = {'task_title': 'Same keywords here', 'scope': 'MICRO', 'mode': 'DEBUG', 'health_status': '🔴'}
        different_title = {'task_title': 'Completely different xyz', 'scope': 'MEDIUM', 'mode': 'BUILD', 'health_status': '🟢'}

        score_similar_title = _calculate_session_similarity(base, similar_title)
        score_different_title = _calculate_session_similarity(base, different_title)

        self.assertGreater(score_similar_title, 0.3)

    def test_scope_weight_30_percent(self):
        """Test scope contributes 30% to score"""
        from intelligence.pattern_recognition import _calculate_session_similarity

        session1 = {'task_title': '', 'scope': 'LARGE', 'mode': '', 'health_status': ''}
        session2_same = {'task_title': '', 'scope': 'LARGE', 'mode': '', 'health_status': ''}
        session2_close = {'task_title': '', 'scope': 'MEDIUM', 'mode': '', 'health_status': ''}
        session2_far = {'task_title': '', 'scope': 'MICRO', 'mode': '', 'health_status': ''}

        score_same = _calculate_session_similarity(session1, session2_same)
        score_close = _calculate_session_similarity(session1, session2_close)
        score_far = _calculate_session_similarity(session1, session2_far)

        self.assertGreater(score_same, score_close)
        self.assertGreater(score_close, score_far)

    def test_mode_weight_20_percent(self):
        """Test mode contributes 20% to score"""
        from intelligence.pattern_recognition import _calculate_session_similarity

        session1 = {'task_title': '', 'scope': 'MEDIUM', 'mode': 'BUILD', 'health_status': ''}
        session2_same = {'task_title': '', 'scope': 'MEDIUM', 'mode': 'BUILD', 'health_status': ''}
        session2_diff = {'task_title': '', 'scope': 'MEDIUM', 'mode': 'DEBUG', 'health_status': ''}

        score_same = _calculate_session_similarity(session1, session2_same)
        score_diff = _calculate_session_similarity(session1, session2_diff)

        self.assertAlmostEqual(score_same - score_diff, 0.2, delta=0.05)

    def test_health_weight_10_percent(self):
        """Test health contributes 10% to score"""
        from intelligence.pattern_recognition import _calculate_session_similarity

        session1 = {'task_title': '', 'scope': 'MEDIUM', 'mode': '', 'health_status': '🟢'}
        session2_same = {'task_title': '', 'scope': 'MEDIUM', 'mode': '', 'health_status': '🟢'}
        session2_diff = {'task_title': '', 'scope': 'MEDIUM', 'mode': '', 'health_status': '🔴'}

        score_same = _calculate_session_similarity(session1, session2_same)
        score_diff = _calculate_session_similarity(session1, session2_diff)

        self.assertAlmostEqual(score_same - score_diff, 0.1, delta=0.05)


class TestPercentile(unittest.TestCase):
    """Test _percentile() function"""

    def test_p50_median(self):
        """Test 50th percentile (median)"""
        from intelligence.pattern_recognition import _percentile

        values = [10, 20, 30, 40, 50]
        result = _percentile(values, 50)

        self.assertIn(result, [20, 30])

    def test_p90_pessimistic(self):
        """Test 90th percentile"""
        from intelligence.pattern_recognition import _percentile

        values = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        result = _percentile(values, 90)

        self.assertGreaterEqual(result, 80)

    def test_empty_list(self):
        """Test empty list returns 0"""
        from intelligence.pattern_recognition import _percentile

        result = _percentile([], 50)

        self.assertEqual(result, 0)

    def test_single_value(self):
        """Test single value list"""
        from intelligence.pattern_recognition import _percentile

        result = _percentile([42], 50)

        self.assertEqual(result, 42)

    def test_unsorted_input(self):
        """Test with unsorted input list"""
        from intelligence.pattern_recognition import _percentile

        values = [50, 10, 40, 20, 30]
        result = _percentile(values, 50)

        self.assertIn(result, [20, 30])


class TestClassifyBlocker(unittest.TestCase):
    """Test _classify_blocker() function"""

    def test_dependency_classification(self):
        """Test dependency issue classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'dependency_check', 'event_data': 'module not found'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'dependency_issue')

    def test_permission_classification(self):
        """Test permission error classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'file_access', 'event_data': 'permission denied'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'permission_error')

    def test_network_classification(self):
        """Test network issue classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'api_call', 'event_data': 'network unreachable'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'network_issue')

    def test_database_classification(self):
        """Test database error classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'query', 'event_data': 'database connection failed'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'database_error')

    def test_timeout_classification(self):
        """Test timeout classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'request', 'event_data': 'operation timeout'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'timeout')

    def test_syntax_classification(self):
        """Test syntax error classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'compile', 'event_data': 'syntax error on line 42'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'syntax_error')

    def test_unknown_classification(self):
        """Test unknown blocker classification"""
        from intelligence.pattern_recognition import _classify_blocker

        event = {'hook_name': 'random', 'event_data': 'something weird happened'}
        result = _classify_blocker(event)

        self.assertEqual(result, 'unknown_blocker')


if __name__ == '__main__':
    print("\n✅ Running Pattern Recognition Test Suite\n")
    unittest.main(verbosity=2)
