# Plan: Tests, Docs, and MCP Wrapper

Date: 2025-10-18

## Objective

Provide robust testing and CI for the repo, a clear onboarding doc for new users, and a hardened local MCP wrapper for development and automated calls to the existing bash scripts.

## Phases

1. Initialize CI and test infra
   - Add GitHub Actions workflow for unit tests (pytest) and shell smoke tests
   - Provide a manual `integration-tests` workflow for jobs that require secrets
2. Wrapper refactor and unit tests
   - Add injectable executor to `_run_script` for mocking
   - Add pytest tests that validate logic without calling external systems
3. Docs and examples
   - Add `docs/user-setup.md` with environment variables, secrets, prompt guidance, and quickstart
4. Polish & merge
   - Open PRs, run CI, resolve issues, and merge to `main`

## Milestones

- M1: `ci/add-tests-workflow` branch created and CI workflow committed
- M2: `mcp/improve-wrapper-tests` branch created with wrapper changes and pytest tests
- M3: `docs/new-user-setup` branch with `docs/user-setup.md`
- M4: PR reviews and merges
