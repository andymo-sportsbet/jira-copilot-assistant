import asyncio
import importlib.util
import sys
import types
from pathlib import Path
import json
import os

MODULE_PATH = Path(__file__).resolve().parents[2] / 'mcp-server' / 'jira_bash_wrapper.py'
spec = importlib.util.spec_from_file_location('jira_bash_wrapper', MODULE_PATH)
jbw = importlib.util.module_from_spec(spec)

# Build a test-friendly DummyServer that records handlers
class RecordingServer:
    def __init__(self, name=None):
        self.name = name
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
    def get_capabilities(self, notification_options=None, experimental_capabilities=None):
        return {}

# Minimal fake types used by handlers
fake_types = types.SimpleNamespace()
fake_types.Tool = lambda **kwargs: kwargs
fake_types.Resource = lambda **kwargs: kwargs
fake_types.TextContent = lambda **kwargs: types.SimpleNamespace(**kwargs)

# Inject fake mcp and dotenv into sys.modules before loading module
fake_mcp_pkg = types.SimpleNamespace()
fake_mcp_pkg.server = types.SimpleNamespace(Server=RecordingServer, NotificationOptions=object, InitializationOptions=object)
fake_mcp_pkg.types = fake_types
fake_mcp_pkg.server.stdio = types.SimpleNamespace(stdio_server=lambda: None)

sys.modules['mcp'] = fake_mcp_pkg
sys.modules['mcp.server'] = fake_mcp_pkg.server
sys.modules['mcp.server.stdio'] = fake_mcp_pkg.server.stdio
sys.modules['mcp.types'] = fake_mcp_pkg.types

import types as _types
fake_dotenv = _types.SimpleNamespace(load_dotenv=lambda *a, **k: None)
sys.modules['dotenv'] = fake_dotenv

# Load module
spec.loader.exec_module(jbw)
JiraBashWrapper = jbw.JiraBashWrapper

# Test wrapper subclass that uses RecordingServer and deterministic _run_script
class TestWrapper(JiraBashWrapper):
    def __init__(self, prompts_dir, scripts_dir):
        # set minimal attributes and override server
        self.project_dir = os.path.dirname(os.path.dirname(__file__))
        self.scripts_dir = scripts_dir
        self.prompts_dir = prompts_dir
        self.server = RecordingServer('test-server')
        # call setup to register handlers onto our RecordingServer
        self._setup_handlers()
    def _run_script(self, script_name, args=None, input_data=None):
        # Return canned responses depending on script
        if 'get-description-template.sh' in script_name:
            return {'success': True, 'output': 'prompt://generate-description-story.md'}
        if 'jira-groom.sh' in script_name:
            return {'success': True, 'output': 'Groom output'}
        if 'jira-create.sh' in script_name:
            return {'success': True, 'output': 'Created ticket: RVV-4242'}
        if 'find-related-tickets.sh' in script_name:
            return {'success': True, 'output': 'RVV-1\nRVV-2'}
        if 'jira-close.sh' in script_name:
            return {'success': True, 'output': 'Closed RVV-1'}
        if 'confluence-to-spec.sh' in script_name:
            return {'success': True, 'output': 'Fetched'}
        if 'confluence-to-jira.sh' in script_name:
            return {'success': True, 'output': 'Synced'}
        return {'success': False, 'error': 'not found'}

async def _call_async(func, *args, **kwargs):
    if asyncio.iscoroutinefunction(func):
        return await func(*args, **kwargs)
    else:
        return func(*args, **kwargs)


def test_handlers_list_and_resources(tmp_path):
    prompts = tmp_path / '.prompts'
    prompts.mkdir()
    # create a prompt file matching generate-description-story.md
    pfile = prompts / 'generate-description-story.md'
    pfile.write_text('# story template')

    scripts = tmp_path / 'scripts'
    scripts.mkdir()

    w = TestWrapper(str(prompts), str(scripts))

    # Ensure handlers were recorded
    assert 'list_tools' in w.server._handlers
    assert 'list_resources' in w.server._handlers
    assert 'read_resource' in w.server._handlers
    assert 'call_tool' in w.server._handlers

    # Call list_tools handler
    result = asyncio.run(_call_async(w.server._handlers['list_tools']))
    # returns list of Tool dicts
    assert any(t['name'] == 'groom_ticket' for t in result)

    # Call list_resources handler and confirm prompt file is listed
    resources = asyncio.run(_call_async(w.server._handlers['list_resources']))
    assert any(r['uri'].startswith('prompt://') for r in resources)

    # Read resource via read_resource handler
    content = asyncio.run(_call_async(w.server._handlers['read_resource'], 'prompt://generate-description-story.md'))
    assert '# story template' in content

    # Call create_ticket via call_tool
    tc = asyncio.run(_call_async(w.server._handlers['call_tool'], 'create_ticket', {'summary': 'S'}))
    # handler returns list of TextContent; extract JSON
    txt = tc[0].text
    parsed = json.loads(txt)
    assert parsed['success']
    assert 'ticket_key' in parsed

    # Call groom_ticket via call_tool
    groom = asyncio.run(_call_async(w.server._handlers['call_tool'], 'groom_ticket', {'ticket_key': 'RVV-1'}))
    groom_parsed = json.loads(groom[0].text)
    assert groom_parsed['success']
    assert 'ticket_key' in groom_parsed

    # Call find_related_tickets
    related = asyncio.run(_call_async(w.server._handlers['call_tool'], 'find_related_tickets', {'ticket_key': 'RVV-1'}))
    related_parsed = json.loads(related[0].text)
    assert related_parsed['success']
    assert 'RVV-1' in related_parsed['output']

    # Call close_ticket
    closed = asyncio.run(_call_async(w.server._handlers['call_tool'], 'close_ticket', {'ticket_key': 'RVV-1', 'comment': 'done'}))
    closed_parsed = json.loads(closed[0].text)
    assert closed_parsed['success']

    # Call sync_to_confluence
    sync = asyncio.run(_call_async(w.server._handlers['call_tool'], 'sync_to_confluence', {'ticket_key': 'RVV-1', 'page_id': '123'}))
    sync_parsed = json.loads(sync[0].text)
    assert sync_parsed['success']
