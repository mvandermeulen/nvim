#!/usr/bin/env python3
"""
Unit tests for Decision Learning intelligence module

Tests cover:
1. get_decision_chain() - forward and backward traversal
2. find_similar_decisions() - Jaccard similarity matching
3. get_high_impact_lessons() - impact filtering
4. _extract_keywords() - stop word removal
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
from unittest.mock import patch, MagicMock


class TestGetDecisionChain(unittest.TestCase):
    """Test get_decision_chain() function"""

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_forward_traversal(self, mock_decision_repo):
        """Test forward chain traversal (consequences)"""
        from intelligence.decision_learning import get_decision_chain

        mock_instance = MagicMock()
        mock_instance.get.side_effect = [
            {'id': 1, 'title': 'Start Decision', 'context': 'Initial'},
            {'id': 2, 'title': 'Next Decision', 'context': 'decision:1'}
        ]
        mock_instance.list.side_effect = [
            [{'id': 2, 'title': 'Next Decision', 'context': 'decision:1', 'decided_at': '2026-01-27T10:00:00'}],
            []
        ]
        mock_decision_repo.return_value = mock_instance

        result = get_decision_chain(1, depth=3, direction='forward')

        self.assertGreaterEqual(len(result), 1)
        self.assertEqual(result[0]['id'], 1)

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_backward_traversal(self, mock_decision_repo):
        """Test backward chain traversal (dependencies)"""
        from intelligence.decision_learning import get_decision_chain

        mock_instance = MagicMock()
        mock_instance.get.side_effect = [
            {'id': 3, 'title': 'Current Decision', 'context': 'Based on decision:2'},
            {'id': 2, 'title': 'Previous Decision', 'context': 'Based on decision:1'},
            {'id': 1, 'title': 'Original Decision', 'context': 'Initial'}
        ]
        mock_decision_repo.return_value = mock_instance

        result = get_decision_chain(3, depth=3, direction='backward')

        self.assertGreaterEqual(len(result), 1)

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_depth_limit(self, mock_decision_repo):
        """Test depth limit is respected"""
        from intelligence.decision_learning import get_decision_chain

        mock_instance = MagicMock()
        mock_instance.get.return_value = {'id': 1, 'title': 'Decision', 'context': ''}
        mock_instance.list.return_value = [
            {'id': i, 'title': f'Decision {i}', 'context': f'decision:{i-1}', 'decided_at': f'2026-01-27T{i:02d}:00:00'}
            for i in range(2, 10)
        ]
        mock_decision_repo.return_value = mock_instance

        result = get_decision_chain(1, depth=2, direction='forward')

        self.assertLessEqual(len(result), 3)

    @patch('intelligence.decision_learning.HAS_DECISION_REPO', False)
    def test_no_repo_returns_empty(self):
        """Test empty list when repository unavailable"""
        from intelligence.decision_learning import get_decision_chain

        result = get_decision_chain(1, depth=3)

        self.assertEqual(result, [])

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_missing_decision_returns_empty(self, mock_decision_repo):
        """Test empty list when decision not found"""
        from intelligence.decision_learning import get_decision_chain

        mock_instance = MagicMock()
        mock_instance.get.return_value = None
        mock_decision_repo.return_value = mock_instance

        result = get_decision_chain(999, depth=3)

        self.assertEqual(result, [])


class TestFindSimilarDecisions(unittest.TestCase):
    """Test find_similar_decisions() function"""

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_jaccard_similarity(self, mock_decision_repo):
        """Test Jaccard similarity calculation"""
        from intelligence.decision_learning import find_similar_decisions

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'id': 1, 'title': 'Redis caching layer', 'context': 'choosing redis for caching system', 'impact': 'high'},
            {'id': 2, 'title': 'PostgreSQL storage', 'context': 'using postgresql database', 'impact': 'high'},
            {'id': 3, 'title': 'Memcached caching', 'context': 'choosing memcached for caching', 'impact': 'medium'},
        ]
        mock_decision_repo.return_value = mock_instance

        result = find_similar_decisions(
            context='choosing caching solution for performance',
            limit=5,
            min_similarity=0.1
        )

        self.assertIsInstance(result, list)
        if result:
            caching_found = any('cach' in d['title'].lower() for d in result)
            self.assertTrue(caching_found, "Expected caching-related decisions to match")

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_min_similarity_threshold(self, mock_decision_repo):
        """Test minimum similarity threshold filtering"""
        from intelligence.decision_learning import find_similar_decisions

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'id': 1, 'title': 'Completely different', 'context': 'unrelated topic xyz abc', 'impact': 'high'},
            {'id': 2, 'title': 'Similar topic', 'context': 'redis caching layer implementation', 'impact': 'high'},
        ]
        mock_decision_repo.return_value = mock_instance

        result = find_similar_decisions(
            context='redis caching performance',
            limit=5,
            min_similarity=0.5
        )

        for decision in result:
            self.assertIn('redis', decision['context'].lower())

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_impact_filter(self, mock_decision_repo):
        """Test filtering by impact level"""
        from intelligence.decision_learning import find_similar_decisions

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'id': 1, 'title': 'High Impact', 'context': 'test context match', 'impact': 'high'},
        ]
        mock_decision_repo.return_value = mock_instance

        result = find_similar_decisions(
            context='test context',
            impact_filter='high'
        )

        mock_instance.list.assert_called_with(filters={'impact': 'high'})

    @patch('intelligence.decision_learning.HAS_DECISION_REPO', False)
    def test_no_repo_returns_empty(self):
        """Test empty list when repository unavailable"""
        from intelligence.decision_learning import find_similar_decisions

        result = find_similar_decisions('any context')

        self.assertEqual(result, [])

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_limit_respected(self, mock_decision_repo):
        """Test limit parameter is respected"""
        from intelligence.decision_learning import find_similar_decisions

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'id': i, 'title': f'Decision {i}', 'context': 'matching context keyword', 'impact': 'high'}
            for i in range(20)
        ]
        mock_decision_repo.return_value = mock_instance

        result = find_similar_decisions('context keyword', limit=3)

        self.assertLessEqual(len(result), 3)


class TestGetHighImpactLessons(unittest.TestCase):
    """Test get_high_impact_lessons() function"""

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_impact_filtering(self, mock_decision_repo):
        """Test filtering by high/critical impact"""
        from intelligence.decision_learning import get_high_impact_lessons

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'id': 1, 'title': 'Critical Lesson', 'decision': 'A', 'impact': 'critical',
             'rationale': 'Important', 'consequences': 'Good outcome', 'decided_at': '2026-01-27T10:00:00', 'tags': 'arch,perf'},
            {'id': 2, 'title': 'High Lesson', 'decision': 'B', 'impact': 'high',
             'rationale': 'Needed', 'consequences': '', 'decided_at': '2026-01-27T11:00:00', 'tags': ''},
        ]
        mock_decision_repo.return_value = mock_instance

        result = get_high_impact_lessons(impact='high', limit=10)

        self.assertEqual(len(result), 2)
        impacts = [r['impact'] for r in result]
        self.assertTrue(all(il in ['high', 'critical'] for il in impacts))

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_lesson_format(self, mock_decision_repo):
        """Test lesson dictionary format"""
        from intelligence.decision_learning import get_high_impact_lessons

        mock_instance = MagicMock()
        mock_instance.list.return_value = [
            {'id': 1, 'title': 'Test Lesson', 'decision': 'Test Decision',
             'impact': 'high', 'rationale': 'Test rationale',
             'consequences': 'Test consequences', 'decided_at': '2026-01-27T10:00:00',
             'tags': 'tag1,tag2'}
        ]
        mock_decision_repo.return_value = mock_instance

        result = get_high_impact_lessons()

        self.assertEqual(len(result), 1)
        lesson = result[0]
        self.assertIn('id', lesson)
        self.assertIn('title', lesson)
        self.assertIn('decision', lesson)
        self.assertIn('rationale', lesson)
        self.assertIn('consequences', lesson)
        self.assertIn('impact', lesson)
        self.assertIn('decided_at', lesson)
        self.assertIn('tags', lesson)
        self.assertEqual(lesson['tags'], ['tag1', 'tag2'])

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_session_filter(self, mock_decision_repo):
        """Test filtering by session_id"""
        from intelligence.decision_learning import get_high_impact_lessons

        mock_instance = MagicMock()
        mock_instance.list.return_value = []
        mock_decision_repo.return_value = mock_instance

        get_high_impact_lessons(session_id='session-123')

        call_args = mock_instance.list.call_args
        filters = call_args[1]['filters']
        self.assertEqual(filters['session_id'], 'session-123')

    @patch('intelligence.decision_learning.HAS_DECISION_REPO', False)
    def test_no_repo_returns_empty(self):
        """Test empty list when repository unavailable"""
        from intelligence.decision_learning import get_high_impact_lessons

        result = get_high_impact_lessons()

        self.assertEqual(result, [])


class TestExtractKeywords(unittest.TestCase):
    """Test _extract_keywords() function"""

    def test_stop_word_removal(self):
        """Test common stop words are removed"""
        from intelligence.decision_learning import _extract_keywords

        text = "the quick brown fox is a very good animal"
        result = _extract_keywords(text)

        self.assertNotIn('the', result)
        self.assertNotIn('is', result)
        self.assertNotIn('a', result)
        self.assertIn('quick', result)
        self.assertIn('brown', result)
        self.assertIn('fox', result)

    def test_short_words_removed(self):
        """Test words <= 2 chars are removed"""
        from intelligence.decision_learning import _extract_keywords

        text = "we do it by me to go on"
        result = _extract_keywords(text)

        for word in result:
            self.assertGreater(len(word), 2)

    def test_lowercase_conversion(self):
        """Test text is lowercased"""
        from intelligence.decision_learning import _extract_keywords

        text = "Redis CACHING PostgreSQL"
        result = _extract_keywords(text)

        self.assertIn('redis', result)
        self.assertIn('caching', result)
        self.assertIn('postgresql', result)

    def test_punctuation_handling(self):
        """Test punctuation is handled correctly"""
        from intelligence.decision_learning import _extract_keywords

        text = "hello, world! how's it going?"
        result = _extract_keywords(text)

        self.assertIn('hello', result)
        self.assertIn('world', result)

    def test_empty_string(self):
        """Test empty string returns empty list"""
        from intelligence.decision_learning import _extract_keywords

        result = _extract_keywords("")

        self.assertEqual(result, [])


class TestGracefulDegradation(unittest.TestCase):
    """Test graceful degradation scenarios"""

    @patch('intelligence.decision_learning.DecisionRepository')
    @patch('intelligence.decision_learning.HAS_DECISION_REPO', True)
    def test_repository_exception(self, mock_decision_repo):
        """Test handling of repository exceptions"""
        from intelligence.decision_learning import get_decision_chain

        mock_instance = MagicMock()
        mock_instance.get.side_effect = Exception("Database error")
        mock_decision_repo.return_value = mock_instance

        with self.assertRaises(Exception):
            get_decision_chain(1)


if __name__ == '__main__':
    print("\n✅ Running Decision Learning Test Suite\n")
    unittest.main(verbosity=2)
