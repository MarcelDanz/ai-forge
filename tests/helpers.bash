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


# Placeholder for PR URL created during a test run
export CREATED_PR_URL_FILE

# Cleans up a pull request created during a test run.
# This function should be called from the teardown function of a test file.
teardown_pr() {
    if [ ! -f "$CREATED_PR_URL_FILE" ]; then
        return
    fi
    local pr_url
    pr_url=$(cat "$CREATED_PR_URL_FILE")
    rm -f "$CREATED_PR_URL_FILE"
    if [ -z "$pr_url" ]; then
        return
    fi

    echo "INFO: Cleaning up PR: $pr_url"
    if gh pr view "$pr_url" > /dev/null 2>&1; then
        gh pr close "$pr_url" --comment "Closed automatically after test run." || echo "WARN: Failed to close PR $pr_url."
    else
        echo "WARN: PR $pr_url not found, can't clean up."
    fi
}
