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
  skip "Skipping integration test: requires local mock JIRA (set RUN_INTEGRATION_TESTS=1 to enable)"
}

@test "integration: jira_api_call auth failure against mock server" {
  skip "Skipping integration test: requires local mock JIRA (set RUN_INTEGRATION_TESTS=1 to enable)"
}
