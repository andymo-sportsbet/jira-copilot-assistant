#!/usr/bin/env python3
"""Test template selection logic"""

from jira_bash_wrapper import JiraBashWrapper

def test_template_selection():
    """Test smart template selection"""
    wrapper = JiraBashWrapper()
    
    test_cases = [
        ("Spring Boot 3 upgrade", "Upgrade to Java 17", "tech-debt"),
        ("User login bug", "Users cannot login", "bug"),
        ("Investigate Kafka performance", "Research spike", "spike"),
        ("Add export feature", "New CSV export functionality", "story"),
        ("Refactor authentication", "Clean up auth code", "tech-debt"),
    ]
    
    print("=== Testing Template Selection ===\n")
    
    for summary, description, expected in test_cases:
        result = wrapper._suggest_template_smart(summary, description)
        status = "✅" if result == expected else "❌"
        print(f"{status} '{summary}' -> {result} (expected: {expected})")
    
    print("\n=== Test Complete ===")

if __name__ == "__main__":
    test_template_selection()
