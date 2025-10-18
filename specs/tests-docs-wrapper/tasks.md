# Tasks: Tests, Docs & Wrapper


- [x] Create `ci/add-tests-workflow` branch and add `.github/workflows/ci-tests.yml` (owner: andy)
- [x] Add `mcp-server/test_jira_bash_wrapper_pytest.py` with mocked subprocess tests (owner: andy)
- [x] Add test utilities under `tests/ci/` (owner: andy)
- [x] Add manual `integration-tests.yml` workflow for secrets-backed tests (owner: andy)
- [x] Refactor `mcp-server/jira_bash_wrapper.py` to support injectable executor and smaller helpers (owner: andy)
- [x] Add `docs/user-setup.md` (owner: andy)
- [x] Run full test matrix and fix issues (owner: andy)
- [x] Open PRs for CI, wrapper, and docs (owner: andy)
	- PR: https://github.com/andymo-sportsbet/jira-copilot-assistant/pull/21 (docs: onboarding & presentations cleanup)

- [x] Docs cleanup: consolidated contribution guide, annotated archived copies, updated setup/quick-start, normalized presentation filenames (owner: andy)


Completed / notable additions (reference):

- `tests/bash/` — unit Bats tests; local unit suite runs green (flaky cases skipped as needed).
- `tests/integration/e2e-run.sh` — E2E runner (create → fetch → groom → close) moved into `tests/integration/` (gated).
- `.env.test.local` — local-only env override pattern added (gitignored) for safe E2E runs.
- `scripts/mock_jira.py` — small deterministic mock JIRA server used for local integration tests.
- `scripts/cleanup-temp.sh` and Makefile targets (`test-integration`, `clean-temp`) — helpers for running and cleaning artifacts in `.temp/`.

How to run tests locally (safe, repeatable)
-----------------------------------------

Follow these steps when you want to run the integration/E2E tooling locally against a test Jira instance. These commands assume your shell is `zsh` and you're in the repository root (`/path/to/jira-copilot-assistant`).

1) Create a local-only env file (never commit this):

```bash
cd /path/to/jira-copilot-assistant
cp .env.example .env.test.local
# Edit .env.test.local with test credentials (JIRA test instance)
vim .env.test.local
```

2) Run unit tests (fast):

```bash
# runs Bats tests under tests/bash
bats tests/bash
```

3) Run the gated integration/E2E runner (explicit opt-in):

```bash
export RUN_INTEGRATION_TESTS=1
source .env.test.local
./tests/integration/e2e-run.sh
```

Notes:
- `RUN_INTEGRATION_TESTS=1` prevents accidental CI or developer runs — only run when you explicitly opt in.
- `e2e-run.sh` will auto-detect the Story Points custom field (when possible), create temporary artifacts under `.temp/` (JSON, markdown and a log). Review or clean them after the run.

4) Local mock server (for hermetic integration tests without a live Jira):

```bash
# start mock JIRA on port 8765
python3 scripts/mock_jira.py --port 8765 &
# stop it later with `kill <PID>` or use pkill -f mock_jira.py
```

5) Cleanup artifacts (non-destructive helper):

```bash
./scripts/cleanup-temp.sh
# or use the Makefile shortcut
make clean-temp
```

Tips and troubleshooting
------------------------

- If you see flaky failures in the mock-based integration tests, run them in a clean shell environment to avoid startup/profile noise:

```bash
bash --noprofile --norc -c 'bats tests/integration/test_integration_mock_jira.bats'
```

- If your instance uses a different Story Points custom field id, `e2e-run.sh` will try to detect it and set `JIRA_STORY_POINTS_FIELD`. You can also set it manually in `.env.test.local`:

```bash
JIRA_STORY_POINTS_FIELD=customfield_10016
```

Notes:
- Keep PRs small and focused — one area per PR.
- Prefer mocked unit tests for CI; run integration tests manually or in a gated workflow.
