"""Tests for service layer."""

from __future__ import annotations

from unittest.mock import patch

from app.services.example_service import ExampleService

_STUB = [{"id": "1", "title": "Result", "subtitle": "Sub", "url": "https://example.com"}]


class TestExampleService:
    def test_search_returns_results(self):
        service = ExampleService()
        with patch.object(service._client, "search", return_value=_STUB):
            results = service.search("test")
        assert isinstance(results, list)
        assert len(results) > 0

    def test_search_caches_results(self):
        service = ExampleService()
        stub = [{"id": "1", "title": "T", "subtitle": "", "url": ""}]
        with patch.object(service._client, "search", return_value=stub) as mock_search:
            service.search("cached_query")
            service.search("cached_query")
            assert mock_search.call_count == 1  # second call uses cache

    def test_search_different_queries_are_cached_separately(self):
        service = ExampleService()
        with patch.object(service._client, "search", return_value=[]) as mock_search:
            service.search("query_a")
            service.search("query_b")
            assert mock_search.call_count == 2
