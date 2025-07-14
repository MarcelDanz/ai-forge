# BATS test helpers

# Make the forge script available to the tests
export FORGE_SCRIPT
FORGE_SCRIPT="$(pwd)/bin/forge.sh"

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

# Creates a temporary git repository to act as the AI Forge framework remote.
# The path to this repo is stored in the global FRAMEWORK_REPO_DIR variable.
# The AI_FORGE_REPO_URL environment variable is set to this path.
setup_framework_repo() {
    FRAMEWORK_REPO_DIR=$(mktemp -d)
    (
        cd "$FRAMEWORK_REPO_DIR"
        git init --quiet
        git config user.email "test@example.com"
        git config user.name "Test User"

        mkdir -p codex lore saga
        echo "Codex Version: 0.1.0" > codex/README.md
        echo "codex file" > codex/rules.md
        echo "lore readme" > lore/README.md
        echo "saga readme" > saga/README.md
        git add .
        git commit --quiet -m "Initial framework commit"
    )
    export AI_FORGE_REPO_URL="$FRAMEWORK_REPO_DIR"
}

# Cleans up the framework repo directory.
teardown_framework_repo() {
    rm -rf "$FRAMEWORK_REPO_DIR"
}

# Creates a temporary bare git repository to act as the user's fork.
# The path to this repo is stored in the global USER_FORK_REPO_DIR variable.
setup_user_fork_repo() {
    USER_FORK_REPO_DIR=$(mktemp -d)
    git init --quiet --bare "$USER_FORK_REPO_DIR"
}

teardown_user_fork_repo() {
    rm -rf "$USER_FORK_REPO_DIR"
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
