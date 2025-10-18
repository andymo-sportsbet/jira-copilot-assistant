#!/usr/bin/env python3
"""
merge_adf.py

Small helper to merge two JIRA ADF documents into one.

Usage:
  merge_adf.py --original original_adf.json --enhanced enhanced_adf.json --output merged.json

Behavior:
- Loads both JSON docs (must be ADF `doc` objects with `content` arrays)
- Produces a new `doc` with version=1 and content = original.content + enhanced.content
- If `enhanced` contains top-level metadata (title etc.) it's preserved; merged doc will use original `version` if present or 1

This avoids fragile jq/bash quoting by using Python's JSON parsing.
"""

import argparse
import json
import sys
from pathlib import Path


def load_json(path: Path):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading JSON from {path}: {e}", file=sys.stderr)
        raise


def ensure_doc(adf: dict):
    if not isinstance(adf, dict):
        raise TypeError("ADF must be a JSON object")
    if adf.get("type") != "doc":
        # Allow if the user passed the content array directly
        if isinstance(adf.get("content"), list):
            return adf
        raise ValueError("ADF doc must have type 'doc'")
    return adf


def merge_adf(original: dict, enhanced: dict) -> dict:
    orig = ensure_doc(original)
    enh = ensure_doc(enhanced)

    merged = {
        "type": "doc",
        "version": max(orig.get("version", 1), enh.get("version", 1)),
        "content": []
    }

    # Append original content first (preserve as-is)
    merged_content = []
    if isinstance(orig.get("content"), list):
        merged_content.extend(orig.get("content"))

    # Then append enhanced content
    if isinstance(enh.get("content"), list):
        merged_content.extend(enh.get("content"))

    merged["content"] = merged_content
    return merged


def main():
    p = argparse.ArgumentParser(description="Merge two JIRA ADF JSON documents (original then enhanced)")
    p.add_argument("--original", required=True, help="Path to original ADF JSON file")
    p.add_argument("--enhanced", required=True, help="Path to enhanced ADF JSON file")
    p.add_argument("--output", required=True, help="Path to write merged ADF JSON file")
    args = p.parse_args()

    orig = load_json(Path(args.original))
    enh = load_json(Path(args.enhanced))

    merged = merge_adf(orig, enh)

    outp = Path(args.output)
    outp.parent.mkdir(parents=True, exist_ok=True)
    with outp.open("w", encoding="utf-8") as f:
        json.dump(merged, f, indent=2, ensure_ascii=False)

    print(f"Wrote merged ADF to {outp}")


if __name__ == "__main__":
    main()
