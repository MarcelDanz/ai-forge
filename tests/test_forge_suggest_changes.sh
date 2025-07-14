#!/usr/bin/env bats

load 'helpers'

setup() {
    setup_test_dir
    setup_framework_repo
    setup_user_fork_repo
    setup_mock_gh

    # Init a local project to suggest changes from
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]
}

teardown() {
    teardown_mock_gh
    teardown_user_fork_repo
    teardown_framework_repo
    teardown_test_dir
}

@test "suggest-changes: full successful run" {
    # Make a change to the local codex
    echo "new rule" >> codex/rules.md
    
    # Prepare user input for the prompts
    local pr_title="Test PR Title"
    local pr_body="Test PR Body"
    local user_fork="testuser/ai-forge-fork"
    
    local input
    printf -v input "%s\n%s\n\n%s\n" "$pr_title" "$pr_body" "$user_fork"

    # Override the fork URL to point to our local bare repo for testing
    export AI_FORGE_FORK_URL_OVERRIDE="$USER_FORK_REPO_DIR"

    run bash -c "echo -e '$input' | $FORGE_SCRIPT suggest-changes"

    [ "$status" -eq 0 ]
    # Check that the PR was created with gh
    [ -s "$MOCK_GH_ARGS_FILE" ]
    local gh_args
    gh_args=$(cat "$MOCK_GH_ARGS_FILE")
    [[ "$gh_args" == *"pr create"* ]]
    [[ "$gh_args" == *"--title $pr_title"* ]]
    [[ "$gh_args" == *"--body $pr_body"* ]]

    # Check that the user fork repo received the push
    local branch_exists
    branch_exists=$(git -C "$USER_FORK_REPO_DIR" branch --list 'suggest-codex-updates-*')
    [ -n "$branch_exists" ]
}

@test "suggest-changes: exits if local codex is older" {
    # Make framework version newer
    (
        cd "$FRAMEWORK_REPO_DIR"
        echo "Codex Version: 0.2.0" > codex/README.md
        git add codex/README.md
        git commit --quiet -m "Bump version"
    )

    run "$FORGE_SCRIPT" suggest-changes <<< $'title\nbody\nuser/repo\n'
    
    [ "$status" -eq 1 ]
    [[ "$output" == *"Your local codex version (0.1.0) is older than the framework's version (0.2.0)."* ]]
}

@test "suggest-changes: exits if no changes are detected" {
    # Run suggest-changes without making any changes to the codex
    local input
    printf -v input "%s\n%s\n\n%s\n" "Title" "Body" "user/repo"

    run bash -c "echo -e '$input' | $FORGE_SCRIPT suggest-changes"

    [ "$status" -eq 0 ]
    [[ "$output" == *"No codex changes detected to commit."* ]]
}
