#!/usr/bin/env python3
"""
Integration tests for Intelligence Layer with Coordinator

Tests cover:
1. Coordinator calls smart_resume on session-start
2. Context summary returned as reminder
3. Graceful degradation when intelligence unavailable
4. End-to-end session resume workflow
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
from unittest.mock import patch, MagicMock


class TestCoordinatorSmartResumeIntegration(unittest.TestCase):
    """Test coordinator integration with smart_resume"""

    @patch('coordinator.load_session_context')
    @patch('coordinator.state_manager')
    @patch('coordinator.HAS_SMART_RESUME', True)
    @patch('coordinator.HAS_STATE_MANAGER', True)
    def test_session_start_calls_smart_resume(self, mock_state_mgr, mock_load_context):
        """Test session-start handler calls smart_resume"""
        from coordinator import session_manager_initialize

        mock_state_mgr.load_state.return_value = {
            'session': {'id': 'test-session-123'},
            'currentSkill': None,
            'currentResearch': None
        }

        mock_load_context.return_value = {
            'summary': '# Session Resume: test-session-123',
            'token_count': 500,
            'load_time_ms': 45
        }

        event = {'session_id': 'test-session-123'}
        result = session_manager_initialize(event)

        self.assertEqual(result['status'], 'success')
        self.assertIn('smart_resume', result['data'])
        self.assertTrue(result['data']['smart_resume']['loaded'])

    @patch('coordinator.load_session_context')
    @patch('coordinator.state_manager')
    @patch('coordinator.HAS_SMART_RESUME', True)
    @patch('coordinator.HAS_STATE_MANAGER', True)
    def test_context_summary_as_reminder(self, mock_state_mgr, mock_load_context):
        """Test context summary returned in reminders"""
        from coordinator import session_manager_initialize

        mock_state_mgr.load_state.return_value = {
            'session': {'id': 'test-session'},
            'currentSkill': None,
            'currentResearch': None
        }

        mock_load_context.return_value = {
            'summary': '# Session Resume\n**Status**: 🟢 Healthy',
            'token_count': 300,
            'load_time_ms': 25
        }

        event = {}
        result = session_manager_initialize(event)

        self.assertIn('reminders', result)
        self.assertTrue(any('Session Context Resume' in r for r in result['reminders']))

    @patch('coordinator.state_manager')
    @patch('coordinator.HAS_SMART_RESUME', False)
    @patch('coordinator.HAS_STATE_MANAGER', True)
    def test_graceful_degradation_no_smart_resume(self, mock_state_mgr):
        """Test graceful degradation when smart_resume unavailable"""
        from coordinator import session_manager_initialize

        mock_state_mgr.load_state.return_value = {
            'session': {'id': 'test-session'},
            'currentSkill': None,
            'currentResearch': None
        }

        event = {}
        result = session_manager_initialize(event)

        self.assertEqual(result['status'], 'success')
        self.assertNotIn('reminders', result)

    @patch('coordinator.load_session_context')
    @patch('coordinator.state_manager')
    @patch('coordinator.HAS_SMART_RESUME', True)
    @patch('coordinator.HAS_STATE_MANAGER', True)
    def test_smart_resume_error_handling(self, mock_state_mgr, mock_load_context):
        """Test error handling when smart_resume fails"""
        from coordinator import session_manager_initialize

        mock_state_mgr.load_state.return_value = {
            'session': {'id': 'test-session'},
            'currentSkill': None,
            'currentResearch': None
        }

        mock_load_context.side_effect = Exception("Database connection failed")

        event = {}
        result = session_manager_initialize(event)

        self.assertEqual(result['status'], 'success')
        self.assertIn('smart_resume', result['data'])
        self.assertFalse(result['data']['smart_resume']['loaded'])
        self.assertIn('error', result['data']['smart_resume'])


class TestEndToEndSessionResume(unittest.TestCase):
    """Test end-to-end session resume workflow"""

    @patch('intelligence.context_optimizer.EventRepository')
    @patch('intelligence.context_optimizer.DecisionRepository')
    @patch('intelligence.context_optimizer.TaskRepository')
    @patch('intelligence.context_optimizer.SessionRepository')
    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', True)
    def test_full_resume_workflow(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test complete resume workflow from session ID to context"""
        from intelligence.context_optimizer import get_recommended_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'e2e-test-session',
            'health_status': '🟢',
            'message_count': 20,
            'mode': 'BUILD',
            'scope': 'LARGE',
            'task_title': 'Implement feature X',
            'task_reference': 'FEAT-123',
            'task_phase': 'implementation',
            'task_progress': 60,
            'branch': 'feature/x',
            'started_at': '2026-01-27T10:00:00'
        }
        mock_session_repo.return_value = mock_session_instance

        mock_task_instance = MagicMock()
        mock_task_instance.list.side_effect = [
            [{'id': 1, 'title': 'Active task', 'status': 'in_progress', 'priority': 1}],
            [{'id': 2, 'title': 'Completed task', 'status': 'completed', 'priority': 2}]
        ]
        mock_task_repo.return_value = mock_task_instance

        mock_decision_instance = MagicMock()
        mock_decision_instance.list.return_value = [
            {'id': 1, 'title': 'Architecture decision', 'decision': 'Use Redis',
             'impact': 'high', 'decided_at': '2026-01-27T11:00:00'}
        ]
        mock_decision_repo.return_value = mock_decision_instance

        mock_event_instance = MagicMock()
        mock_event_instance.list.return_value = [
            {'hook_name': 'milestone_reached', 'timestamp': '2026-01-27T12:00:00', 'status': 'success'}
        ]
        mock_event_repo.return_value = mock_event_instance

        result = get_recommended_context('e2e-test-session')

        self.assertEqual(result['session_id'], 'e2e-test-session')
        self.assertIn('session_state', result['components'])
        self.assertIn('active_tasks', result['components'])
        self.assertIn('decisions', result['components'])
        self.assertIn('events', result['components'])
        self.assertLess(result['tokens_used'], 4000)


