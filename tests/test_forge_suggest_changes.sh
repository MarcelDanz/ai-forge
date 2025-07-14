#!/usr/bin/env bats

load 'helpers'

setup() {
    setup_test_dir
    setup_mock_gh
}

teardown() {
    teardown_mock_gh
    teardown_test_dir
}

@test "suggest-changes: full successful run" {
    # Init a repo to get a codex to modify
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]

    # Modify the codex
    echo "## New Rule" >> codex/rules/README.md

    # Provide input for the prompts
    local pr_title="Test PR Title"
    local pr_body="Test PR Body"
    local user_fork="testuser/ai-forge-fork"
    
    local input
    printf -v input "%s\n%s\n\n%s\n" "$pr_title" "$pr_body" "$user_fork"

    run bash -c "echo -e '$input' | $FORGE_SCRIPT suggest-changes"
    [ "$status" -eq 0 ]
    
    # Check that gh was called with correct arguments
    local mock_gh_output
    mock_gh_output=$(cat "$MOCK_GH_ARGS_FILE")
    
    [[ "$mock_gh_output" == *"pr create"* ]]
    [[ "$mock_gh_output" == *"--repo https://github.com/MarcelDanz/ai-forge.git"* ]]
    [[ "$mock_gh_output" == *"--title $pr_title"* ]]
    [[ "$mock_gh_output" == *"--body $pr_body"* ]]
    [[ "$mock_gh_output" == *"--head ${user_fork%/*}:suggest-codex-"* ]]
}
