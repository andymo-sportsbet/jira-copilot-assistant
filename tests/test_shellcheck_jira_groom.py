import shutil
import subprocess
from pathlib import Path


def test_shellcheck_jira_groom():
    """Run shellcheck on scripts/jira-groom.sh for basic linting.

    The test will be skipped if `shellcheck` isn't available in PATH to keep CI green
    for environments without shellcheck installed.
    """
    shellcheck = shutil.which('shellcheck')
    if shellcheck is None:
        import pytest

        pytest.skip("shellcheck not installed; skipping shellcheck lint test")

    script = Path('scripts/jira-groom.sh')
    assert script.exists(), "scripts/jira-groom.sh not found"

    # Run shellcheck. We capture stdout/stderr and fail the test if shellcheck returns non-zero.
    completed = subprocess.run([shellcheck, str(script)], capture_output=True, text=True)

    if completed.returncode != 0:
        print('shellcheck output:\n', completed.stdout)
        print('shellcheck errors:\n', completed.stderr)
    assert completed.returncode == 0, "shellcheck reported issues"
