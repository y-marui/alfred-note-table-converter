"""ApiClient - replace this with your actual external API client.

Clients are responsible only for HTTP/IO communication.
Business logic belongs in services, not here.
"""

from __future__ import annotations

import json
import urllib.error
import urllib.parse
import urllib.request
from typing import Any

from alfred.logger import get_logger

log = get_logger(__name__)

# TODO: Replace with your API's base URL
_BASE_URL = "https://api.example.com/v1"


class ApiClientError(Exception):
    """Raised when the API returns an unexpected response."""


class ApiClient:
    """Minimal HTTP client using stdlib urllib (no third-party deps).

    For complex APIs, replace urllib with ``requests`` or ``httpx``
    and add them to requirements.txt.
    """

    def __init__(self, base_url: str = _BASE_URL, timeout: float = 5.0) -> None:
        self._base_url = base_url.rstrip("/")
        self._timeout = timeout

    def search(self, query: str) -> list[dict[str, Any]]:
        """Search the API and return a list of result dicts.

        Returns:
            List of dicts with keys: id, title, subtitle, url.

        Raises:
            ApiClientError: On HTTP or network errors.
        """
        # TODO: Replace with your actual API endpoint and response parsing
        log.debug("api search: query=%r", query)

        # --- STUB: remove this block and implement the real API call ---
        return [
            {
                "id": f"stub-{i}",
                "title": f"Result {i}: {query}",
                "subtitle": "Replace ApiClient with a real implementation",
                "url": f"https://example.com/result/{i}",
            }
            for i in range(1, 4)
        ]
        # --- end stub ---

        # Example real implementation:
        # params = urllib.parse.urlencode({"q": query, "limit": 10})
        # url = f"{self._base_url}/search?{params}"
        # return self._get(url)

    def _get(self, url: str) -> Any:
        log.debug("GET %s", url)
        try:
            req = urllib.request.Request(url, headers={"Accept": "application/json"})
            with urllib.request.urlopen(req, timeout=self._timeout) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            raise ApiClientError(f"HTTP {exc.code}: {url}") from exc
        except urllib.error.URLError as exc:
            raise ApiClientError(f"Network error: {exc.reason}") from exc
