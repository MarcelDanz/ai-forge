# BATS test helpers

# Make the forge script available to the tests
export FORGE_SCRIPT
FORGE_SCRIPT="$(pwd)/bin/forge"

# Creates a temporary directory for a test to run in.
# The path to the directory is stored in the global BATS_TEST_DIR variable.
# The original working directory is stored in BATS_TEST_ORIG_DIR.
# The setup_test_dir function should be called from the setup function of a test file.
setup_test_dir() {
    BATS_TEST_ORIG_DIR=$(pwd)
    BATS_TEST_DIR=$(mktemp -d)
    cd "$BATS_TEST_DIR"
}

# Cleans up the temporary directory.
# The teardown_test_dir function should be called from the teardown function of a test file.
teardown_test_dir() {
    cd "$BATS_TEST_ORIG_DIR"
    rm -rf "$BATS_TEST_DIR"
}


# Creates a mock 'gh' command that records its arguments.
# The path to the mock bin is prepended to PATH.
# The arguments are written to MOCK_GH_ARGS_FILE.
setup_mock_gh() {
    MOCK_BIN_DIR=$(mktemp -d)
    export MOCK_GH_ARGS_FILE
    MOCK_GH_ARGS_FILE=$(mktemp)
    
    cat <<-'EOF' > "$MOCK_BIN_DIR/gh"
#!/bin/bash
echo "$@" > "$MOCK_GH_ARGS_FILE"
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/gh"
    export PATH="$MOCK_BIN_DIR:$PATH"
}

teardown_mock_gh() {
    rm -rf "$MOCK_BIN_DIR"
    rm -f "$MOCK_GH_ARGS_FILE"
}
