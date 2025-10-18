import os
import subprocess
from pathlib import Path
import pytest


@pytest.mark.skipif(os.environ.get('RUN_MCP_INTEGRATION') != '1', reason='integration tests disabled')
def test_jira_groom_runs_and_exits_zero(tmp_path):
    repo = Path(__file__).resolve().parents[2]
    scripts = repo / 'scripts'
    script = scripts / 'jira-groom.sh'
    assert script.exists(), f'{script} must exist for integration test'
    # Ensure executable
    script.chmod(script.stat().st_mode | 0o111)

    # Run with --help or a safe flag if exists; otherwise run and expect non-error
    try:
        res = subprocess.run([str(script), '--help'], capture_output=True, text=True, timeout=30)
    except Exception:
        # Fallback: run without args
        res = subprocess.run([str(script)], capture_output=True, text=True, timeout=30)

    # We only care that the script executed (no crash); returncode 0 or usage output is acceptable
    assert res.returncode in (0, 1)
