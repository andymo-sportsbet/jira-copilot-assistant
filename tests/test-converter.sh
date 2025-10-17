#!/usr/bin/env bash
# Test runner for markdown_to_jira_adf converter
# Validates that markdown samples convert to valid ADF JSON and checks node types

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source the converter library
source "$PROJECT_ROOT/scripts/lib/jira-format.sh"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result function
test_result() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$actual" == *"$expected"* ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${YELLOW}Expected (substring):${NC} $expected"
        echo -e "  ${YELLOW}Actual:${NC} $actual"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test: valid JSON output
test_valid_json() {
    local input="$1"
    local test_name="$2"
    
    local output
    output=$(markdown_to_jira_adf "$input" 2>&1) || {
        echo -e "${RED}✗${NC} $test_name - Conversion failed"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    }
    
    # Validate JSON
    if echo "$output" | jq . >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name - Valid JSON"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "$output"
        return 0
    else
        echo -e "${RED}✗${NC} $test_name - Invalid JSON"
        echo "$output"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test: check for specific ADF node type
test_node_type() {
    local input="$1"
    local expected_type="$2"
    local test_name="$3"
    
    local output
    output=$(markdown_to_jira_adf "$input" 2>&1) || {
        echo -e "${RED}✗${NC} $test_name - Conversion failed"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    }
    
    test_result "$test_name" "\"type\": \"$expected_type\"" "$output"
}

echo "========================================"
echo "Markdown to ADF Converter Test Suite"
echo "========================================"
echo ""

# Test 1: Simple paragraph
echo "Test Group 1: Basic Paragraph"
test_valid_json "This is a simple paragraph." "Simple paragraph - valid JSON"
test_node_type "This is a simple paragraph." "paragraph" "Simple paragraph - contains paragraph node"
echo ""

# Test 2: ATX Heading (Level 2)
echo "Test Group 2: ATX Headings"
test_valid_json "## Overview" "ATX heading - valid JSON"
test_node_type "## Overview" "heading" "ATX heading - contains heading node"
echo ""

# Test 3: Fenced code block
echo "Test Group 3: Fenced Code Blocks"
CODE_SAMPLE='```python
def hello():
    print("Hello")
```'
test_valid_json "$CODE_SAMPLE" "Fenced code block - valid JSON"
test_node_type "$CODE_SAMPLE" "codeBlock" "Fenced code block - contains codeBlock node"
echo ""

# Test 4: Bullet list
echo "Test Group 4: Lists"
LIST_SAMPLE='- Item one
- Item two
- Item three'
test_valid_json "$LIST_SAMPLE" "Bullet list - valid JSON"
test_node_type "$LIST_SAMPLE" "bulletList" "Bullet list - contains bulletList node"
echo ""

# Test 5: Inline code
echo "Test Group 5: Inline Formatting"
test_valid_json "Use the \`code()\` function." "Inline code - valid JSON"
test_node_type "Use the \`code()\` function." "code" "Inline code - contains code mark"
echo ""

# Test 6: Bold text
test_valid_json "This is **bold** text." "Bold text - valid JSON"
test_node_type "This is **bold** text." "strong" "Bold text - contains strong mark"
echo ""

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "Total:  $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
