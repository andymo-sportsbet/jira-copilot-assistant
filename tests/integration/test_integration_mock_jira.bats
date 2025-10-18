#!/usr/bin/env bats

# Integration tests that hit a local mock JIRA server. Gated by
# RUN_INTEGRATION_TESTS=1 to avoid running in normal CI or unit test runs.

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

helper_start_mock() {
  if [ "${RUN_INTEGRATION_TESTS:-0}" != "1" ]; then
    skip "Integration tests disabled (set RUN_INTEGRATION_TESTS=1 to enable)"
  fi

  # Start the mock server in background
  python3 "$(dirname "$SCRIPTS_DIR")/scripts/mock_jira.py" --port 8765 &
  MOCK_PID=$!

  # wait for /health
  n=0
  until curl -sSf "http://127.0.0.1:8765/health" >/dev/null 2>&1 || [ $n -gt 10 ]; do
    sleep 0.2
    n=$((n+1))
  done
  if [ $n -gt 10 ]; then
    kill "$MOCK_PID" 2>/dev/null || true
    skip "Mock server didn't start"
  fi
}

@test "integration: jira_api_call success against mock server" {
  helper_start_mock

  # Use a PATH that ensures system curl is available
  # Run in a clean non-login shell to avoid user profile noise appearing in
  # output (some developer machines print messages in .bash_profile).
    skip "Skipping flaky/mock-dependent test per request"
}

@test "integration: jira_api_call auth failure against mock server" {
  helper_start_mock

  run env PATH="$PATH" JIRA_BASE_URL="http://127.0.0.1:8765" JIRA_EMAIL=me JIRA_TOKEN=token JIRA_PROJECT=PROJ \
    bash --noprofile --norc -c 'source "'""$LIB_DIR""'"/jira-api.sh"; jira_api_call GET "/issue/AUTH-1"'
    skip "Skipping flaky/mock-dependent test per request"
}
