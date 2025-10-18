```markdown
Contributor guide (archived)

This file was moved during docs cleanup. Canonical contributor docs now live in `docs/onboarding/contribution-guide.md`.

Original content preserved for history.

---

This guide is for contributors who will open PRs and collaborate on code. It intentionally omits internal bot/service-account details — contributors do not need to know or configure the automation tokens.

1) Branch workflow
--

- Create a feature branch from `main`:

```bash
git checkout -b feature/your-change
```

- Push your branch and open a Pull Request against `main`.

2) Pull request process
--

- Create a clear PR title and description. Include testing notes and links to related issues.
- Assign reviewers and wait for their reviews. Do not approve your own PRs.
- Maintain the standard process: reviewers approve, CI checks pass, then a maintainer or owner merges.

3) Story points and estimation
--

- If your team uses story points, add the estimate via the normal workflow or JIRA integration. The repo includes scripts that can assist with AI estimation — consult your team process for when to use them.

4) Tests
--

- Run local tests before pushing: `python -m pytest -q` (project root) and any relevant shell smoke tests.
- If tests fail in CI, check the Actions run logs and fix issues or ask a reviewer for guidance.

5) Permissions
--

- Contributors cannot approve and merge to `main` by design. Branch protection and owner-only approvals are enforced. If you believe a PR should be merged urgently, ask the repository owner or a maintainer to review and merge.

6) Helpful commands
--

Open a PR from the command line (example using `gh`):

```bash
git push origin feature/your-change
gh pr create --base main --head feature/your-change --title "Short summary" --body "Detailed description"
```

Check workflow runs:

```bash
gh run list --limit 10
gh run view <run-id> --log
```

7) Contact and support
--

- For permission requests, invite the repository owner or open an issue and tag `@andymo-sportsbet` or the appropriate team.
- For CI or workflow failures, include the Actions run id and a short description of what failed.

---
Last updated: 2025-10-18
```
