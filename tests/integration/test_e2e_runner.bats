#!/usr/bin/env bats

# Wrapper to run the local E2E runner in a gated/integration-only way.

setup() {
  ROOT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../" && pwd)"
}

@test "integration: e2e-run.sh (gated)" {
  if [ "${RUN_INTEGRATION_TESTS:-0}" != "1" ]; then
    skip "Integration tests disabled (set RUN_INTEGRATION_TESTS=1 to enable)"
  fi

  # Ensure .env.test.local exists
  if [ ! -f "$ROOT_DIR/.env.test.local" ]; then
    skip ".env.test.local not present; skipping E2E run"
  fi

  run bash "$ROOT_DIR/scripts/e2e-run.sh"
  [ "$status" -eq 0 ]
}
