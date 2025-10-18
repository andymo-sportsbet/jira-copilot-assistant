from tests.ci.support.mcp_helpers import load_jira_module

mod = load_jira_module()
JiraBashWrapper = mod.JiraBashWrapper

def test_template_selection_cases():
    wrapper = JiraBashWrapper()
    cases = [
        ("Spring Boot 3 upgrade", "Upgrade to Java 17", "tech-debt"),
        ("User login bug", "Users cannot login", "bug"),
        ("Investigate Kafka performance", "Research spike", "spike"),
        ("Add export feature", "New CSV export functionality", "story"),
    ]
    for s, d, expected in cases:
        assert wrapper._suggest_template_smart(s, d) == expected
