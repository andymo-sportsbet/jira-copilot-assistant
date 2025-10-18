from tests.ci.support.mcp_helpers import load_jira_module
mod = load_jira_module()
JiraBashWrapper = mod.JiraBashWrapper


def test_wrapper_init_minimal():
    w = JiraBashWrapper()
    assert hasattr(w, 'scripts_dir') and hasattr(w, 'project_dir')
