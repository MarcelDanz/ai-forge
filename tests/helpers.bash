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


# Placeholders for test artifacts that need to be cleaned up
export CREATED_PR_URL_FILE
export CREATED_FORK_REPO_FILE
export CREATED_BRANCH_NAME_FILE

# Cleans up a pull request and its remote branch created during a test run.
# This function should be called from the teardown function of a test file.
teardown_pr() {
    # Close PR if one was created
    if [ -f "$CREATED_PR_URL_FILE" ]; then
        local pr_url
        pr_url=$(cat "$CREATED_PR_URL_FILE")
        rm -f "$CREATED_PR_URL_FILE"

        if [ -n "$pr_url" ]; then
            echo "INFO: Cleaning up PR: $pr_url"
            if gh pr view "$pr_url" > /dev/null 2>&1; then
                gh pr close "$pr_url" --comment "Closed automatically after test run." || echo "WARN: Failed to close PR $pr_url."
            else
                echo "WARN: PR $pr_url not found, can't clean up."
            fi
        fi
    fi

    # Delete the remote branch from the fork
    if [ -f "$CREATED_FORK_REPO_FILE" ] && [ -f "$CREATED_BRANCH_NAME_FILE" ]; then
        local fork_owner_repo
        fork_owner_repo=$(cat "$CREATED_FORK_REPO_FILE")
        rm -f "$CREATED_FORK_REPO_FILE"

        local branch_name
        branch_name=$(cat "$CREATED_BRANCH_NAME_FILE")
        rm -f "$CREATED_BRANCH_NAME_FILE"

        if [ -n "$fork_owner_repo" ] && [ -n "$branch_name" ]; then
            echo "INFO: Deleting remote branch '$branch_name' from fork '$fork_owner_repo'..."
            local ref_path="heads/$branch_name"
            # Use `gh api` to delete the git ref (the branch)
            if ! gh api --method DELETE "repos/$fork_owner_repo/git/refs/$ref_path" > /dev/null; then
                 echo "WARN: Failed to delete remote branch '$branch_name' from fork. It may require manual cleanup."
            fi
        fi
    fi
}
