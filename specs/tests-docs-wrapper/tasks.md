# Tasks: Tests, Docs & Wrapper

Each task is small and actionable. Update status inline when complete.

- [ ] Create `ci/add-tests-workflow` branch and add `.github/workflows/ci-tests.yml` (owner: andy)
- [ ] Add `mcp-server/test_jira_bash_wrapper_pytest.py` with mocked subprocess tests (owner: andy)
- [ ] Add test utilities under `tests/ci/` (owner: andy)
- [ ] Add manual `integration-tests.yml` workflow for secrets-backed tests (owner: andy)
- [ ] Refactor `mcp-server/jira_bash_wrapper.py` to support injectable executor and smaller helpers (owner: andy)
- [ ] Add `docs/user-setup.md` (owner: andy)
- [ ] Run full test matrix and fix issues (owner: andy)
- [ ] Open PRs for CI, wrapper, and docs (owner: andy)

Notes:
- Keep PRs small and focused — one area per PR.
- Prefer mocked unit tests for CI; run integration tests manually or in a gated workflow.
