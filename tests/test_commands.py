"""Tests for command handlers."""

from __future__ import annotations

import json
from unittest.mock import patch

from app.commands import config_cmd, convert_cmd, help_cmd, open_cmd

_MD_TABLE = """\
| Col1 | Col2 |
|------|------|
| a    | b    |"""

_LATEX_TABLE = r"""$$
\begin{array}{|l|l|} \hline \hline
\textbf{Col1} & \textbf{Col2} \\ \hline \hline
\text{a} & \text{b} \\ \hline \hline
\end{array}
$$"""


class TestConvertCommand:
    def test_markdown_clipboard_shows_md_to_latex(self, capsys):
        with patch.object(convert_cmd, "_clipboard", return_value=_MD_TABLE):
            convert_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert len(data["items"]) == 1
        assert "LaTeX" in data["items"][0]["title"]

    def test_latex_clipboard_shows_latex_to_md(self, capsys):
        with patch.object(convert_cmd, "_clipboard", return_value=_LATEX_TABLE):
            convert_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert len(data["items"]) == 1
        assert "Markdown" in data["items"][0]["title"]

    def test_md_conversion_arg_contains_latex(self, capsys):
        with patch.object(convert_cmd, "_clipboard", return_value=_MD_TABLE):
            convert_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        arg = data["items"][0]["arg"]
        assert r"\begin{array}" in arg
        assert r"\textbf{Col1}" in arg

    def test_latex_conversion_arg_contains_markdown(self, capsys):
        with patch.object(convert_cmd, "_clipboard", return_value=_LATEX_TABLE):
            convert_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        arg = data["items"][0]["arg"]
        assert "| Col1 |" in arg
        assert "|---|" in arg

    def test_unknown_clipboard_shows_error(self, capsys):
        with patch.object(convert_cmd, "_clipboard", return_value="no table here"):
            convert_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert "Error" in data["items"][0]["title"] or "No table" in data["items"][0]["title"]

    def test_empty_clipboard_shows_error(self, capsys):
        with patch.object(convert_cmd, "_clipboard", return_value=""):
            convert_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert not data["items"][0]["valid"]

    def test_args_are_ignored(self, capsys):
        """Query string does not affect clipboard-based conversion."""
        with patch.object(convert_cmd, "_clipboard", return_value=_MD_TABLE):
            convert_cmd.handle("some random query")
        data = json.loads(capsys.readouterr().out)
        assert "LaTeX" in data["items"][0]["title"]


class TestOpenCommand:
    def test_no_args_shows_all_shortcuts(self, capsys):
        open_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert len(data["items"]) == len(open_cmd._SHORTCUTS)

    def test_filter_by_name(self, capsys):
        open_cmd.handle("repo")
        data = json.loads(capsys.readouterr().out)
        titles = [it["title"] for it in data["items"]]
        assert all("repo" in t for t in titles)

    def test_unknown_shortcut_shows_error(self, capsys):
        open_cmd.handle("nonexistent")
        data = json.loads(capsys.readouterr().out)
        assert "No shortcut" in data["items"][0]["title"]


class TestConfigCommand:
    def test_empty_config_shows_no_settings(self, capsys):
        config_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        titles = [it["title"] for it in data["items"]]
        assert any("No settings" in t for t in titles)

    def test_reset_clears_config(self, capsys):
        config_cmd._config.set("key", "value")
        config_cmd.handle("reset")
        data = json.loads(capsys.readouterr().out)
        assert "reset" in data["items"][0]["title"].lower()
        assert config_cmd._config.all() == {}

    def test_shows_existing_settings(self, capsys):
        config_cmd._config.set("api_key", "secret")
        config_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        titles = [it["title"] for it in data["items"]]
        assert any("api_key" in t for t in titles)

    def test_unknown_subcommand_shows_current_config(self, capsys):
        config_cmd.handle("unknown-subcommand")
        data = json.loads(capsys.readouterr().out)
        assert len(data["items"]) > 0


class TestHelpCommand:
    def test_shows_all_commands(self, capsys):
        help_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert len(data["items"]) == len(help_cmd._COMMANDS)

    def test_all_items_invalid(self, capsys):
        help_cmd.handle("")
        data = json.loads(capsys.readouterr().out)
        assert all(not it["valid"] for it in data["items"])
