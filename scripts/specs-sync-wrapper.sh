#!/usr/bin/env bash
set -euo pipefail

# Wrapper to sync Confluence pages to specs/ using scripts/confluence-to-spec.sh
# Usage: scripts/specs-sync-wrapper.sh --space SPACE_KEY --output specs/ [--pages "123,456"]

SPACE=""
PAGES=""
OUTPUT="specs"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --space) SPACE="$2"; shift 2 ;;
    --pages) PAGES="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help) echo "Usage: $0 [--space SPACE] [--pages PAGE_IDS] [--output OUTPUT]"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$SPACE" && -z "$PAGES" ]]; then
  echo "Error: either --space or --pages must be provided" >&2
  exit 2
fi

mkdir -p "$OUTPUT"

# Run conversion. The existing script should accept --space or --page-id; adapt if necessary.
if [[ -n "$PAGES" ]]; then
  IFS=',' read -ra IDS <<< "$PAGES"
  for id in "${IDS[@]}"; do
    echo "Converting page id $id..."
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "Dry-run: would convert page id $id -> $OUTPUT"
    else
      ./scripts/confluence-to-spec.sh --page-id "$id" --output "$OUTPUT" || echo "Failed to convert page $id" >&2
    fi
  done
else
  echo "Syncing space $SPACE to $OUTPUT..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Dry-run: would sync space $SPACE -> $OUTPUT"
  else
    ./scripts/confluence-to-spec.sh --space "$SPACE" --output "$OUTPUT"
  fi
fi

# Detect git changes
if [[ -n "$(git status --porcelain "$OUTPUT" 2>/dev/null || true)" ]]; then
  echo "Changes detected in $OUTPUT"
  # List changed files
  git -c core.pager= -C . status --porcelain "$OUTPUT" | awk '{print $2}'
  exit 0
else
  echo "No changes in $OUTPUT"
  exit 0
fi
