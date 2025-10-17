#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/jira-format.sh"

ISSUE_JSON="${SCRIPT_DIR}/../.temp/RVV-1118.json"
AI_DESC="${SCRIPT_DIR}/../.temp/rvv-1118-generated.txt"

if [[ ! -f "$ISSUE_JSON" ]]; then
  echo "Issue JSON not found: $ISSUE_JSON"
  exit 1
fi

if [[ ! -f "$AI_DESC" ]]; then
  echo "AI description not found: $AI_DESC"
  exit 1
fi

# Read ticket_data
ticket_data=$(cat "$ISSUE_JSON")

# Extract current description similar to grooming script
current_description=""
if echo "$ticket_data" | jq -e '.fields.description and (.fields.description | type == "object")' >/dev/null 2>&1; then
  current_description=$(echo "$ticket_data" | jq -r '.fields.description | .. | .text? // empty' 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ //;s/ $//')
else
  current_description=$(echo "$ticket_data" | jq -r '.fields.description // ""' 2>/dev/null || echo "")
fi

# Read and sanitize AI description
ai_description=$(sed -e 's/^\s\+//;s/\s\+$//' "$AI_DESC" | sed '/^$/d')
ai_description=$(echo "$ai_description" | sed 's/⚡ COPILOT_GENERATED_START ⚡//g' | sed 's/⚡ COPILOT_GENERATED_END ⚡//g')

start_marker="⚡ COPILOT_GENERATED_START ⚡"
end_marker="⚡ COPILOT_GENERATED_END ⚡"

# Build enhanced_description
enhanced_description=""
if [[ -n "$current_description" ]]; then
  enhanced_description="$current_description\n\n---\n\n"
fi
enhanced_description+="$start_marker\n\n"
if [[ -n "$ai_description" ]]; then
  enhanced_description+="$ai_description\n\n---\n\n"
fi
# For dry-run keep acceptance criteria placeholder
enhanced_description+="*Generated Acceptance Criteria:*\n\n* Functionality should be fully tested with unit tests\n* Code should follow project coding standards\n"
enhanced_description+="\n\n$end_marker"

# Convert using markdown_to_jira_adf (this function should be available)
converted=$(markdown_to_jira_adf "$enhanced_description")

# Validate JSON
if echo "$converted" | jq -e '.' >/dev/null 2>&1; then
  echo "Conversion: OK — valid JSON ADF"
  echo "ADF preview (truncated 800 chars):"
  echo
  echo "$converted" | head -c 800
  echo
else
  echo "Conversion: FAILED — output is not valid JSON"
  echo "Converted output (truncated 800 chars):"
  echo
  echo "$converted" | head -c 800
  echo
  exit 1
fi

exit 0
