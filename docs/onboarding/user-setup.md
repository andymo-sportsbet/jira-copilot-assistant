# User setup & developer quickstart

This page helps new contributors get their local environment and CI secrets ready for working on this repository. It covers:

- Required environment variables and repository secrets
- Local test setup (Python virtualenv, dev dependencies, running tests)
- How the self-approve workflow behaves (owner commands)
- Quick troubleshooting notes (common CI/workflow issues)

## Local developer setup (macOS / zsh)

1. Create a virtualenv and activate it

```bash
python -m venv .venv
source .venv/bin/activate
```

2. Upgrade pip and install dev requirements

```bash
python -m pip install --upgrade pip
pip install -r mcp-server/requirements.txt || true
if [ -f dev-requirements.txt ]; then pip install -r dev-requirements.txt; fi
```

3. Run tests

```bash
# Run pytest for mcp-server
python -m pytest -q mcp-server

# Run shell smoke tests (optional)
bash tests/test-converter.sh
```

Notes:

- The repository expects a modern Python (3.10+). The CI workflow uses a quoted matrix ("3.10","3.11","3.12") to avoid YAML numeric parsing issues.
- If tests fail due to missing async plugins, install `pytest-asyncio` and `anyio`:

```bash
pip install pytest-asyncio anyio
```

## Troubleshooting common issues

- Workflow attempted to use Python `3.1` in CI: YAML can treat `3.10` as a numeric and parse it to `3.1`. We quote matrix items (e.g. `"3.10"`) to avoid this. If you see a runner error about `3.1` in logs, update workflows to use quoted strings and re-run.
- Approval/merge not happening: check repository secrets, make sure `BOT_SELF_APPROVE_TOKEN` is present and valid (PAT with `repo` scope). Also verify the workflow event context is correct (the workflow uses `pull_request_target` or validated `issue_comment`).
- Token name typo: ensure the secret is exactly `BOT_SELF_APPROVE_TOKEN` or `SELF_APPROVE_TOKEN` (the workflow supports the fallback order).

---
Last updated: 2025-10-18
