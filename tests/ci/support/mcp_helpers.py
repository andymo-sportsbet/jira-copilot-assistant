from pathlib import Path
import os
import sys
import importlib.util
import types


def wrapper_path():
    repo_root = Path(__file__).resolve().parents[3]
    return str(repo_root / 'mcp-server' / 'jira_bash_wrapper.py')


def python_exec():
    return os.environ.get('MCP_SERVER_PYTHON', sys.executable)


def integration_enabled():
    return os.environ.get('RUN_MCP_INTEGRATION', '') == '1'


def load_jira_module():
    """Load jira_bash_wrapper.py with minimal fake mcp and dotenv packages injected.

    Returns the loaded module object.
    """
    spec = importlib.util.spec_from_file_location('jira_bash_wrapper', wrapper_path())
    module = importlib.util.module_from_spec(spec)

    # minimal fake mcp
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
    sys.modules['mcp.types'] = fake_mcp_pkg.types

    # minimal dotenv
    fake_dotenv = types.SimpleNamespace(load_dotenv=lambda *a, **k: None)
    sys.modules['dotenv'] = fake_dotenv

    spec.loader.exec_module(module)
    return module
