import re
from pathlib import Path


def test_estimation_posting_comment_and_single_post():
    script = Path('scripts/jira-groom.sh').read_text()

    # 1) Check explanatory comment exists near the estimation block
    assert 'generate the ADF payload to a temp file and POST it exactly once' in script, \
        "Explanatory comment about single generate->post sequence is missing"

    # 2) Ensure we only post the estimation temp file once (count occurrences of -d @"$est_comment_file")
    post_pattern = re.compile(r"-d\s+@\"\$est_comment_file\"")
    posts = post_pattern.findall(script)
    assert len(posts) == 1, f"Expected exactly one POST of $est_comment_file, found {len(posts)}"

    # 3) Ensure there is a removal of the temp file (cleanup)
    assert script.count('rm -f "$est_comment_file"') >= 1, "Expected at least one rm -f of the est_comment_file"
