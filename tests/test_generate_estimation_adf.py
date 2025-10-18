import json
from pathlib import Path
import sys

# Ensure repo root on path
REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from scripts.lib.generate_estimation_adf import build_adf


def find_node_by_type(content, node_type):
    for n in content:
        if n.get('type') == node_type:
            return n
    return None


def test_build_adf_basic():
    points = '3'
    explanation = 'Base:1; Complexity:+1; Testing:+0.5; Total:2'
    doc = build_adf(points, explanation)

    assert 'body' in doc
    body = doc['body']
    assert body['type'] == 'doc'
    assert body['version'] == 1

    content = body['content']
    # Heading exists
    heading = find_node_by_type(content, 'heading')
    assert heading is not None
    assert heading['content'][0]['text'] == 'AI Story Point Estimation'

    # Paragraph with Estimated Effort and strong mark
    para = find_node_by_type(content, 'paragraph')
    assert para is not None
    texts = ''.join([t.get('text','') for t in para.get('content',[])])
    assert 'Estimated Effort' in texts

    # Bullet list exists and contains codeBlock
    bl = find_node_by_type(content, 'bulletList')
    assert bl is not None
    # second listItem should contain a codeBlock
    second_item = bl['content'][1]
    has_code = any(n.get('type') == 'codeBlock' for n in second_item.get('content', []))
    assert has_code


def test_build_adf_explanation_preserved():
    points = '2'
    explanation = 'Line1\nLine2 with special chars: " \ / < > &'
    doc = build_adf(points, explanation)
    bl = find_node_by_type(doc['body']['content'], 'bulletList')
    second_item = bl['content'][1]
    # Find codeBlock and its text
    codeblock = None
    for node in second_item['content']:
        if node.get('type') == 'codeBlock':
            codeblock = node
            break
    assert codeblock is not None
    text_node = codeblock['content'][0]
    assert text_node['text'] == explanation
