#!/usr/bin/env python3
"""
Unit tests for Context Optimizer intelligence module

Tests cover:
1. prioritize_context() - priority-based loading, token budget allocation
2. get_minimal_context() - essential only (~600 tokens)
3. get_recommended_context() - essential + high (~2800 tokens)
4. get_comprehensive_context() - all priorities (~5600 tokens)
5. calculate_token_savings() - percentage calculation
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
from unittest.mock import patch, MagicMock


class TestPrioritizeContext(unittest.TestCase):
    """Test prioritize_context() function"""

    @patch('intelligence.context_optimizer.EventRepository')
    @patch('intelligence.context_optimizer.DecisionRepository')
    @patch('intelligence.context_optimizer.TaskRepository')
    @patch('intelligence.context_optimizer.SessionRepository')
    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', True)
    def test_priority_based_loading(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test context loaded based on specified priorities"""
        from intelligence.context_optimizer import prioritize_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'test-session',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'MEDIUM'
        }
        mock_session_repo.return_value = mock_session_instance

        for mock_repo in [mock_task_repo, mock_decision_repo, mock_event_repo]:
            mock_instance = MagicMock()
            mock_instance.list.return_value = []
            mock_repo.return_value = mock_instance

        result = prioritize_context(
            session_id='test-session',
            max_tokens=4000,
            priorities=['essential']
        )

        self.assertIn('session_state', result['components'])
        self.assertIn('active_tasks', result['components'])
        self.assertNotIn('decisions', result['components'])
        self.assertNotIn('events', result['components'])

    @patch('intelligence.context_optimizer.EventRepository')
    @patch('intelligence.context_optimizer.DecisionRepository')
    @patch('intelligence.context_optimizer.TaskRepository')
    @patch('intelligence.context_optimizer.SessionRepository')
    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', True)
    def test_token_budget_allocation(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test token budget respects allocation percentages"""
        from intelligence.context_optimizer import prioritize_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'test-session',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'MEDIUM'
        }
        mock_session_repo.return_value = mock_session_instance

        for mock_repo in [mock_task_repo, mock_decision_repo, mock_event_repo]:
            mock_instance = MagicMock()
            mock_instance.list.return_value = []
            mock_repo.return_value = mock_instance

        result = prioritize_context(
            session_id='test-session',
            max_tokens=4000,
            priorities=['essential', 'high']
        )

        self.assertIn('tokens_used', result)
        self.assertIn('tokens_budget', result)
        self.assertEqual(result['tokens_budget'], 4000)
        self.assertLessEqual(result['tokens_used'], 4000)

    @patch('intelligence.context_optimizer.SessionRepository')
    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', True)
    def test_missing_session_raises_error(self, mock_session_repo):
        """Test ValueError raised for missing session"""
        from intelligence.context_optimizer import prioritize_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = None
        mock_session_repo.return_value = mock_session_instance

        with self.assertRaises(ValueError):
            prioritize_context('nonexistent-session')

    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', False)
    def test_no_dependencies_raises_error(self):
        """Test RuntimeError when dependencies unavailable"""
        from intelligence.context_optimizer import prioritize_context

        with self.assertRaises(RuntimeError):
            prioritize_context('any-session')

    @patch('intelligence.context_optimizer.EventRepository')
    @patch('intelligence.context_optimizer.DecisionRepository')
    @patch('intelligence.context_optimizer.TaskRepository')
    @patch('intelligence.context_optimizer.SessionRepository')
    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', True)
    def test_default_priorities(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test default priorities are essential + high"""
        from intelligence.context_optimizer import prioritize_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'test-session',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'MEDIUM'
        }
        mock_session_repo.return_value = mock_session_instance

        for mock_repo in [mock_task_repo, mock_decision_repo, mock_event_repo]:
            mock_instance = MagicMock()
            mock_instance.list.return_value = []
            mock_repo.return_value = mock_instance

        result = prioritize_context('test-session')

        self.assertEqual(result['priorities_loaded'], ['essential', 'high'])


