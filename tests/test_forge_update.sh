#!/usr/bin/env bats

load 'helpers'

setup() {
    setup_test_dir
    setup_framework_repo
}

teardown() {
    teardown_framework_repo
    teardown_test_dir
}

@test "update: replaces existing codex" {
    # First, init a project with an old codex
    mkdir -p codex
    echo "Codex Version: 0.0.1" > codex/README.md
    echo "old rule" > codex/rules.md

    # Now, run update (without backup)
    run bash -c "echo 'N' | $FORGE_SCRIPT update"
    
    [ "$status" -eq 0 ]
    [ -f "codex/README.md" ]
    [[ "$(cat codex/README.md)" == *"Codex Version: 0.1.0"* ]]
    [ ! -d "codex.bak" ]
}

@test "update: creates a backup when user says yes" {
    mkdir -p codex
    echo "Codex Version: 0.0.1" > codex/README.md
    echo "old rule" > codex/rules.md

    # Run update and say 'y' to backup
    run bash -c "echo 'y' | $FORGE_SCRIPT update"

    [ "$status" -eq 0 ]
    [ -d "codex.bak" ]
    [ -f "codex.bak/README.md" ]
    [[ "$(cat codex.bak/README.md)" == *"Codex Version: 0.0.1"* ]]
    [[ "$(cat codex/README.md)" == *"Codex Version: 0.1.0"* ]]
}

@test "update: does not create backup when user says no" {
    mkdir -p codex
    echo "Codex Version: 0.0.1" > codex/README.md

    # Run update and say 'N' to backup
    run bash -c "echo 'N' | $FORGE_SCRIPT update"

    [ "$status" -eq 0 ]
    [ ! -d "codex.bak" ]
    [[ "$(cat codex/README.md)" == *"Codex Version: 0.1.0"* ]]
}
