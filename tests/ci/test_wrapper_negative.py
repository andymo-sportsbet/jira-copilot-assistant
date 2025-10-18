"""Renamed from test_jira_bash_wrapper_missing_cases.py — negative and edge-case tests."""

import os
import types
import subprocess
import json
import importlib.util
from pathlib import Path
import pytest

from tests.ci.support.mcp_helpers import load_jira_module, wrapper_path

mod = load_jira_module()
JiraBashWrapper = mod.JiraBashWrapper


def test_init_raises_when_scripts_dir_missing(monkeypatch, tmp_path):
    # Force os.path.exists to return False for scripts_dir
    monkeypatch.setattr('os.path.exists', lambda p: False)
    with pytest.raises(ValueError):
        JiraBashWrapper()


def test_get_prompt_template_handles_failure_and_empty(monkeypatch):
    w = JiraBashWrapper()
    # failure from _run_script
    monkeypatch.setattr(w, '_run_script', lambda *a, **k: {'success': False, 'error': 'boom'})
    assert w._get_prompt_template('RVV-1') is None

    # empty output
    monkeypatch.setattr(w, '_run_script', lambda *a, **k: {'success': True, 'output': ''})
    assert w._get_prompt_template('RVV-1') is None


def test_run_script_handles_general_exception(monkeypatch, tmp_path):
    # create a dummy scripts dir and dummy script file so path exists
    scripts = tmp_path / 'scripts'
    scripts.mkdir()
    (scripts / 'jira-groom.sh').write_text('#!/bin/sh\necho hi')

    w = JiraBashWrapper()
    # point wrapper to tmp scripts
    w.scripts_dir = str(scripts)

    def fake_run(cmd, cwd, capture_output, text, input, timeout):
        raise Exception('boom')

    monkeypatch.setattr('subprocess.run', fake_run)
    res = w._run_script('jira-groom.sh')
    assert res['success'] is False
    assert 'Script execution failed' in res['error']
    assert 'boom' in res['error']


class RecordingServer:
    def __init__(self, name=None):
        self._handlers = {}
    def list_tools(self):
        def decorator(f):
            self._handlers['list_tools'] = f
            return f
        return decorator
    def list_resources(self):
        def decorator(f):
            self._handlers['list_resources'] = f
            return f
        return decorator
    def read_resource(self):
        def decorator(f):
            self._handlers['read_resource'] = f
            return f
        return decorator
    def call_tool(self):
        def decorator(f):
            self._handlers['call_tool'] = f
            return f
        return decorator
    def get_capabilities(self, *a, **k):
        return {}


def make_test_wrapper(prompts_dir=None, scripts_dir=None):
    # create wrapper instance but inject RecordingServer and call _setup_handlers
    w = JiraBashWrapper.__new__(JiraBashWrapper)
    # minimal attributes
    repo_root = Path(wrapper_path()).resolve().parents[1]
    w.project_dir = str(repo_root)
    w.prompts_dir = str(prompts_dir) if prompts_dir else os.path.join(w.project_dir, '.prompts')
    w.scripts_dir = str(scripts_dir) if scripts_dir else os.path.join(w.project_dir, 'scripts')
    w.server = RecordingServer()
    # register handlers onto our RecordingServer
    w._setup_handlers()
    return w


def test_handle_list_resources_when_prompts_missing(tmp_path):
    w = make_test_wrapper(prompts_dir=str(tmp_path / 'nope'))
    # invoke coroutine sync
    handler = w.server._handlers['list_resources']
    import asyncio
    resources = asyncio.run(handler())
    assert isinstance(resources, list)
    assert resources == []


def test_handle_read_resource_errors(tmp_path):
    # create wrapper with prompts dir but no files
    prompts = tmp_path / 'prompts'
    prompts.mkdir()
    w = make_test_wrapper(prompts_dir=str(prompts))
    handler = w.server._handlers['read_resource']

    import asyncio
    # bad URI
    with pytest.raises(ValueError):
        asyncio.run(handler('bad://file'))

    # missing file
    with pytest.raises(ValueError):
        asyncio.run(handler('prompt://missing-file.md'))


def test_handle_call_tool_unknown_and_exception(monkeypatch):
    w = make_test_wrapper()
    handler = w.server._handlers['call_tool']
    import asyncio

    # Unknown tool
    out = asyncio.run(handler('unknown_tool', {}))
    assert isinstance(out, list)
    parsed = json.loads(out[0].text)
    assert parsed['success'] is False
    assert 'Unknown tool' in parsed['error']

    # Simulate exception inside one of the tool functions: monkeypatch create_ticket to raise
    def raiser(*a, **k):
        raise RuntimeError('internal')
    monkeypatch.setattr(JiraBashWrapper, 'create_ticket', raiser)
    out2 = asyncio.run(handler('create_ticket', {'summary': 's'}))
    parsed2 = json.loads(out2[0].text)
    assert parsed2['success'] is False
    assert 'internal' in parsed2['error']


def test_groom_ticket_confluence_fetch_failure(monkeypatch):
    w = JiraBashWrapper()
    # simulate fetch_confluence_page failure
    monkeypatch.setattr(w, 'fetch_confluence_page', lambda url, out=None: {'success': False, 'error': 'no-access'})
    res = w.groom_ticket('RVV-1', confluence_url='https://x')
    assert res['success'] is False
    assert 'no-access' in res['error']


def test_create_ticket_and_fetch_failures(monkeypatch):
    w = JiraBashWrapper()
    # create_ticket failure path: _run_script returns failure
    monkeypatch.setattr(w, '_run_script', lambda script, args=None, input_data=None: {'success': False, 'error': 'fail'})
    res = w.create_ticket(summary='S')
    assert res['success'] is False
    assert 'fail' in res['error']

    # fetch_confluence_page failure path
    monkeypatch.setattr(w, '_run_script', lambda script, args=None, input_data=None: {'success': False, 'error': 'fetch-fail'})
    res2 = w.fetch_confluence_page(page_url='https://x')
    assert res2['success'] is False
    assert 'fetch-fail' in res2['error']