class TestGetMinimalContext(unittest.TestCase):
    """Test get_minimal_context() function"""

    @patch('intelligence.context_optimizer.prioritize_context')
    def test_minimal_context_essential_only(self, mock_prioritize):
        """Test minimal context loads essential only"""
        from intelligence.context_optimizer import get_minimal_context

        mock_prioritize.return_value = {
            'session_id': 'test',
            'components': {'session_state': {}, 'active_tasks': []},
            'tokens_used': 500,
            'tokens_budget': 1000,
            'token_efficiency': 0.5,
            'priorities_loaded': ['essential']
        }

        get_minimal_context('test-session')

        mock_prioritize.assert_called_once_with(
            session_id='test-session',
            max_tokens=1000,
            priorities=['essential']
        )

    @patch('intelligence.context_optimizer.EventRepository')
    @patch('intelligence.context_optimizer.DecisionRepository')
    @patch('intelligence.context_optimizer.TaskRepository')
    @patch('intelligence.context_optimizer.SessionRepository')
    @patch('intelligence.context_optimizer.HAS_DEPENDENCIES', True)
    def test_minimal_context_token_target(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test minimal context targets ~600 tokens"""
        from intelligence.context_optimizer import get_minimal_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'test-session',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'SMALL'
        }
        mock_session_repo.return_value = mock_session_instance

        for mock_repo in [mock_task_repo, mock_decision_repo, mock_event_repo]:
            mock_instance = MagicMock()
            mock_instance.list.return_value = []
            mock_repo.return_value = mock_instance

        result = get_minimal_context('test-session')

        self.assertLess(result['tokens_used'], 1000)


class TestGetRecommendedContext(unittest.TestCase):
    """Test get_recommended_context() function"""

    @patch('intelligence.context_optimizer.prioritize_context')
    def test_recommended_context_essential_high(self, mock_prioritize):
        """Test recommended context loads essential + high"""
        from intelligence.context_optimizer import get_recommended_context

        mock_prioritize.return_value = {
            'session_id': 'test',
            'components': {},
            'tokens_used': 2500,
            'tokens_budget': 4000,
            'token_efficiency': 0.375,
            'priorities_loaded': ['essential', 'high']
        }

        get_recommended_context('test-session')

        mock_prioritize.assert_called_once_with(
            session_id='test-session',
            max_tokens=4000,
            priorities=['essential', 'high']
        )


class TestGetComprehensiveContext(unittest.TestCase):
    """Test get_comprehensive_context() function"""

    @patch('intelligence.context_optimizer.prioritize_context')
    def test_comprehensive_context_all_priorities(self, mock_prioritize):
        """Test comprehensive context loads all priorities"""
        from intelligence.context_optimizer import get_comprehensive_context

        mock_prioritize.return_value = {
            'session_id': 'test',
            'components': {},
            'tokens_used': 5000,
            'tokens_budget': 6000,
            'token_efficiency': 0.167,
            'priorities_loaded': ['essential', 'high', 'medium', 'low']
        }

        get_comprehensive_context('test-session')

        mock_prioritize.assert_called_once_with(
            session_id='test-session',
            max_tokens=6000,
            priorities=['essential', 'high', 'medium', 'low']
        )


class TestCalculateTokenSavings(unittest.TestCase):
    """Test calculate_token_savings() function"""

    def test_percentage_calculation(self):
        """Test token savings percentage calculation"""
        from intelligence.context_optimizer import calculate_token_savings

        result = calculate_token_savings(
            full_context_tokens=10000,
            optimized_tokens=6000
        )

        self.assertEqual(result['tokens_saved'], 4000)
        self.assertEqual(result['percent_reduction'], 40.0)
        self.assertEqual(result['efficiency_gain'], 0.4)
        self.assertEqual(result['full_context_tokens'], 10000)
        self.assertEqual(result['optimized_tokens'], 6000)

    def test_zero_full_context(self):
        """Test handling of zero full context"""
        from intelligence.context_optimizer import calculate_token_savings

        result = calculate_token_savings(
            full_context_tokens=0,
            optimized_tokens=0
        )

        self.assertEqual(result['tokens_saved'], 0)
        self.assertEqual(result['percent_reduction'], 0)
        self.assertEqual(result['efficiency_gain'], 0)

    def test_no_savings(self):
        """Test when no savings achieved"""
        from intelligence.context_optimizer import calculate_token_savings

        result = calculate_token_savings(
            full_context_tokens=5000,
            optimized_tokens=5000
        )

        self.assertEqual(result['tokens_saved'], 0)
        self.assertEqual(result['percent_reduction'], 0.0)
        self.assertEqual(result['efficiency_gain'], 0.0)

    def test_40_percent_target(self):
        """Test meeting 40% reduction target"""
        from intelligence.context_optimizer import calculate_token_savings

        result = calculate_token_savings(
            full_context_tokens=10000,
            optimized_tokens=6000
        )

        self.assertGreaterEqual(result['percent_reduction'], 40.0)


class TestTokenAllocation(unittest.TestCase):
    """Test token allocation constants"""

    def test_allocation_sums_to_one(self):
        """Test token allocation percentages sum to 1.0"""
        from intelligence.context_optimizer import TOKEN_ALLOCATION

        total = sum(TOKEN_ALLOCATION.values())
        self.assertEqual(total, 1.0)

    def test_essential_is_highest(self):
        """Test essential has largest allocation"""
        from intelligence.context_optimizer import TOKEN_ALLOCATION

        essential = TOKEN_ALLOCATION['essential']
        self.assertEqual(essential, 0.40)


if __name__ == '__main__':
    print("\n✅ Running Context Optimizer Test Suite\n")
    unittest.main(verbosity=2)
