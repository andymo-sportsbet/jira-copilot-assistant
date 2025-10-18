#!/usr/bin/env python3
"""
Test Bash Wrapper
Quick validation that wrapper can call bash scripts
"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from jira_bash_wrapper import JiraBashWrapper


def test_wrapper():
    """Test basic wrapper functionality"""
    print("=== Testing Jira Bash Wrapper ===\n")
    
    # Initialize wrapper
    wrapper = None
    try:
        wrapper = JiraBashWrapper()
        print(f"✅ Wrapper initialized")
        print(f"   Scripts dir: {wrapper.scripts_dir}")
        print(f"   Project dir: {wrapper.project_dir}\n")
    except Exception as e:
        print(f"❌ Failed to initialize wrapper: {e}")
        assert False, f"Failed to initialize wrapper: {e}"
    
    # Check scripts exist
    scripts = [
        'jira-groom.sh',
        'jira-create.sh',
        'confluence-to-spec.sh',
        'find-related-tickets.sh',
        'jira-close.sh'
    ]
    
    print("Checking scripts exist:")
    all_found = True
    for script in scripts:
        script_path = os.path.join(wrapper.scripts_dir, script)
        exists = os.path.exists(script_path)
        print(f"   {'✅' if exists else '❌'} {script}")
        if not exists:
            all_found = False
    
    if not all_found:
        print("\n❌ Some scripts not found!")
        assert False, "Some scripts not found"
    
    print("\n✅ All scripts found!")
    
    # Test running a simple script (just check it executes)
    print("\nTesting script execution...")
    print("Note: This will fail if .env is not configured, but wrapper itself works")
    
    # Try running help for jira-groom
    result = wrapper._run_script('jira-groom.sh', ['--help'])
    
    if 'Usage:' in result.get('output', '') or result.get('success'):
        print("✅ Script execution works (help displayed)")
    else:
        print("⚠️  Script execution attempted")
        print(f"   Output: {result.get('output', '')[:100]}")
        print(f"   Error: {result.get('error', '')[:100]}")

    print("\n=== Wrapper Test Complete ===")
    print("\nTo use with MCP:")
    print("1. Update mcp.json to use jira_bash_wrapper.py")
    print("2. Reload VS Code")
    print("3. Ask Copilot: 'Groom ticket RVV-1234'")

    # Return None for pytest-friendly behavior
    return None


if __name__ == "__main__":
    try:
        test_wrapper()
        sys.exit(0)
    except AssertionError as e:
        print(f"Test failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(2)
