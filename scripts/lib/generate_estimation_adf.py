#!/usr/bin/env python3
"""generate_estimation_adf.py

Generate a JIRA ADF JSON payload for AI story point estimation comments.

Usage:
  generate_estimation_adf.py --points 2 --explanation "..." --output /tmp/comment.json

Produces a JSON file containing the top-level object expected by the JIRA REST API when posting
a formatted document comment (the file will be passed to curl -d @file).
"""

from pathlib import Path
import argparse
import json
import sys


def build_adf(points: str, explanation: str) -> dict:
    doc = {
        "body": {
            "type": "doc",
            "version": 1,
            "content": [
                {
                    "type": "heading",
                    "attrs": {"level": 2},
                    "content": [{"type": "text", "text": "AI Story Point Estimation"}]
                },
                {
                    "type": "paragraph",
                    "content": [
                        {"type": "text", "text": "Estimated Effort: "},
                        {"type": "text", "text": str(points), "marks": [{"type": "strong"}]},
                        {"type": "text", "text": " Story Points"}
                    ]
                },
                {
                    "type": "bulletList",
                    "content": [
                        {
                            "type": "listItem",
                            "content": [
                                {"type": "paragraph", "content": [{"type": "text", "text": "Explanation", "marks": [{"type": "strong"}]}]}
                            ]
                        },
                        {
                            "type": "listItem",
                            "content": [
                                {"type": "paragraph", "content": [{"type": "text", "text": "Details (verbatim):", "marks": [{"type": "strong"}]}]},
                                {"type": "codeBlock", "attrs": {"language": "text"}, "content": [{"type": "text", "text": explanation}]}
                            ]
                        }
                    ]
                },
                {
                    "type": "paragraph",
                    "content": [{"type": "text", "text": "This is an AI-generated estimate. Team review recommended.", "marks": [{"type": "em"}]}]
                }
            ]
        }
    }
    return doc


def main():
    p = argparse.ArgumentParser(description="Generate ADF JSON for estimation comments")
    p.add_argument("--points", required=True, help="Estimated story points (string)")
    p.add_argument("--explanation", required=True, help="Estimation explanation text")
    p.add_argument("--output", required=True, help="Path to write the JSON payload")
    args = p.parse_args()

    outp = Path(args.output)
    outp.parent.mkdir(parents=True, exist_ok=True)

    doc = build_adf(args.points, args.explanation)

    with outp.open("w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, indent=2)

    print(f"Wrote estimation ADF to {outp}")


if __name__ == "__main__":
    main()
