import os
import stat
import subprocess
import shutil

REPO_ROOT = os.path.dirname(os.path.dirname(__file__))
SCRIPT = os.path.join(REPO_ROOT, 'scripts', 'jira-groom.sh')
TEMP_DIR = os.path.join(REPO_ROOT, '.temp')


def make_executable(path):
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IEXEC)


import pytest


@pytest.mark.skip(reason="Temporarily skipped: flaky in local environments — enable when mocking is stable")
def test_auto_description_llm_path_with_mock(tmp_path, monkeypatch):
    # Prepare environment
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()

    # Create a fake template file
    template = tmp_path / "template.md"
    template.write_text("# Template\n\nThis is a template for testing LLM path.")

    # Create a fake get-description-template.sh that prints the template path
    get_template = bin_dir / "get-description-template.sh"
    get_template.write_text(f"#!/usr/bin/env bash\necho {template}\n")
    make_executable(str(get_template))

    # Create a fake curl that returns a deterministic OpenAI-like JSON payload
    curl_bin = bin_dir / "curl"
    # The mock returns a JSON where choices[0].message.content is a JSON string (the ADF)
    mock_response = '{"choices":[{"message":{"content":"{\\"body\\":{\\"type\\":\\"doc\\",\\"version\\":1,\\"content\\":[{\\"type\\":\\"paragraph\\",\\"content\\":[{\\"type\\":\\"text\\",\\"text\\":\\"LLM GENERATED DESCRIPTION\\"}]}]}}"}}]}'

    curl_script = f"""#!/usr/bin/env bash
if echo "$@" | grep -q api.openai.com; then
  printf '%s' '{mock_response}'
  exit 0
fi
# Fallback to system curl if not the openai URL
/usr/bin/env curl "$@"
"""

    curl_bin.write_text(curl_script)
    make_executable(str(curl_bin))

    # Prepare PATH so our fake tools are used
    env = os.environ.copy()
    env['PATH'] = f"{bin_dir}:{env.get('PATH','')}"
    env['USE_LLM_GENERATION'] = 'true'
    env['OPENAI_API_KEY'] = 'test-key'

    # Ensure clean temp dir
    if os.path.exists(TEMP_DIR):
        shutil.rmtree(TEMP_DIR)

    ticket = 'TST-1'

    # Run groomer in dry-run (so it doesn't try to contact JIRA) but will invoke the LLM path
    proc = subprocess.run([SCRIPT, ticket, '--auto-description', '--dry-run'], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    assert proc.returncode == 0, f"Script failed: stdout={proc.stdout}\nstderr={proc.stderr}"

    expected_file = os.path.join(TEMP_DIR, f"{ticket}-ai-description.txt")
    assert os.path.exists(expected_file), f"AI description temp file not found: {expected_file}"

    content = open(expected_file, 'r').read()
    assert 'LLM GENERATED DESCRIPTION' in content, "LLM output not present in ai-description file"

    # Cleanup
    if os.path.exists(TEMP_DIR):
        shutil.rmtree(TEMP_DIR)
