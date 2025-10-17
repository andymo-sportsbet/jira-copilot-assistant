# Spec: Automated Spec Maintenance (Confluence → specs/)

**Version**: 1.0.0
**Created**: 2025-10-18
**Status**: Proposed

---

## Summary

Add a scheduled automation that keeps markdown `specs/` up to date by syncing content from Confluence. The automation will run periodically (daily or weekly), convert pages to markdown using the existing `scripts/confluence-to-spec.sh`, and open a PR with the diffs when changes are detected. This keeps the repo authoritative while ensuring human review before changes land on `main`.

## Tiny contract

- Inputs: Confluence space ID or list of page IDs; `CONFLUENCE_BASE_URL` and `CONFLUENCE_TOKEN` (repo secrets); optional output path under `specs/`.
- Outputs: When changes exist, create branch `auto/specs-sync-YYYYMMDDHHMMSS`, commit updated files under `specs/`, and open a PR with a summary and changelog. If no changes, do nothing.
- Error modes: Confluence auth failure (create issue or post comment), API rate limits (backoff and retry), export conversion errors (log and skip page), merge conflicts (PR shows conflicts for human resolution).

## Security & secrets

- Secrets required:
  - `CONFLUENCE_TOKEN` (read-only token to fetch pages)
  - `CONFLUENCE_BASE_URL` (if not already set)
- Use `GITHUB_TOKEN` to push branches and create PRs (default Actions token is fine for opening PRs).
- Do NOT log secrets; mask tokens in logs.

## Workflow outline

1. Action runs on schedule (cron) or manual dispatch.
2. Checkout repository.
3. Run `scripts/confluence-to-spec.sh --space <SPACE> --output specs/` (or iterate page IDs).
4. If `git status --porcelain` indicates changes:
   - Create branch `auto/specs-sync-<timestamp>`
   - Commit updates under `specs/` with message `chore(specs): sync from Confluence <date>`
   - Push branch
   - Create PR titled `chore(specs): Confluence sync <date>` with a short changelog and list of pages changed
5. Optionally run spec linter as part of the PR checks.

## Acceptance criteria

- A scheduled run that finds changes creates a PR with only `specs/` changes.
- PR body includes a summary of changed pages and a link to the Confluence source(s).
- No secrets are printed in logs.
- If the Confluence token is invalid, the Action fails with a helpful error and creates an issue (or posts a comment to a tracking issue).

## Tasks

1. Add workflow `.github/workflows/specs-sync.yml` (10–20 min)
2. Add a tiny wrapper script `scripts/specs-sync-wrapper.sh` to call `confluence-to-spec.sh`, collect changed pages, and exit with an appropriate status (15–30 min)
3. (Optional) Add spec-lint job used by the PR checks (30–60 min)

## Example workflow snippet

```yaml
name: Sync specs from Confluence
on:
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Confluence -> spec sync
        env:
          CONFLUENCE_BASE_URL: ${{ secrets.CONFLUENCE_BASE_URL }}
          CONFLUENCE_TOKEN: ${{ secrets.CONFLUENCE_TOKEN }}
        run: |
          ./scripts/confluence-to-spec.sh --space DATAFEEDS --output specs/
      - name: Commit & create PR if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          if [[ -n "$(git status --porcelain)" ]]; then
            BRANCH="auto/specs-sync-$(date -u +%Y%m%d%H%M%S)"
            git checkout -b "$BRANCH"
            git add specs/
            git commit -m "chore(specs): update from Confluence $(date -u +%Y-%m-%d)"
            git push origin "$BRANCH"
            gh pr create --title "chore(specs): Confluence sync $(date -u +%Y-%m-%d)" --body "Auto-updated specs from Confluence" --base main --head "$BRANCH"
          else
            echo "No spec changes; nothing to do."
          fi
```

## Validation

- Manual `workflow_dispatch` run should produce a PR when Confluence pages differ from the current `specs/` files.
- Confirm PR contains a clear list of changed files and links to the original Confluence pages (the `confluence-to-spec` script should embed source links in the spec front-matter).

---

**Maintainers**: Engineering Team
**Contact**: GitHub Copilot Chat
