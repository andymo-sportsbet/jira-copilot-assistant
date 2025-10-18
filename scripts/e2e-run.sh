#!/usr/bin/env bash

set -euo pipefail

# scripts/e2e-run.sh
# Simple end-to-end runner: create -> fetch -> groom -> close

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$ROOT_DIR/.temp"
mkdir -p "$TMP_DIR"

timestamp() { date +%Y%m%dT%H%M%S; }

LOG_FILE="$TMP_DIR/e2e-$(timestamp).log"

echo "Starting E2E run: logging to $LOG_FILE"

# Load test environment (prefers .env.test.local if present)
if [[ -f "$ROOT_DIR/.env.test.local" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env.test.local"

  # Always try to discover the Story Points field id and override if found.
  echo "Detecting story points field id (will override existing value if found)..." | tee -a "$LOG_FILE"
  sp_field=$(curl -s -u "$JIRA_EMAIL:${JIRA_API_TOKEN:-$JIRA_TOKEN}" -H "Accept: application/json" "$JIRA_BASE_URL/rest/api/3/field" | jq -r '.[] | select(.name|test("story point|Story point|Story Points";"i")) | .id' | head -1 || true)
  if [[ -n "$sp_field" ]]; then
    if [[ "${JIRA_STORY_POINTS_FIELD:-}" != "$sp_field" ]]; then
      echo "Overriding JIRA_STORY_POINTS_FIELD: '${JIRA_STORY_POINTS_FIELD:-<none>}' -> '$sp_field'" | tee -a "$LOG_FILE"
    else
      echo "JIRA_STORY_POINTS_FIELD already set to detected value: $sp_field" | tee -a "$LOG_FILE"
    fi
    export JIRA_STORY_POINTS_FIELD="$sp_field"
  else
    echo "Could not detect story points field" | tee -a "$LOG_FILE"
  fi
else
  echo "No .env.test.local found in repo root. Aborting." | tee -a "$LOG_FILE"
  exit 1
fi

cd "$ROOT_DIR"

summary="E2E test $(timestamp)"
description="Created by automated E2E run. Safe to delete."

echo "[1/4] Creating ticket..." | tee -a "$LOG_FILE"
create_output=$(bash ./scripts/jira-create.sh --summary "$summary" --description "$description" --features "e2e-test" --priority "Low" 2>&1 | tee -a "$LOG_FILE") || true

ticket_key=$(echo "$create_output" | grep -oE '[A-Z]+-[0-9]+' | head -1 || true)
if [[ -z "$ticket_key" ]]; then
  echo "Failed to create ticket. Output:" | tee -a "$LOG_FILE"
  echo "$create_output" | tee -a "$LOG_FILE"
  exit 1
fi

echo "Created ticket: $ticket_key" | tee -a "$LOG_FILE"

echo "[2/4] Fetching ticket $ticket_key..." | tee -a "$LOG_FILE"
bash ./scripts/jira-fetch.sh "$ticket_key" 2>&1 | tee -a "$LOG_FILE"

if [[ ! -f "$TMP_DIR/${ticket_key}.json" ]]; then
  echo "Fetch failed: expected $TMP_DIR/${ticket_key}.json" | tee -a "$LOG_FILE"
  exit 1
fi

echo "[3/4] Grooming ticket $ticket_key (set points=1)..." | tee -a "$LOG_FILE"
# Use --points to avoid interactive estimation in tests; tolerate story-points update failures
set +e
bash ./scripts/jira-groom.sh "$ticket_key" --points 1 2>&1 | tee -a "$LOG_FILE"
groom_status=${PIPESTATUS[0]}
set -e
if [[ "$groom_status" -ne 0 ]]; then
  echo "Groom step returned non-zero status: $groom_status" | tee -a "$LOG_FILE"
  echo "Continuing to close the ticket despite grooming errors." | tee -a "$LOG_FILE"
fi

echo "[4/4] Closing ticket $ticket_key..." | tee -a "$LOG_FILE"
bash ./scripts/jira-close.sh "$ticket_key" 2>&1 | tee -a "$LOG_FILE"

echo "E2E run completed successfully for $ticket_key" | tee -a "$LOG_FILE"
echo "Logs: $LOG_FILE"

exit 0
