#!/usr/bin/env bats

setup() {
  ROOT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../" && pwd)"
  # Load the team estimation library into the current shell
  # shellcheck disable=SC1090
  source "$ROOT_DIR/scripts/lib/jira-estimate-team.sh"
}

@test "team estimation: bug fix returns 1 story point" {
  ticket='{"fields": {"summary": "Fix broken login button", "description": "The login button is not working in production", "issuetype": {"name": "Bug"}}}'

  output=$(estimate_story_points_team "$ticket")
  rc=$?
  [ "$rc" -eq 0 ]

  points=$(echo "$output" | jq -r '.estimated_points')
  [ "$points" -eq 1 ]
}

@test "team estimation: reasoning contains base explanation for bugs" {
  ticket='{"fields": {"summary": "Fix broken login button", "description": "The login button is not working in production", "issuetype": {"name": "Bug"}}}'

  output=$(estimate_story_points_team "$ticket")
  rc=$?
  [ "$rc" -eq 0 ]

  reasoning=$(echo "$output" | jq -r '.reasoning')
  echo "$reasoning" | grep -q "Base: 0.5"
}
