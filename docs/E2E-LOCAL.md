# Local end-to-end (E2E) testing with live JIRA

This short guide explains the local-only testing guardrails used by the repository and how to run the `scripts/e2e-run.sh` runner safely.

WARNING: The E2E runner uses your Jira credentials and will create, update and close real tickets in the configured Jira instance. Keep credentials out of version control and run these steps only on a trusted machine.

## Purpose

- Provide repeatable local end-to-end coverage for create → fetch → groom → close flows.
- Keep CI focused on unit tests and avoid storing secrets in the repo.

## `.env.test.local` (local-only)

Create a file named `.env.test.local` at the repo root to configure the runner. This file is gitignored by default. Example contents:

```
# Example .env.test.local
JIRA_BASE_URL=https://your-instance.atlassian.net
JIRA_EMAIL=you@example.com
JIRA_API_TOKEN=your_api_token_here
JIRA_PROJECT=MSPOC
JIRA_ISSUETYPE=Story
# Optional override; the runner can auto-detect if unset
JIRA_STORY_POINTS_FIELD=customfield_10016

# Local convenience values
TEMP_DIR=.temp
```

Notes:
- Never commit this file. It contains credentials. Keep it local and protected.
- The runner attempts to auto-detect the correct Story Points custom field when possible.

## Running the E2E runner

Make sure `.env.test.local` is present and populated. Then run:

```bash
cd jira-copilot-assistant
source .env.test.local
bash ./scripts/e2e-run.sh
```

What the script does:
- Creates a ticket in the configured project
- Fetches it and saves artifacts to `.temp/` (JSON + Markdown)
- Attempts to groom (update story points / acceptance criteria)
- Transitions the ticket to Done

If something goes wrong, inspect the log lines printed to the terminal and the `.temp/` log file created by the runner.

## Artifacts and cleanup

- `.temp/` will contain JSON and markdown copies of fetched tickets and the e2e log.
- Decide whether to keep these artifacts. Consider adding a cleanup helper if you prefer to remove them after runs.

## Safety checklist before running

1. Confirm `.env.test.local` contains credentials for a non-production/test project.
2. Confirm you want to create and close tickets in that Jira project.
3. Run the script and watch output. The script logs key steps and any API errors.

## Troubleshooting

- If ticket creation fails with a `customfield_*` required error, your Jira instance may require additional fields. Either populate those fields in `.env.test.local` or run the create step manually to inspect required create metadata.
- If story points cannot be updated, the runner will attempt to auto-detect the correct custom field; check permissions and field configuration in Jira.

## Contributing

If you'd like the repo to include a reproducible mock-server-based integration suite, we recommend moving the existing integration tests to `tests/integration/` and executing them only on developer machines (not CI). Open a PR with that change if you'd like help.

---
Last updated: 2025-10-18
