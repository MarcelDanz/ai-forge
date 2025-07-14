#!/usr/bin/env bats

load 'helpers'

setup() {
    setup_test_dir
    setup_test_fork_repo
}

teardown() {
    teardown_test_dir
}

@test "suggest-changes: pushes changes to a local fork repo" {
    # Init a repo to get a codex to modify
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]

    # Modify the codex to create a diff
    echo "## New Automated Test Rule" >> codex/rules/README.md

    # Prepare inputs for the command
    local pr_title="[TEST] Automated local PR"
    local pr_body="This is an automated test PR."
    # This fork name is prompted for, but AI_FORGE_FORK_URL_OVERRIDE takes precedence
    local user_fork="testuser/ai-forge-fork" 
    
    local input
    # The final blank line in the body input is to finish the multiline prompt
    printf -v input "%s\n%s\n\n%s\ny\n" "$pr_title" "$pr_body" "$user_fork"

    # Run the command and capture the output
    run bash -c "echo -e '$input' | $FORGE_SCRIPT suggest-changes"

    # The command should succeed overall by printing manual instructions, even if gh fails
    [ "$status" -eq 0 ]
    
    # Verify that the new branch was pushed to our local bare repo
    local fork_repo_path="$AI_FORGE_FORK_URL_OVERRIDE"
    local branches
    branches=$(git --git-dir="$fork_repo_path" branch)
    
    # Check that a branch with the correct prefix exists
    [[ "$branches" == *"suggest-codex-"* ]]

    # If gh is installed, the script will try and fail to create a PR, printing an error.
    # If not, it will just print the manual instructions. Both are valid outcomes.
    if command -v gh &> /dev/null; then
        [[ "$output" == *"Failed to create Pull Request using 'gh'"* ]]
    fi

    # Verify that the manual instructions are printed
    [[ "$output" == *"MANUAL ACTION REQUIRED"* ]]
    [[ "$output" == *"https://github.com/MarcelDanz/ai-forge/compare/main..."* ]]
}
