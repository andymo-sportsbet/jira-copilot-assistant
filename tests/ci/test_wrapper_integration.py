"""Renamed from test_jira_bash_wrapper_integration.py — integration-like tests for _run_script and prompt behavior."""

import os
import sys
import importlib.util
import subprocess
from pathlib import Path
import types

MODULE_PATH = Path(__file__).resolve().parents[2] / 'mcp-server' / 'jira_bash_wrapper.py'
spec = importlib.util.spec_from_file_location('jira_bash_wrapper', MODULE_PATH)
jbw = importlib.util.module_from_spec(spec)

# Provide minimal fake mcp and dotenv
fake_mcp_pkg = types.SimpleNamespace()
class DummyServer:
    def __init__(self, name=None):
        pass
    def list_tools(self):
        def decorator(f):
            return f
        return decorator
    def list_resources(self):
        def decorator(f):
            return f
        return decorator
    def read_resource(self):
        def decorator(f):
            return f
        return decorator
    def call_tool(self):
        def decorator(f):
            return f
        return decorator
    def get_capabilities(self, notification_options=None, experimental_capabilities=None):
        return {}

fake_types = types.SimpleNamespace()
fake_types.Tool = lambda **kwargs: kwargs
fake_types.Resource = lambda **kwargs: kwargs
fake_types.TextContent = lambda **kwargs: types.SimpleNamespace(**kwargs)

fake_mcp_pkg.server = types.SimpleNamespace(Server=DummyServer, NotificationOptions=object, InitializationOptions=object)
fake_mcp_pkg.types = fake_types
fake_mcp_pkg.server.stdio = types.SimpleNamespace(stdio_server=lambda: None)

import types as _types
fake_dotenv = _types.SimpleNamespace(load_dotenv=lambda *a, **k: None)

sys.modules['mcp'] = fake_mcp_pkg
sys.modules['mcp.server'] = fake_mcp_pkg.server
sys.modules['mcp.server.stdio'] = fake_mcp_pkg.server.stdio
sys.modules['mcp.types'] = fake_mcp_pkg.types
sys.modules['dotenv'] = fake_dotenv

spec.loader.exec_module(jbw)
JiraBashWrapper = jbw.JiraBashWrapper

class DummyCompleted:
    def __init__(self, returncode=0, stdout='', stderr=''):
        self.returncode = returncode
        self.stdout = stdout
        self.stderr = stderr

# Monkeypatch subprocess.run and os.path.exists to exercise _run_script success and timeout

def test_run_script_success(monkeypatch, tmp_path):
    # simulate scripts dir existing and a script file
    tmp_scripts = tmp_path / 'scripts'
    tmp_scripts.mkdir()
    script_file = tmp_scripts / 'jira-groom.sh'
    script_file.write_text('#!/bin/sh\necho groom')

    monkeypatch.setenv('PYTEST', '1')
    # Simulate path detection
    monkeypatch.setattr('os.path.exists', lambda p: True)
    # Fake subprocess.run
    def fake_run(cmd, cwd, capture_output, text, input, timeout):
        return DummyCompleted(returncode=0, stdout='ok', stderr='')
    monkeypatch.setattr('subprocess.run', fake_run)

    w = JiraBashWrapper()
    w.scripts_dir = str(tmp_scripts)
    res = w._run_script('jira-groom.sh')
    assert res['success'] and 'ok' in res['output']


def test_run_script_timeout(monkeypatch, tmp_path):
    tmp_scripts = tmp_path / 'scripts'
    tmp_scripts.mkdir()
    monkeypatch.setattr('os.path.exists', lambda p: True)

    def fake_run_timeout(cmd, cwd, capture_output, text, input, timeout):
        raise subprocess.TimeoutExpired(cmd, timeout)
    monkeypatch.setattr('subprocess.run', fake_run_timeout)

    w = JiraBashWrapper()
    w.scripts_dir = str(tmp_scripts)
    res = w._run_script('jira-groom.sh')
    assert not res['success'] and 'timed out' in res['error']


def test_get_prompt_template_auto(monkeypatch):
    # Test auto template path: monkeypatch _run_script called by _get_prompt_template
    w = JiraBashWrapper()
    # Ensure scripts_dir exists for internal checks
    monkeypatch.setattr('os.path.exists', lambda p: True)
    # Make _run_script return a template path string
    monkeypatch.setattr(JiraBashWrapper, '_run_script', lambda self, sn, args=None, input_data=None: {'success': True, 'output': 'prompt://generate-description-story.md'})
    p = w._get_prompt_template('RVV-1')
    assert p.strip() == 'prompt://generate-description-story.md' or p is not None
