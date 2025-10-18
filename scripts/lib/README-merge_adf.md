merge_adf.py

Helper to merge two JIRA ADF JSON documents (original + enhanced) into a single ADF `doc`.

Usage examples:

1) Merge two files:

```bash
python3 scripts/lib/merge_adf.py \
  --original .temp/MSPOC-99-original-adf.json \
  --enhanced .temp/MSPOC-99-enhanced-adf.json \
  --output .temp/MSPOC-99-merged-adf.json
```

2) From `scripts/jira-groom.sh`, after producing an enhanced ADF JSON file, call this helper to create the final merged ADF before sending to JIRA.

Notes:
- This tool concatenates the `content` arrays: original content first, enhanced content appended.
- It intentionally does not attempt to dedupe or deeply merge ADF nodes — that would be more complex and is left for future improvements.
