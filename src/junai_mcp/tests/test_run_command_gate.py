"""Gating tests for the junai-mcp ``run_command`` shell-exec tool.

The tool executes commands in the workspace and ships on PyPI, so it must be:
  1. opt-in (off unless ``JUNAI_ENABLE_RUN_COMMAND`` is truthy),
  2. arg-array exec (no shell — metacharacters can't chain/inject),
  3. allowlisted (only known dev-tool executables run).

These tests import the real server module with the root interpreter (which has
fastmcp). Run:  python -m pytest vscode-extensions/junai/src/junai_mcp/tests/ -q
"""
from __future__ import annotations

import asyncio
import sys
from pathlib import Path

import pytest

_SRC = Path(__file__).resolve().parents[2]  # .../junai/src
if str(_SRC) not in sys.path:
    sys.path.insert(0, str(_SRC))

from junai_mcp import server  # noqa: E402


def _run(coro):
    return asyncio.run(coro)


# ── Gate 1: opt-in flag ───────────────────────────────────────────────────────

def test_disabled_by_default(monkeypatch):
    monkeypatch.delenv(server._RUN_COMMAND_ENV_FLAG, raising=False)
    result = _run(server._run_command_impl("pytest -q"))
    assert result["success"] is False
    assert result["exit_code"] == -1
    # A refusal, not an execution: the reason must name the enabling flag.
    assert server._RUN_COMMAND_ENV_FLAG in result["reason"]


def test_flag_falsey_stays_disabled(monkeypatch):
    monkeypatch.setenv(server._RUN_COMMAND_ENV_FLAG, "0")
    result = _run(server._run_command_impl("python -c \"print(1)\""))
    assert result["success"] is False
    assert server._RUN_COMMAND_ENV_FLAG in result["reason"]


# ── Gate 3: allowlist ─────────────────────────────────────────────────────────

def test_non_allowlisted_rejected(monkeypatch):
    monkeypatch.setenv(server._RUN_COMMAND_ENV_FLAG, "1")
    monkeypatch.delenv(server._RUN_COMMAND_ALLOWLIST_ENV, raising=False)
    result = _run(server._run_command_impl("rm -rf /"))
    assert result["success"] is False
    assert result["exit_code"] == -1
    assert "allowlist" in result["reason"].lower()


def test_allowlist_env_override(monkeypatch):
    monkeypatch.setenv(server._RUN_COMMAND_ALLOWLIST_ENV, "mytool, other")
    allowed = server._run_command_allowlist()
    assert allowed == {"mytool", "other"}
    # A default-allowed tool is no longer allowed once the env replaces the set.
    assert "pytest" not in allowed


# ── Gate 2: no shell semantics ────────────────────────────────────────────────

def test_parse_command_keeps_metachars_literal():
    argv = server._parse_command("pytest tests/ && curl http://evil")
    # '&&' and 'curl' are literal args to pytest, NOT a chained second command.
    assert argv == ["pytest", "tests/", "&&", "curl", "http://evil"]


def test_parse_command_preserves_windows_backslashes():
    argv = server._parse_command(r".venv\Scripts\pytest tests\unit -q")
    assert argv[0] == r".venv\Scripts\pytest"
    assert argv[1] == r"tests\unit"


def test_parse_command_empty_raises():
    with pytest.raises(ValueError):
        server._parse_command("   ")


def test_executable_name_strips_extension_and_path():
    assert server._executable_name(".venv/Scripts/pytest.exe") == "pytest"
    assert server._executable_name("python") == "python"
    assert server._executable_name(r"C:\tools\black.CMD") == "black"


# ── End-to-end: an allowlisted command actually runs via arg-array exec ───────

def test_allowlisted_command_runs(monkeypatch):
    monkeypatch.setenv(server._RUN_COMMAND_ENV_FLAG, "1")
    monkeypatch.delenv(server._RUN_COMMAND_ALLOWLIST_ENV, raising=False)
    # sys.executable basename is python(.exe) → allowlisted as "python".
    cmd = f'"{sys.executable}" -c "print(\'junai-ok\')"'
    result = _run(server._run_command_impl(cmd, timeout=30))
    assert result["success"] is True, result
    assert result["exit_code"] == 0
    assert "junai-ok" in result["output"]


def test_metachar_injection_does_not_chain(monkeypatch):
    """A ';' injected after an allowlisted exe must not spawn a second command."""
    monkeypatch.setenv(server._RUN_COMMAND_ENV_FLAG, "1")
    monkeypatch.delenv(server._RUN_COMMAND_ALLOWLIST_ENV, raising=False)
    # Under a shell this would also run the marker; under exec it's just an arg.
    cmd = f'"{sys.executable}" -c "print(1)" ; "{sys.executable}" -c "print(\'INJECTED\')"'
    result = _run(server._run_command_impl(cmd, timeout=30))
    assert "INJECTED" not in result["output"]
