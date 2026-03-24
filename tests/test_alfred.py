"""Tests for the Alfred SDK helpers."""

from __future__ import annotations

import json
import time

import pytest

from alfred.cache import Cache
from alfred.config import Config
from alfred.response import item, output
from alfred.router import Router
from alfred.safe_run import safe_run

# ---------------------------------------------------------------------------
# response
# ---------------------------------------------------------------------------


class TestItem:
    def test_minimal(self):
        result = item("Title")
        assert result["title"] == "Title"
        assert result["subtitle"] == ""
        assert result["arg"] == ""
        assert result["valid"] is True

    def test_full(self):
        result = item(
            "Title",
            "Sub",
            arg="value",
            uid="uid1",
            valid=False,
            autocomplete="auto",
        )
        assert result["uid"] == "uid1"
        assert result["valid"] is False
        assert result["autocomplete"] == "auto"

    def test_icon_omitted_when_none(self):
        result = item("T")
        assert "icon" not in result

    def test_icon_included(self):
        result = item("T", icon="myicon.png")
        assert result["icon"] == {"path": "myicon.png"}


class TestOutput:
    def test_writes_json_to_stdout(self, capsys):
        output([item("Hello")])
        captured = capsys.readouterr()
        data = json.loads(captured.out)
        assert data["items"][0]["title"] == "Hello"

    def test_with_variables(self, capsys):
        output([item("T")], variables={"foo": "bar"})
        data = json.loads(capsys.readouterr().out)
        assert data["variables"] == {"foo": "bar"}

    def test_with_rerun(self, capsys):
        output([item("T")], rerun=0.5)
        data = json.loads(capsys.readouterr().out)
        assert data["rerun"] == 0.5


# ---------------------------------------------------------------------------
# cache
# ---------------------------------------------------------------------------


class TestCache:
    def test_miss_returns_none(self):
        cache = Cache()
        assert cache.get("missing") is None

    def test_key_with_special_chars_is_sanitized(self):
        cache = Cache()
        # Path traversal attempts and other special chars must not escape the cache dir
        for key in ["../etc/passwd", "key with spaces", "key/slash", "key\x00null"]:
            cache.set(key, "value")
            assert cache.get(key) == "value"
            cache_file = cache._path(key)
            # File must be inside the cache dir, not somewhere else
            assert cache_file.parent == cache._dir

    def test_empty_key_is_handled(self):
        cache = Cache()
        cache.set("", "value")
        assert cache.get("") == "value"

    def test_set_and_get(self):
        cache = Cache()
        cache.set("key", {"value": 42})
        assert cache.get("key") == {"value": 42}

    def test_expired_returns_none(self):
        cache = Cache(ttl=0.01)
        cache.set("key", "data")
        time.sleep(0.05)
        assert cache.get("key") is None

    def test_delete(self):
        cache = Cache()
        cache.set("key", "data")
        cache.delete("key")
        assert cache.get("key") is None

    def test_clear(self):
        cache = Cache()
        cache.set("a", 1)
        cache.set("b", 2)
        cache.clear()
        assert cache.get("a") is None
        assert cache.get("b") is None

    def test_get_or_set(self):
        cache = Cache()
        called = []

        def compute():
            called.append(1)
            return "result"

        assert cache.get_or_set("k", compute) == "result"
        assert cache.get_or_set("k", compute) == "result"
        assert len(called) == 1  # only called once


# ---------------------------------------------------------------------------
# config
# ---------------------------------------------------------------------------


class TestConfig:
    def test_get_missing_returns_default(self):
        config = Config()
        assert config.get("missing") is None
        assert config.get("missing", "default") == "default"

    def test_set_and_get(self):
        config = Config()
        config.set("key", "value")
        assert config.get("key") == "value"

    def test_delete(self):
        config = Config()
        config.set("key", "value")
        config.delete("key")
        assert config.get("key") is None

    def test_reset(self):
        config = Config()
        config.set("a", 1)
        config.set("b", 2)
        config.reset()
        assert config.all() == {}

    def test_all(self):
        config = Config()
        config.set("x", 10)
        config.set("y", 20)
        assert config.all() == {"x": 10, "y": 20}


# ---------------------------------------------------------------------------
# router
# ---------------------------------------------------------------------------


class TestRouter:
    def test_dispatch_to_registered_command(self):
        router = Router(default="search")
        calls = []

        @router.register("search")
        def handle_search(args):
            calls.append(("search", args))

        router.dispatch("search foo")
        assert calls == [("search", "foo")]

    def test_default_command_on_unknown(self):
        router = Router(default="search")
        calls = []

        @router.register("search")
        def handle_search(args):
            calls.append(args)

        router.dispatch("unknown input")
        # Falls back to search with full query
        assert calls == ["unknown input"]

    def test_empty_query_uses_default(self):
        router = Router(default="help")
        calls = []

        @router.register("help")
        def handle_help(args):
            calls.append(args)

        router.dispatch("")
        assert calls == [""]

    def test_command_with_no_args(self):
        router = Router(default="search")
        calls = []

        @router.register("config")
        def handle_config(args):
            calls.append(args)

        router.dispatch("config")
        assert calls == [""]

    def test_raises_when_no_default_handler_registered(self):
        router = Router(default="missing")  # "missing" is never registered
        with pytest.raises(ValueError, match="No handler registered"):
            router.dispatch("unknown")

    def test_command_case_insensitive(self):
        router = Router(default="search")
        calls = []

        @router.register("search")
        def handle_search(args):
            calls.append(args)

        router.dispatch("SEARCH foo")
        assert calls == ["foo"]


# ---------------------------------------------------------------------------
# safe_run
# ---------------------------------------------------------------------------


class TestSafeRun:
    def test_runs_normally(self):
        results = []
        safe_run(lambda: results.append(1))
        assert results == [1]

    def test_catches_exception_and_outputs_error(self, capsys):
        def boom():
            raise ValueError("test error")

        safe_run(boom)
        captured = capsys.readouterr()
        data = json.loads(captured.out)
        assert data["items"][0]["title"] == "Workflow Error"
        assert "test error" in data["items"][0]["subtitle"]

    def test_error_output_is_valid_json_with_non_ascii(self, capsys):
        """Non-ASCII error messages must be preserved, not escaped."""

        def boom():
            raise ValueError("エラー: 日本語")

        safe_run(boom)
        raw = capsys.readouterr().out
        # Must be decodable and contain the original string
        data = json.loads(raw)
        assert "エラー" in data["items"][0]["subtitle"]

    def test_cmd_mod_copies_full_traceback(self, capsys):
        def boom():
            raise RuntimeError("full trace")

        safe_run(boom)
        data = json.loads(capsys.readouterr().out)
        mods = data["items"][0]["mods"]
        assert "cmd" in mods
        assert "full trace" in mods["cmd"]["arg"]
