# Approval & Collaboration Guide

This file explains the repo's approval workflow and shows the exact commands to add contributors with `Write` access so they can open PRs but cannot merge into `main` without the code owner's approval.

Summary
- `main` is protected and requires a code owner review before merging. The repository `CODEOWNERS` file assigns `@andymo-sportsbet` as the owner for all files.
- Contributors should be granted `Write` permission so they can create branches and open PRs. They will not be able to merge into `main` without an approval from the code owner.

Quick README / CONTRIBUTING snippet (copy into your repo):

```
Approval workflow

- Branches: create feature branches from `main`.
- PRs: open a pull request targeting `main` and add reviewers.
- Approval: At least one approval from the CODEOWNER (`@andymo-sportsbet`) is required before merge.
- CI: Ensure all CI checks pass (if configured).

If you need a merge, request a review from `@andymo-sportsbet` and mention the purpose and testing done.
```

Commands: add/remove collaborators

Add a collaborator with Write permission (preferred for contributors):

```bash
# Invite a user with write access (run locally where you are authenticated with gh)
gh repo add-collaborator andymo-sportsbet/jira-copilot-assistant USERNAME --permission write
```

Change an existing collaborator's permission (use this to downgrade Admin/Maintain -> Write):

```bash
# Replace OWNER, REPO, USERNAME
gh api repos/:owner/:repo/collaborators/:username -X PUT -f permission=write

# Example
gh api repos/andymo-sportsbet/jira-copilot-assistant/collaborators/someuser -X PUT -f permission=write
```

Remove a collaborator:

```bash
gh api repos/:owner/:repo/collaborators/:username -X DELETE
# Example
gh api repos/andymo-sportsbet/jira-copilot-assistant/collaborators/someuser -X DELETE
```

List current collaborators and their permissions:

```bash
gh api repos/andymo-sportsbet/jira-copilot-assistant/collaborators --jq '.[] | {login,permissions}'
```

Notes and best practices
- Use `Write` permission for regular contributors. Do not give Admin/Maintain unless necessary.
- Admins with UI access can still change settings, but with "Include administrators" enabled, admins must still follow branch protection when merging.
- If you use teams, prefer adding a team (e.g., `@org/team`) to the repository with the appropriate role and then reference that team in `CODEOWNERS`.

If you'd like, provide a list of GitHub usernames and I can run the `gh` commands here to add them as `Write` collaborators.

Personal Access Token (PAT) — setup & testing
-------------------------------------------

To enable the automated self-approval workflow (`.github/workflows/self-approve-and-merge.yml`) you must create a Personal Access Token (PAT) for your account and store it as a repository secret.

1. Create a PAT
	- Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token.
	- For classic tokens: select the `repo` scope (gives full repo access). For a more secure approach, use a fine-grained token and grant only the needed repository access (Repository permissions: Pull requests: Read & Write; Contents: Read; Actions: Read).
	- Copy the token once generated — you won't be able to see it again.

2. Save the PAT as a repository secret
	- Repository → Settings → Secrets & variables → Actions → New repository secret
	- Name: `SELF_APPROVE_TOKEN`
	- Value: (paste the PAT)

3. Optional: add the secret via gh CLI (local)
```bash
# run locally where you are authenticated with gh
gh secret set SELF_APPROVE_TOKEN --body 'PASTE_YOUR_TOKEN_HERE' --repo andymo-sportsbet/jira-copilot-assistant
```

4. Test the workflow
	- Open a test PR (small change) or use the PR already created: https://github.com/andymo-sportsbet/jira-copilot-assistant/pull/1
	- Comment on the PR: `/self-approve` to only approve, or `/self-approve-and-merge` to approve and merge.
	- The workflow will:
	  - Verify the commenter is `andymo-sportsbet` (changeable in the workflow)
	  - Post an approval as your account using the PAT
	  - Optionally merge the PR

Security notes
-------------
- Prefer a fine-grained token with the minimal permissions required. If you use a classic token, restrict and rotate it regularly.
- Keep the token secret; store it only in repository secrets and never in code.
- After testing, you can revoke the PAT from your GitHub account settings if you no longer want automated approvals.

Bot account setup (recommended for automation)
---------------------------------------------

1. Create a bot/service GitHub account (for example: `andymo-bot`).
2. Add the bot account to your organization or invite it as a collaborator, then add its handle to `.github/CODEOWNERS` (we added `@andymo-bot` as a placeholder).
3. Create a fine-grained token for the bot with minimal repo permissions:
	- Repository: select `andymo-sportsbet/jira-copilot-assistant` only
	- Permissions: Pull requests (Read & Write), Contents (Read)
4. Store the token as a repository secret named `BOT_SELF_APPROVE_TOKEN`:

```bash
gh secret set BOT_SELF_APPROVE_TOKEN --body 'PASTE_TOKEN_HERE' --repo andymo-sportsbet/jira-copilot-assistant
```

5. Confirm the workflow uses `BOT_SELF_APPROVE_TOKEN` (we updated `.github/workflows/self-approve-and-merge.yml`).

6. Test: open a PR from a personal account and comment `/self-approve` (the PR author must post the comment). The workflow will run and the bot will post the approval and optionally merge.

Security reminder: the bot account is powerful; rotate its token and limit its scope to the specific repository.
