#!/usr/bin/env bats

# Integration tests that hit a local mock JIRA server. These are gated by
# RUN_INTEGRATION_TESTS=1 to avoid running in normal CI.

setup() {
  SCRIPTS_DIR="$(dirname "$BATS_TEST_FILENAME")/../../scripts"
  LIB_DIR="$(dirname "$BATS_TEST_FILENAME")/../../scripts/lib"
}

teardown() {
  if [ -n "${MOCK_PID:-}" ]; then
    kill "$MOCK_PID" 2>/dev/null || true
    wait "$MOCK_PID" 2>/dev/null || true
  fi
}

@test "integration: jira_api_call success against mock server" {
  if [ "${RUN_INTEGRATION_TESTS:-0}" != "1" ]; then
    skip "Integration tests disabled (set RUN_INTEGRATION_TESTS=1 to enable)"
  fi

  python3 "$SCRIPTS_DIR/mock_jira.py" --port 8765 &
  MOCK_PID=$!
  # wait briefly for server to be ready
  sleep 0.5

  # Source the library and call jira_api_call against the mock server
  source "$LIB_DIR/jira-api.sh"
  JIRA_BASE_URL="http://127.0.0.1:8765" JIRA_EMAIL=me JIRA_TOKEN=token JIRA_PROJECT=PROJ \
    run bash -c 'jira_api_call GET "/issue/OK-1"'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"key":"OK-1"'
}

@test "integration: jira_api_call auth failure against mock server" {
  if [ "${RUN_INTEGRATION_TESTS:-0}" != "1" ]; then
    skip "Integration tests disabled (set RUN_INTEGRATION_TESTS=1 to enable)"
  fi

  # mock server already started in previous test if sequential; still safe
  source "$LIB_DIR/jira-api.sh"
  JIRA_BASE_URL="http://127.0.0.1:8765" JIRA_EMAIL=me JIRA_TOKEN=token JIRA_PROJECT=PROJ \
    run bash -c 'jira_api_call GET "/issue/AUTH-1"'
  [ "$status" -ne 0 ]
  echo "$output" | grep -qi 'Authentication failed'
}
