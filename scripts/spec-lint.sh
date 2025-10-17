#!/usr/bin/env bash
set -euo pipefail

# Very small spec linter: checks for YAML front-matter with title and confluence_url

FAILED=0

for f in "$@"; do
  if [[ ! -f "$f" ]]; then
    echo "Skipping $f (not a file)"
    continue
  fi
  # check for YAML front-matter
  if ! head -n 5 "$f" | grep -q '^---'; then
    echo "[ERROR] $f missing YAML front-matter start '---'"
    FAILED=1
    continue
  fi
  # check contains confluence_url or title
  if ! grep -q '^confluence_url:' -m1 "$f" && ! grep -q '^title:' -m1 "$f"; then
    echo "[WARN] $f missing 'confluence_url' or 'title' in front-matter"
  fi
done

exit $FAILED
