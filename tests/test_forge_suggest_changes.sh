#!/usr/bin/env bats

load 'helpers'

setup() {
    setup_test_dir

    # Ensure gh is installed and authenticated
    if ! gh auth status &> /dev/null; then
        skip "GitHub CLI 'gh' is not authenticated. Skipping live PR test."
    fi
    
    # The test will write the created PR URL to this file for cleanup
    CREATED_PR_URL_FILE="$BATS_TEST_DIR/created_pr_url.txt"
}

teardown() {
    teardown_pr
    teardown_test_dir
}

@test "suggest-changes: creates a real pull request" {
    # Init a repo to get a codex to modify
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]

    # Modify the codex to create a diff
    echo "## New Automated Test Rule" >> codex/rules/README.md

    # Prepare inputs for the command
    local pr_title="[TEST] Automated PR via forge suggest-changes"
    # Add a timestamp to the body to ensure it's unique
    local pr_body="This is an automated test PR created at $(date). It should be closed automatically."
    
    local input
    # Prepare an input file for the script prompts
    local input_file
    input_file=$(mktemp)

    # Input stream for the script:
    # 1. PR Title
    # 2. PR Body (multiline, terminated by an empty line)
    # 3. 'forge' confirmation for the suggested version bump ('y')
    # 4. `gh` prompt to create a fork ('y')
    printf "%s\n%s\n\n%s\n%s\n" "$pr_title" "$pr_body" "y" "y" > "$input_file"

    # Redirect input from the file, which is the most robust method for tests
    run "$FORGE_SCRIPT" suggest-changes < "$input_file"
    rm "$input_file"
    [ "$status" -eq 0 ]
    
    # Extract the PR URL from the output
    local pr_url
    pr_url=$(echo "$output" | grep -o 'https://github.com/fork-base/ai-forge/pull/[0-9]*' | head -n1)

    if [ -z "$pr_url" ]; then
        echo "Error: Could not extract PR URL from the command output."
        echo "Output was:"
        echo "$output"
        return 1
    fi

    # Write the PR URL to a file for teardown cleanup
    echo "$pr_url" > "$CREATED_PR_URL_FILE"

    # Verify the created PR's details using the gh CLI
    local pr_json
    pr_json=$(gh pr view "$pr_url" --json title,body,headRefName,state)
    [ "$?" -eq 0 ]

    # Assertions
    local created_title
    created_title=$(echo "$pr_json" | grep '"title"' | sed 's/.*"title": "\(.*\)".*/\1/')
    [ "$created_title" = "$pr_title" ]

    local created_body
    created_body=$(echo "$pr_json" | grep '"body"' | sed 's/.*"body": "\(.*\)".*/\1/')
    # Using contains because JSON escaping can be tricky
    [[ "$created_body" == *"$pr_body"* ]]

    local head_ref_name
    head_ref_name=$(echo "$pr_json" | grep '"headRefName"' | sed 's/.*"headRefName": "\(.*\)".*/\1/')
    [[ "$head_ref_name" == "suggest-codex-"* ]]

    local pr_state
    pr_state=$(echo "$pr_json" | grep '"state"' | sed 's/.*"state": "\(.*\)".*/\1/')
    [ "$pr_state" = "OPEN" ]
}
