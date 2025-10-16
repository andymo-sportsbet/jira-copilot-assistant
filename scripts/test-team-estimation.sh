#!/usr/bin/env bash
# Test script for team estimation library

cd "$(dirname "$0")/.."
source scripts/lib/jira-estimate-team.sh

echo "=========================================="
echo "Team Estimation Library Tests"
echo "=========================================="
echo ""

# Test 1: Simple bug fix
echo "Test 1: Bug Fix"
echo "---------------"
test_ticket_1='{
  "fields": {
    "summary": "Fix broken login button",
    "description": "The login button is not working in production",
    "issuetype": {"name": "Bug"}
  }
}'

result=$(estimate_story_points_team "$test_ticket_1")
echo "$result" | jq '.'
echo ""

# Test 2: Simple config change
echo "Test 2: Config Change"
echo "---------------------"
test_ticket_2='{
  "fields": {
    "summary": "Update environment configuration for staging",
    "description": "Simple config change to add new environment variable",
    "issuetype": {"name": "Task"}
  }
}'

result=$(estimate_story_points_team "$test_ticket_2")
echo "$result" | jq '.'
echo ""

# Test 3: API integration (moderate complexity)
echo "Test 3: API Integration"
echo "-----------------------"
test_ticket_3='{
  "fields": {
    "summary": "Add new API endpoint for user profiles",
    "description": "Create REST API endpoint with database queries and validation logic",
    "issuetype": {"name": "Story"}
  }
}'

result=$(estimate_story_points_team "$test_ticket_3")
echo "$result" | jq '.'
echo ""

# Test 4: Framework upgrade (high complexity)
echo "Test 4: Framework Upgrade"
echo "-------------------------"
test_ticket_4='{
  "fields": {
    "summary": "Upgrade Spring Boot framework to latest version",
    "description": "Major framework upgrade requiring migration and refactoring. Unknown issues might need investigation.",
    "issuetype": {"name": "Story"}
  }
}'

result=$(estimate_story_points_team "$test_ticket_4")
echo "$result" | jq '.'
echo ""

# Test 5: Generate explanation
echo "Test 5: Estimation Explanation"
echo "-------------------------------"
generate_team_estimation_explanation "2" "Add API endpoint"
echo ""

# Test 6: Complexity analysis
echo "Test 6: Complexity Analysis"
echo "---------------------------"
result=$(analyze_complexity_team "Upgrade framework" "This requires migration and integration work")
echo "$result" | jq '.'
echo ""

echo "=========================================="
echo "All tests completed!"
echo "=========================================="
