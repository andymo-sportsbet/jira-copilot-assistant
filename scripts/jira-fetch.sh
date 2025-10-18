## Dry-run support
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/lib/dryrun.sh"
parse_dry_run_arg "$@"
if is_dry_run; then
  echo "Dry-run: would fetch JIRA issue (no network calls)." >&2
  exit 0
fi

# Main
#!/usr/bin/env bash
set -euo pipefail

# jira-fetch.sh - read-only fetch of a JIRA issue and save JSON + markdown summary
# Usage: jira-fetch.sh <ISSUE-KEY>

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=1
  ISSUE_KEY=${2:-}
else
  ISSUE_KEY=${1:-}
fi

if [ -z "$ISSUE_KEY" ]; then
  echo "Usage: $0 [--dry-run] <ISSUE-KEY>"
  exit 2
fi

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
TMP_DIR="$ROOT_DIR/.temp"
mkdir -p "$TMP_DIR"

# Source shared helpers so behavior matches other scripts
source "$ROOT_DIR/scripts/lib/utils.sh"
source "$ROOT_DIR/scripts/lib/jira-api.sh"

# Load .env if present (same pattern as other scripts)
load_env "$ROOT_DIR/.env"

check_dependencies || exit 1

if [ "$DRY_RUN" -eq 0 ]; then
  # check_jira_config will validate required env vars and JIRA_TOKEN/JIRA_API_TOKEN
  check_jira_config || exit 1
else
  echo "Dry run: will not contact JIRA."
fi

OUT_JSON="$TMP_DIR/${ISSUE_KEY}.json"
OUT_MD="$TMP_DIR/${ISSUE_KEY}.md"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN: would fetch ${JIRA_BASE_URL:-<JIRA_BASE_URL>}/rest/api/3/issue/${ISSUE_KEY} and write to $OUT_JSON and $OUT_MD"
  echo "DRY RUN: summary preview:" 
  echo "# ${ISSUE_KEY} — <summary from JIRA>"
  echo "**Status:** <status>" 
  echo "**Assignee:** <assignee>" 
  echo
else
  echo "Fetching $ISSUE_KEY from JIRA..."
  if ! jira_get_issue "$ISSUE_KEY" > "$OUT_JSON"; then
    echo "Failed to fetch issue or API returned an error." >&2
    exit 1
  fi

  echo "Saving JSON to $OUT_JSON"
  echo "Generating markdown summary to $OUT_MD"
  # Extract common fields safely with jq and build the markdown in shell to avoid jq quoting issues
  KEY=$(jq -r '.key // ""' "$OUT_JSON" 2>/dev/null || true)
  SUMMARY=$(jq -r '.fields.summary // ""' "$OUT_JSON" 2>/dev/null || true)
  STATUS=$(jq -r '.fields.status.name // ""' "$OUT_JSON" 2>/dev/null || true)
  ASSIGNEE=$(jq -r '.fields.assignee.displayName // "(unassigned)"' "$OUT_JSON" 2>/dev/null || true)

  # Determine if description exists and whether it's an object (ADF) or plain string
  if jq -e 'has("fields") and (.fields.description != null)' "$OUT_JSON" >/dev/null 2>&1; then
    if jq -e '(.fields.description | type) == "object"' "$OUT_JSON" >/dev/null 2>&1; then
      DESC_JSON=$(jq '.fields.description' "$OUT_JSON" 2>/dev/null || true)
      cat > "$OUT_MD" <<EOF
# ${KEY} — ${SUMMARY}

**Status:** ${STATUS}

**Assignee:** ${ASSIGNEE}

**Description (ADF JSON excerpt):**

EOF
      # Append pretty-printed JSON block
      printf '```json
%s
```
' "${DESC_JSON}" >> "$OUT_MD"
    else
      DESC_TEXT=$(jq -r '.fields.description // ""' "$OUT_JSON" 2>/dev/null || true)
      cat > "$OUT_MD" <<EOF
# ${KEY} — ${SUMMARY}

**Status:** ${STATUS}

**Assignee:** ${ASSIGNEE}

**Description:**

${DESC_TEXT}
EOF
    fi
  else
    # fallback to summary-only output when no description
    cat > "$OUT_MD" <<EOF
# ${KEY} — ${SUMMARY}

**Status:** ${STATUS}

**Assignee:** ${ASSIGNEE}
EOF
  fi

  echo "Wrote: $OUT_JSON and $OUT_MD"
fi

exit 0
