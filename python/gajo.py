"""A small client for the Gajo URL shortener API (https://gajo.io/docs).

Needs `requests` (pip install -r requirements.txt). Copy this file into your project.
"""

from __future__ import annotations

import os
import time
from typing import Any, Iterator

import requests

DEFAULT_API_URL = "https://gajo.io/api/v1"


class GajoError(Exception):
    def __init__(self, status: int, message: str, retry_after: int | None = None):
        super().__init__(message)
        self.status = status
        self.message = message
        self.retry_after = retry_after


class Gajo:
    def __init__(self, api_key: str | None = None, api_url: str | None = None, timeout: float = 10):
        """api_key defaults to GAJO_API_KEY; api_url to GAJO_API_URL, then https://gajo.io/api/v1."""
        self.api_key = api_key or os.environ.get("GAJO_API_KEY")
        if not self.api_key:
            raise ValueError("Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)")
        self.api_url = (api_url or os.environ.get("GAJO_API_URL") or DEFAULT_API_URL).rstrip("/")
        # short links live on the site root: https://gajo.io/{code}
        self.site_url = self.api_url.removesuffix("/api/v1")
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers["x-api-key"] = self.api_key

    def short_url(self, link: dict) -> str:
        """The shareable URL for a link returned by the API."""
        prefix = "/c/" if link.get("isCustomCode") else "/"
        return f"{self.site_url}{prefix}{link['shortCode']}"

    def shorten(self, url: str, **options: Any) -> dict:
        """Shorten a URL. Options: lifetimeDays, customCode (Pro), fallbackUrl (Pro, for app deep links)."""
        return self._request("POST", "/shorten", json={"url": url, **options})["data"]

    def shorten_batch(self, items: list[str | dict]) -> list[dict]:
        """Pro: shorten up to 100 URLs. Each item is a URL string or a {"url": ..., ...} dict."""
        urls = [{"url": item} if isinstance(item, str) else item for item in items]
        return self._request("POST", "/shorten/batch", json={"urls": urls})["data"]

    def list_links(self, page: int = 1, limit: int = 100) -> tuple[list[dict], int]:
        """One page of links, newest first, and the total number of links."""
        response = self._send("GET", "/urls", params={"page": page, "limit": limit})
        body = response.json()
        return body["data"], int(response.headers.get("X-Total-Count", len(body["data"])))

    def all_links(self, limit: int = 500) -> Iterator[dict]:
        """Every link on the account, fetched a page at a time."""
        page = 1
        while True:
            links, total = self.list_links(page, limit)
            yield from links
            if page * limit >= total or not links:
                return
            page += 1

    def get_link(self, code: str) -> dict:
        return self._request("GET", f"/urls/{code}")["data"]

    def stats(self, code: str) -> dict:
        """Click stats with bots excluded. Free: totals and 7 days; Basic and Pro: full breakdowns."""
        return self._request("GET", f"/urls/{code}/stats")["data"]

    def usage(self) -> dict:
        """Plan, links created this month, and how many are left."""
        return self._request("GET", "/usage")["data"]

    def update_destination(self, code: str, url: str) -> dict:
        """Pro: point an existing link somewhere else."""
        return self._request("PUT", f"/urls/{code}", json={"originalUrl": url})["data"]

    def deactivate(self, code: str) -> dict:
        return self._request("DELETE", f"/urls/{code}")

    def _request(self, method: str, path: str, **kwargs: Any) -> dict:
        return self._send(method, path, **kwargs).json()

    def _send(self, method: str, path: str, retried: bool = False, **kwargs: Any) -> requests.Response:
        """Errors become GajoError with the API's message; a 429 waits for Retry-After and tries once more."""
        response = self.session.request(method, f"{self.api_url}{path}", timeout=self.timeout, **kwargs)
        retry_after = response.headers.get("Retry-After")
        if response.status_code == 429 and not retried:
            time.sleep(int(retry_after or 1))
            return self._send(method, path, retried=True, **kwargs)
        if not response.ok:
            try:
                message = response.json().get("message") or f"HTTP {response.status_code}"
            except ValueError:
                message = f"HTTP {response.status_code}"
            raise GajoError(response.status_code, message, int(retry_after) if retry_after else None)
        return response
