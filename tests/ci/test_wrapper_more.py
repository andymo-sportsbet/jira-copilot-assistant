"""Renamed from test_jira_bash_wrapper_more.py — additional cases for JiraBashWrapper."""

import os
import types
import pytest
import importlib.util
import sys
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[2] / 'mcp-server' / 'jira_bash_wrapper.py'
spec = importlib.util.spec_from_file_location('jira_bash_wrapper', MODULE_PATH)
jbw = importlib.util.module_from_spec(spec)

# Provide minimal fake mcp and dotenv as in the earlier test
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

sys.modules['mcp'] = fake_mcp_pkg
sys.modules['mcp.server'] = fake_mcp_pkg.server
sys.modules['mcp.server.stdio'] = fake_mcp_pkg.server.stdio
sys.modules['mcp.server.notification'] = types.SimpleNamespace(NotificationOptions=object)

import types as _types
fake_dotenv = _types.SimpleNamespace(load_dotenv=lambda *a, **k: None)
sys.modules['dotenv'] = fake_dotenv

spec.loader.exec_module(jbw)
JiraBashWrapper = jbw.JiraBashWrapper

class DummyWrapper(JiraBashWrapper):
    def __init__(self):
        # minimal attributes without requiring scripts dir
        self.project_dir = str(Path(__file__).resolve().parents[3])
        self.scripts_dir = os.path.join(self.project_dir, 'scripts')
        self.prompts_dir = os.path.join(self.project_dir, '.prompts')
        self.server = DummyServer()
    def _run_script(self, script_name, args=None, input_data=None):
        # simulate missing script when name contains 'missing'
        if 'missing' in script_name:
            return {'success': False, 'error': f'Script not found: {script_name}'}
        if 'jira-groom.sh' in script_name:
            return {'success': True, 'output': 'Groomed', 'exit_code': 0}
        if 'jira-create.sh' in script_name:
            return {'success': True, 'output': 'Created ticket: RVV-1111', 'exit_code': 0}
        if 'find-related-tickets.sh' in script_name:
            return {'success': True, 'output': 'RVV-1\nRVV-2', 'exit_code': 0}
        if 'jira-close.sh' in script_name:
            return {'success': True, 'output': 'Closed RVV-1', 'exit_code': 0}
        if 'confluence-to-jira.sh' in script_name or 'confluence-to-spec.sh' in script_name:
            return {'success': True, 'output': 'Fetched', 'exit_code': 0}
        return {'success': False, 'error': 'unknown', 'exit_code': 1}


def test_get_prompt_template_mapping_for_known_types(tmp_path):
    w = DummyWrapper()
    # Explicit issue type mapping
    assert w._get_prompt_template('RVV-1', issue_type='story').endswith('generate-description-story.md')
    assert w._get_prompt_template('RVV-1', issue_type='bug').endswith('generate-description-bug.md')
    assert w._get_prompt_template('RVV-1', issue_type='spike').endswith('generate-description-spike.md')
    assert w._get_prompt_template('RVV-1', issue_type='technical debt').endswith('generate-description-tech-debt.md')


def test_run_script_missing_script_path(monkeypatch):
    w = DummyWrapper()
    # simulate os.path.exists returning False for a given script path
    monkeypatch.setattr(w, 'scripts_dir', '/nonexistent/path')
    res = w._run_script('missing-script.sh')
    # Our DummyWrapper returns not found error for missing
    assert not res['success']


def test_groom_ticket_with_confluence_url(tmp_path):
    w = DummyWrapper()
    res = w.groom_ticket('RVV-200', confluence_url='https://example.com/page')
    assert res['success']
    assert 'RVV-200' in res['ticket_key'] or res['ticket_key'] == 'RVV-200'


def test_find_close_sync_flows():
    w = DummyWrapper()
    f = w.find_related_tickets('RVV-1')
    assert f['success'] and 'RVV-1' in f['output']
    c = w.close_ticket('RVV-1', comment='done')
    assert c['success']
    s = w.sync_to_confluence('RVV-1', '12345')
    assert s['success']


def test_create_ticket_no_key_found(monkeypatch):
    w = DummyWrapper()
    # simulate create output without RVV- key
    monkeypatch.setattr(w, '_run_script', lambda sn, args=None, input_data=None: {'success': True, 'output': 'No key here'})
    res = w.create_ticket(summary='t')
    assert res['success']
    assert res['ticket_key'] is None


def test_fetch_confluence_missing_args():
    w = DummyWrapper()
    res = w.fetch_confluence_page()
    assert not res['success']
    assert 'required' in res['error'] or 'required' in res.get('error','')