class TestIntelligenceModuleImports(unittest.TestCase):
    """Test intelligence module imports"""

    def test_smart_resume_importable(self):
        """Test smart_resume module can be imported"""
        try:
            from intelligence import smart_resume
            self.assertTrue(hasattr(smart_resume, 'load_session_context'))
        except ImportError as e:
            self.fail(f"Failed to import smart_resume: {e}")

    def test_decision_learning_importable(self):
        """Test decision_learning module can be imported"""
        try:
            from intelligence import decision_learning
            self.assertTrue(hasattr(decision_learning, 'get_decision_chain'))
            self.assertTrue(hasattr(decision_learning, 'find_similar_decisions'))
        except ImportError as e:
            self.fail(f"Failed to import decision_learning: {e}")

    def test_pattern_recognition_importable(self):
        """Test pattern_recognition module can be imported"""
        try:
            from intelligence import pattern_recognition
            self.assertTrue(hasattr(pattern_recognition, 'find_similar_sessions'))
            self.assertTrue(hasattr(pattern_recognition, 'estimate_task_duration'))
        except ImportError as e:
            self.fail(f"Failed to import pattern_recognition: {e}")

    def test_context_optimizer_importable(self):
        """Test context_optimizer module can be imported"""
        try:
            from intelligence import context_optimizer
            self.assertTrue(hasattr(context_optimizer, 'prioritize_context'))
            self.assertTrue(hasattr(context_optimizer, 'calculate_token_savings'))
        except ImportError as e:
            self.fail(f"Failed to import context_optimizer: {e}")


class TestGracefulDegradationWithoutDatabase(unittest.TestCase):
    """Test graceful degradation without database"""

    def test_smart_resume_without_repos(self):
        """Test smart_resume handles missing repositories"""
        import importlib
        import intelligence.smart_resume as sr

        original_has_repos = sr.HAS_REPOS
        sr.HAS_REPOS = False

        try:
            with self.assertRaises(RuntimeError):
                sr.load_session_context('any-session')
        finally:
            sr.HAS_REPOS = original_has_repos

    def test_decision_learning_without_repos(self):
        """Test decision_learning handles missing repositories"""
        import intelligence.decision_learning as dl

        original_has_repo = dl.HAS_DECISION_REPO
        dl.HAS_DECISION_REPO = False

        try:
            result = dl.get_decision_chain(1)
            self.assertEqual(result, [])

            result = dl.find_similar_decisions('context')
            self.assertEqual(result, [])

            result = dl.get_high_impact_lessons()
            self.assertEqual(result, [])
        finally:
            dl.HAS_DECISION_REPO = original_has_repo

    def test_pattern_recognition_without_repos(self):
        """Test pattern_recognition handles missing repositories"""
        import intelligence.pattern_recognition as pr

        original_has_repos = pr.HAS_REPOS
        pr.HAS_REPOS = False

        try:
            result = pr.find_similar_sessions('session')
            self.assertEqual(result, [])

            result = pr.get_common_blockers()
            self.assertEqual(result, [])
        finally:
            pr.HAS_REPOS = original_has_repos


if __name__ == '__main__':
    print("\n✅ Running Intelligence Integration Test Suite\n")
    unittest.main(verbosity=2)
