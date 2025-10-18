def test_auto_description_flag_present():
    script = open('scripts/jira-groom.sh').read()
    assert '--auto-description' in script, "Expected --auto-description to be present in jira-groom.sh"
