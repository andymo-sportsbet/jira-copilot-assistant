import json
import sys
import pytest
from pathlib import Path

# Ensure repository root is on sys.path so tests can import the library modules
REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from scripts.lib.merge_adf import merge_adf, ensure_doc


def make_paragraph(text):
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}


def test_merge_doc_doc_basic():
    orig = {"type": "doc", "version": 1, "content": [make_paragraph("orig")]}
    enh = {"type": "doc", "version": 2, "content": [make_paragraph("enh") ]}

    merged = merge_adf(orig, enh)
    assert merged["type"] == "doc"
    # version should be max of versions
    assert merged["version"] == 2
    texts = [n["content"][0]["text"] for n in merged["content"] if n.get("type") == "paragraph"]
    assert texts == ["orig", "enh"]


def test_merge_doc_with_empty_original():
    orig = {"type": "doc", "version": 1, "content": []}
    enh = {"type": "doc", "version": 1, "content": [make_paragraph("only-enh")]}

    merged = merge_adf(orig, enh)
    assert merged["content"] == enh["content"]


def test_merge_content_only_original_allowed():
    # original missing explicit type but has content -> allowed by ensure_doc
    orig = {"content": [make_paragraph("orig-no-type")]}
    enh = {"type": "doc", "version": 1, "content": [make_paragraph("enh")]}

    # ensure_doc should accept the content-only dict
    o = ensure_doc(orig)
    assert isinstance(o, dict)

    merged = merge_adf(orig, enh)
    texts = [n["content"][0]["text"] for n in merged["content"] if n.get("type") == "paragraph"]
    assert texts == ["orig-no-type", "enh"]


def test_ensure_doc_errors():
    # not a dict
    with pytest.raises(TypeError):
        ensure_doc([1, 2, 3])

    # dict without type and without content list should raise ValueError
    with pytest.raises(ValueError):
        ensure_doc({"foo": "bar"})
