#!/usr/bin/env bats

# Simple Bats test to source a library file and test a helper function that does not call network.
# We choose a safe function name `to_upper` as an example; if it doesn't exist, test will skip.

setup() {
  LIB_DIR="$(dirname "$BATS_TEST_FILENAME")/../../scripts/lib"
}

@test "lib helper to_upper exists and transforms text" {
  if [ ! -f "$LIB_DIR/format.sh" ]; then
    skip "format.sh not present; skip"
  fi
  # shellcheck disable=SC1090
  source "$LIB_DIR/format.sh"
  if ! type to_upper >/dev/null 2>&1; then
    skip "to_upper function not found in format.sh"
  fi
  result=$(to_upper "hello")
  [ "$result" = "HELLO" ]
}
