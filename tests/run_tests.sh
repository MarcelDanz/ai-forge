#!/bin/bash
set -e
# This script runs all bats tests in the tests/ directory.
# It should be run from the root of the repository.

# Ensure bats is available
if [ ! -d "tests/bats" ]; then
    echo "Bats-core submodule not found. Please run:"
    echo "git submodule update --init --recursive"
    exit 1
fi

# Add bats to the path
export PATH="$(pwd)/tests/bats/bin:$PATH"

# Run all test files ending in .bats or .sh
bats --print-output-on-failure tests/test_*.sh
