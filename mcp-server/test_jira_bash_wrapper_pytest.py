import os
import pytest
from jira_bash_wrapper import JiraBashWrapper


class DummyProc:
    def __init__(self, returncode=0, stdout='', stderr=''):
        self.returncode = returncode
        self.stdout = stdout
        self.stderr = stderr


def fake_executor(cmd, cwd=None, capture_output=True, text=True, input=None, timeout=None):
    # Simulate simple script behaviors for tests
    script = os.path.basename(cmd[0]) if isinstance(cmd, list) and len(cmd) > 0 else str(cmd)
    if 'get-description-template.sh' in script:
        return DummyProc(returncode=0, stdout='/tmp/generate-description-story.md\n')
    if '--help' in cmd:
        return DummyProc(returncode=0, stdout='Usage:')
    return DummyProc(returncode=0, stdout='')


def test_suggest_template():
    wrapper = JiraBashWrapper()
    assert wrapper._suggest_template_smart('Upgrade to Spring Boot 3') == 'tech-debt'
    assert wrapper._suggest_template_smart('Investigate database issue') == 'spike'
    assert wrapper._suggest_template_smart('Fix bug when saving settings') == 'bug'
    assert wrapper._suggest_template_smart('Add new payment feature') == 'story'


def test_get_prompt_template_auto(monkeypatch):
    wrapper = JiraBashWrapper()
    # Inject fake executor by monkeypatching _run_script
    monkeypatch.setattr(wrapper, '_run_script', lambda script, args=None, input_data=None: {'success': True, 'output': '/tmp/generate-description-story.md'})
    template = wrapper._get_prompt_template('RVV-123', None)
    assert template.endswith('generate-description-story.md')


def test_run_script_timeout(monkeypatch):
    wrapper = JiraBashWrapper()
    # Simulate missing script
    res = wrapper._run_script('non-existent-script.sh')
    assert res['success'] is False
    assert 'Script not found' in res.get('error', '')
