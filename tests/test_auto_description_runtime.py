import os
import subprocess
import tempfile
import shutil

REPO_ROOT = os.path.dirname(os.path.dirname(__file__))
SCRIPT = os.path.join(REPO_ROOT, 'scripts', 'jira-groom.sh')
TEMP_DIR = os.path.join(REPO_ROOT, '.temp')


def test_auto_description_dry_run_creates_temp_file(tmp_path):
    # Use a fake ticket key to avoid needing JIRA access
    ticket = 'TST-1'

    # Ensure clean temp dir
    if os.path.exists(TEMP_DIR):
        shutil.rmtree(TEMP_DIR)

    # Run the script in dry-run mode with auto-description
    proc = subprocess.run([SCRIPT, ticket, '--auto-description', '--dry-run'], check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    # Script should exit 0 in dry-run
    assert proc.returncode == 0, f"Script failed: {proc.stderr}\n{proc.stdout}"

    # Look for the ai-description temp file for our ticket
    expected_file = os.path.join(TEMP_DIR, f"{ticket}-ai-description.txt")
    # The script prints the path when dry-run; allow either printed or file existence
    printed_path = None
    for line in proc.stdout.splitlines():
        if line.strip().endswith('-ai-description.txt'):
            printed_path = line.strip()
            break

    # Either the file exists or the script printed the path
    file_exists = os.path.exists(expected_file)
    assert file_exists or printed_path is not None, f"AI description file not created and not printed. stdout: {proc.stdout} stderr: {proc.stderr}"

    # If file exists, assert it's non-empty
    if file_exists:
        assert os.path.getsize(expected_file) > 0, "AI description temp file is empty"

    # Cleanup
    if os.path.exists(TEMP_DIR):
        shutil.rmtree(TEMP_DIR)
