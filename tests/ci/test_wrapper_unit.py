import os
import types
import pytest

# Import the module under test via importlib to allow injecting test doubles
import importlib.util
import sys
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[2] / 'mcp-server' / 'jira_bash_wrapper.py'

spec = importlib.util.spec_from_file_location('jira_bash_wrapper', MODULE_PATH)
jbw = importlib.util.module_from_spec(spec)

# Provide minimal stand-ins for external dependencies used in the module
# mcp.server.Server and related types are referenced at import time; create a fake package
fake_mcp = types.SimpleNamespace()

class DummyServer:
    def __init__(self, name=None):
        self._handlers = {}
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

# Build a fake mcp package and place it in sys.modules before executing the module
fake_mcp_pkg = types.SimpleNamespace()
fake_mcp_pkg.server = types.SimpleNamespace(Server=DummyServer, NotificationOptions=object, InitializationOptions=object)
fake_mcp_pkg.types = fake_types
fake_mcp_pkg.server.stdio = types.SimpleNamespace(stdio_server=lambda: None)

sys.modules['mcp'] = fake_mcp_pkg
sys.modules['mcp.server'] = fake_mcp_pkg.server
sys.modules['mcp.server.stdio'] = fake_mcp_pkg.server.stdio
sys.modules['mcp.server.types'] = fake_mcp_pkg.types
sys.modules['mcp.types'] = fake_mcp_pkg.types
sys.modules['mcp.server.notification'] = types.SimpleNamespace(NotificationOptions=object)

# Provide dotenv.load_dotenv (module import uses load_dotenv)
import types as _types
fake_dotenv = _types.SimpleNamespace(load_dotenv=lambda *a, **k: None)
sys.modules['dotenv'] = fake_dotenv

# Now execute the module
spec.loader.exec_module(jbw)

# Access the JiraBashWrapper class
JiraBashWrapper = jbw.JiraBashWrapper

class DummyWrapper(JiraBashWrapper):
    def __init__(self):
        # Bypass real init that checks scripts dir; set minimal attributes
        self.project_dir = str(Path(__file__).resolve().parents[3])
        self.scripts_dir = os.path.join(self.project_dir, 'scripts')
        self.prompts_dir = os.path.join(self.project_dir, '.prompts')
        self.server = DummyServer('jira-mcp-server')
    def _run_script(self, script_name, args=None, input_data=None):
        # Return deterministic fake responses for tests
        if 'jira-groom.sh' in script_name:
            return {'success': True, 'output': 'Groomed successfully', 'exit_code': 0}
        if 'jira-create.sh' in script_name:
            return {'success': True, 'output': 'Created ticket: RVV-9999', 'exit_code': 0}
        if 'confluence-to-spec.sh' in script_name:
            return {'success': True, 'output': 'Fetched', 'exit_code': 0}
        return {'success': False, 'error': 'not found', 'exit_code': 1}


def test_suggest_template_basic():
    w = DummyWrapper()
    # exercise private method
    assert w._suggest_template_smart('Upgrade Spring Boot to 3.0') == 'tech-debt'
    assert w._suggest_template_smart('Investigate payment failure') == 'spike'
    assert w._suggest_template_smart('Fix bug when saving user') == 'bug'
    assert w._suggest_template_smart('Add support for new feature X') == 'story'


def test_groom_ticket_runs_script():
    w = DummyWrapper()
    res = w.groom_ticket('RVV-1234', estimate=True, auto_estimate=True, team_scale=True)
    assert res['success']
    assert 'message' in res and 'groomed' in res['message'].lower()


def test_create_ticket_parses_key():
    w = DummyWrapper()
    res = w.create_ticket(summary='New feature', description='desc', features='a,b')
    assert res['success']
    assert res['ticket_key'] == 'RVV-9999'


def test_fetch_confluence_page_with_output_file(tmp_path, monkeypatch):
    w = DummyWrapper()
    out = tmp_path / 'out.md'
    res = w.fetch_confluence_page(page_url='https://example.com', output_file=str(out))
    assert res['success']
    assert res['message']
import os
import types
import pytest

# Import the module under test via importlib to allow injecting test doubles
import importlib.util
import sys
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[2] / 'mcp-server' / 'jira_bash_wrapper.py'

spec = importlib.util.spec_from_file_location('jira_bash_wrapper', MODULE_PATH)
jbw = importlib.util.module_from_spec(spec)

# Provide minimal stand-ins for external dependencies used in the module
# mcp.server.Server and related types are referenced at import time; create a fake package
fake_mcp = types.SimpleNamespace()

class DummyServer:
    def __init__(self, name=None):
        self._handlers = {}
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
