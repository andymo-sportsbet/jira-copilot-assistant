<!--
  Planning: Tests, New-user Docs, and MCP wrapper improvements
  Created by automated assistant on 2025-10-18
-->
# Plan: Tests, User Setup Doc, and MCP Python Wrapper

Date: 2025-10-18

This spec captures the prioritized plan and concrete next steps for three concurrent initiatives:

- Add tests and a CI pipeline
- Create a new user setup document (prompt + base options)
- Enhance the Python MCP wrapper for local development and testing

## Summary

We will split work into three smaller, reviewable changes so they can be landed independently:

1. CI & tests (high priority) — add unit + smoke tests and a GitHub Actions workflow that runs pytest and the existing shell test runner.
2. Docs (medium priority) — add `docs/user-setup.md` describing prompt templates, environment variables, secrets, and a quickstart for local dev.
3. MCP wrapper (medium-high) — make `mcp-server/jira_bash_wrapper.py` easier to test and extend: injectable executor, smaller helpers, and pytest tests.

Each item includes acceptance criteria, files to add, and branches to use.

---

## 1) Add tests and CI pipeline

Goal: ensure core behaviours are covered and CI runs on pull requests.

Acceptance criteria:
- `pytest` runs for Python tests under `mcp-server/` and exits 0 on success.
- Shell-based converter tests (`tests/test-converter.sh`) run in CI and validate `markdown_to_jira_adf` converter.
- A GitHub Actions workflow named `.github/workflows/ci-tests.yml` runs on push/PR and uses a small matrix (python versions: 3.9-3.11).
- Coverage report is generated (optional upload step) and job exits non-zero if tests fail.

Files to add/modify:
- `.github/workflows/ci-tests.yml` — CI job(s)
- `mcp-server/test_jira_bash_wrapper_pytest.py` — pytest-based unit tests (mocks `subprocess.run`)
- small test utilities under `tests/ci/` as needed

Test strategy and notes:
- Keep real integration tests (that call external APIs or require secrets) as manual jobs (`workflow_dispatch`) or gated behind repository secrets.
- CI will run mocked unit tests + shell smoke tests that do not require network or secrets.
- If you want full integration in CI, a PAT must be stored in repo secrets — prefer to keep that out of main CI.

Branch: `ci/add-tests-workflow`

---

## 2) New user setup doc (prompt + base option)

Goal: provide a clear quickstart for new users so they can run locally and understand prompt templates.

Acceptance criteria:
- `docs/user-setup.md` created and added to the repo.
- Includes: required environment variables and secrets, how to invite the bot user, recommended PAT scopes, prompt template overview (`.prompts/`), and local dev quickstart commands.

Suggested sections:
- Overview
- Prerequisites (python, git, gh CLI)
- Environment & secrets (BOT_SELF_APPROVE_TOKEN, SELF_APPROVE_TOKEN, JIRA_* vars, CONFLUENCE_BASE_URL)
- Prompt templates (describe `.prompts/generate-*` files and purpose)
- Quickstart (create venv, pip install -r mcp-server/requirements.txt, run tests, start MCP server)
- Troubleshooting (neutral exit 78, common secrets issues, how to inspect workflow logs)

Files to add:
- `docs/user-setup.md` (primary)
- small examples under `docs/examples/` (optional)

Branch: `docs/new-user-setup`

---

## 3) Enhance Python MCP wrapper (local)

Goal: make `mcp-server/jira_bash_wrapper.py` easier to test and extend, and add unit tests.

Acceptance criteria:
- Add small refactors: injectable command executor for `_run_script` so unit tests can mock subprocess calls.
- Break out 1–2 helper functions (e.g., `_suggest_template_smart` is already present — make it easily testable) and add pytest tests.
- Add `mcp-server/test_jira_bash_wrapper_pytest.py` with mocked subprocess.run to assert expected arguments and outputs.

Implementation notes:
- Prefer small, low-risk refactors inside the same file to reduce churn.
- Keep existing `test_bash_wrapper.py` as an optional integration smoke test (can be run manually or in a dispatch CI job).

Branch: `mcp/improve-wrapper-tests`

---

## Roadmap & sequencing

1. Create `ci/add-tests-workflow` with CI that runs only unit tests + shell smoke tests.
2. Create `mcp/improve-wrapper-tests` with the wrapper refactor and tests.
3. Create `docs/new-user-setup` with the user guide.
4. Run CI, fix any failures, then open PRs for review.

Parallelization: docs can be landed independently of code. Wrapper changes and tests should be landed together.

## Open questions (decisions needed)

1. CI integration vs mocked-only: Should CI run integration tests that call real services (requires secrets) or keep integration manual?  (Recommendation: keep integration manual; CI runs mocked tests.)
2. Python matrix: prefer 3.9–3.11? (Recommendation: use 3.9–3.11 to cover commonly used environments.)
3. Do you want the wrapper to run the real `scripts/*.sh` in CI? (If yes, we must add secrets and consider rate-limits.)

## Next actions (short-term)

1. Confirm answers to the open questions above.
2. I will create `ci/add-tests-workflow` next and add a basic pytest and shell test job. (If you confirm the integration decision, I'll include an optional manual job for integration tests.)
3. After CI job is added, open `mcp/improve-wrapper-tests` branch to add pytest tests.

---

Author: AI assistant (work in repo: jira-copilot-assistant)
