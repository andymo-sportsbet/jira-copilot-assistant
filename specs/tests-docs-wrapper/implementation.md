# Implementation Notes

## CI: `.github/workflows/ci-tests.yml`

Job outline:
- name: test
  runs-on: ubuntu-latest
  strategy: matrix: python-version: [3.9,3.10,3.11]
  steps:
  - Checkout
  - Setup Python
  - Install dev requirements (`pip install -r mcp-server/requirements.txt`)
  - Run `pytest mcp-server/` (unit tests)
  - Run `bash tests/test-converter.sh` (shell smoke tests)

Integration tests:
- Add a separate `integration-tests.yml` triggered by `workflow_dispatch` that runs jobs requiring repository secrets (PATs). Keep these jobs gated.

## Wrapper refactor suggestions

- Add optional parameter `executor` to `_run_script`, defaulting to a wrapper around `subprocess.run`. Tests can inject a fake executor that returns desired outputs.
- Break out template mapping into a small function so it can be unit tested.
- Add structured logging (use `logging` module).

## Tests

- Add `mcp-server/test_jira_bash_wrapper_pytest.py` covering:
  - `_suggest_template_smart` behavior using sample inputs
  - `_get_prompt_template` mapping (mock `_run_script` to return a path)
  - `groom_ticket` building correct argument list when `auto_template` and `estimate` flags are used (mock executor)

- Keep existing `mcp-server/test_bash_wrapper.py` as a manual integration smoke test.

## PRs

- PR 1: CI workflow + small pytest scaffolding — branch `ci/add-tests-workflow`
- PR 2: Wrapper refactor + pytest tests — branch `mcp/improve-wrapper-tests`
- PR 3: Docs — branch `docs/new-user-setup`

## Safety

- Do not store long-lived PATs in the repository. Use encrypted Actions secrets.
- Avoid running integration tests in PR builds unless secrets are available and the team consents.
