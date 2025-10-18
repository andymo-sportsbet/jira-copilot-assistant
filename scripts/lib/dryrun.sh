#!/usr/bin/env bash
# Simple DRY-RUN helper
DRY_RUN=0
parse_dry_run_arg() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
}

is_dry_run() {
  [[ "$DRY_RUN" -eq 1 ]]
}
