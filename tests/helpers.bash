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
    if [ -f "$CREATED_PR_URL_FILE" ]; then
        local pr_url
        pr_url=$(cat "$CREATED_PR_URL_FILE")
        if [ -n "$pr_url" ];
        then
            echo "INFO: Cleaning up PR: $pr_url"
            # Close the PR without prompting for confirmation
            if gh pr view "$pr_url" > /dev/null 2>&1; then
                gh pr close "$pr_url" --comment "Closed for cleanup after automated test." || echo "WARN: Failed to close PR $pr_url. It may need manual cleanup."
            else
                echo "WARN: PR $pr_url not found. It might have been closed already."
            fi
        fi
        rm -f "$CREATED_PR_URL_FILE"
    fi
}

# --- Live Fork Helpers for suggest-changes tests ---

# Holds the name of the fork created for the test, e.g. "myuser/ai-forge-test-fork-123"
export AI_FORGE_LIVE_TEST_FORK=""

# Creates a temporary, live fork of the ai-forge repo for testing suggest-changes.
setup_live_fork() {
    if ! gh auth status &> /dev/null; then
        # This will be checked in the test's setup, but good to have here too.
        echo "ERROR: GitHub CLI 'gh' is not authenticated. Cannot create a live fork for testing."
        return 1
    fi
    
    local user
    user=$(gh api user --jq .login)
    if [ -z "$user" ]; then
        echo "ERROR: Could not determine GitHub username via 'gh api user'."
        return 1
    fi

    local fork_basename="ai-forge-test-fork-$(date +%s)"
    AI_FORGE_LIVE_TEST_FORK="$user/$fork_basename"

    echo "INFO: Creating temporary live fork: $AI_FORGE_LIVE_TEST_FORK"
    if ! gh repo fork MarcelDanz/ai-forge --clone=false --fork-name "$fork_basename"; then
        echo "ERROR: Failed to create fork $AI_FORGE_LIVE_TEST_FORK"
        # Reset variable on failure
        AI_FORGE_LIVE_TEST_FORK=""
        return 1
    fi
    
    # Give GitHub a moment to process the fork creation.
    sleep 5
}

# Cleans up the temporary fork created by setup_live_fork.
teardown_live_fork() {
    if [ -n "$AI_FORGE_LIVE_TEST_FORK" ]; then
        echo "INFO: Deleting temporary live fork: $AI_FORGE_LIVE_TEST_FORK"
        # Use --yes to skip interactive confirmation.
        if ! gh repo delete "$AI_FORGE_LIVE_TEST_FORK" --yes; then
            echo "WARN: Failed to delete fork $AI_FORGE_LIVE_TEST_FORK. It may require manual cleanup."
        fi
        AI_FORGE_LIVE_TEST_FORK=""
    fi
}
