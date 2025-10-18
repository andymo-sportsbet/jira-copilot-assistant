SHELL := /bin/bash

.PHONY: test-integration clean-temp

# Run integration tests (gated). Requires .env.test.local and optional mock server.
test-integration:
	@echo "Running integration tests (gated). Make sure .env.test.local exists and points to a safe test Jira project."
	@export RUN_INTEGRATION_TESTS=1; \
	bats tests/integration/test_e2e_runner.bats

clean-temp:
	@echo "Cleaning .temp/ artifacts..."
	@./scripts/cleanup-temp.sh || true
