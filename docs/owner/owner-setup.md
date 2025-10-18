Owner setup & admin guide

This document is for the repository owner or administrators who manage secrets, bot/service accounts, and repository settings.

Important: this file contains instructions for inviting and configuring the automation bot and setting repository secrets. Do not share these secrets publicly.

1) Purpose
--

The repository contains automation that can post code-owner approvals and (optionally) merge PRs when authorized. This automation is deliberately restricted — only the repository owner or authorized administrators should enable it.

2) Bot account and token
--

- Preferred approach: create a dedicated GitHub bot/service account and generate a Personal Access Token (PAT) with the `repo` scope (or a GitHub App with equivalent permissions). Store the PAT as a repository Actions secret.

- Recommended secret names (workflow checks these in order):
  - `BOT_SELF_APPROVE_TOKEN` (preferred)
  - `SELF_APPROVE_TOKEN` (legacy fallback)

How to create and store the PAT:
1. Create/identify the bot account (e.g. `your-bot-account`).
2. Sign in as the bot and create a PAT under Settings → Developer settings → Personal access tokens. Grant `repo` scope.
3. In this repository: Settings → Secrets and variables → Actions → New repository secret. Name it `BOT_SELF_APPROVE_TOKEN` and paste the PAT.

3) Invite the bot account as a collaborator (if using a user PAT)
--

If the automation uses a user PAT rather than a GitHub App, invite the bot account to the repository with appropriate access:

1. Repository → Settings → Manage access → Invite teams or people
2. Add the bot account (for example the account created above)
3. Grant Write or Maintain access depending on whether the bot needs to push/merge directly

If you use a GitHub App instead, install the App on the organization/repository and ensure it has the required repository permissions.

4) Branch protection & CODEOWNERS
--

To ensure only the owner can approve/merge to `main`:

1. Add a `CODEOWNERS` file listing the owner or team that must approve critical branches.
2. Configure Branch protection rules for `main`:
   - Require pull request reviews before merging
   - Require approvals from code owners
   - Disable dismissing reviews by authors if desired

5) Workflow behavior and safety
--

The repo contains a workflow (`.github/workflows/self-approve-and-merge.yml`) that:

- Runs on `pull_request_target` (so it can access repository secrets safely).
- Also listens to `issue_comment` and validates the comment author is the repository owner before acting.
- Uses the PAT stored in `BOT_SELF_APPROVE_TOKEN` (or `SELF_APPROVE_TOKEN` fallback).
- Exits with neutral code 78 and a helpful log message if the token is missing — this avoids noisy failures.

Best practices for owners
--

- Use a dedicated bot account and rotate tokens periodically.
- Prefer GitHub Apps where possible; they avoid storing PATs in secrets and are more auditable.
- Keep branch protection enabled — automation should complement, not replace, policy.

Troubleshooting
--

- Approval not posted: check that `BOT_SELF_APPROVE_TOKEN` exists and the PAT has `repo` scope.
- Merge failures: check branch protection rules and any required status checks. The workflow will attempt to merge using the PAT but will fail if checks block merging.
- Secret name typo: ensure secret name is exactly `BOT_SELF_APPROVE_TOKEN` or `SELF_APPROVE_TOKEN`.

Appendix — quick commands
--

List recent Actions runs (requires `gh`):

```bash
gh run list --limit 10
```

View logs for a run:

```bash
gh run view <run-id> --log
```

Re-run a run:

```bash
gh run rerun <run-id>
```
