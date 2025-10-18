#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_DIR="$ROOT_DIR/.temp"

if [ ! -d "$TEMP_DIR" ]; then
  echo ".temp/ directory not found; nothing to clean."
  exit 0
fi

read -p "Are you sure you want to delete all files in $TEMP_DIR? [y/N] " confirm
confirm=${confirm:-N}
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborting."
  exit 1
fi

rm -rf "$TEMP_DIR"/*
echo "Cleaned $TEMP_DIR"
