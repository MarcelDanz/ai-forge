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


# Creates a bare git repository to act as the user's fork for testing.
# This allows testing the push logic without network access.
# The path to this repo is used to set AI_FORGE_FORK_URL_OVERRIDE.
setup_test_fork_repo() {
    # The fork repo will be created inside the main test directory
    # so it gets cleaned up automatically by teardown_test_dir.
    local fork_repo_path
    fork_repo_path="$BATS_TEST_DIR/ai-forge-fork.git"
    
    git init --quiet --bare "$fork_repo_path"
    
    # This environment variable is used by the forge script to override the remote URL.
    export AI_FORGE_FORK_URL_OVERRIDE="$fork_repo_path"
}
