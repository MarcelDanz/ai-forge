#!/usr/bin/env bats

load 'helpers'

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

@test "init: creates codex, lore, and saga directories" {
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]
    [ -d "codex" ]
    [ -d "lore" ]
    [ -d "saga" ]
}

@test "init: copies codex folder correctly" {
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]
    [ -f "codex/README.md" ]
    [ -f "codex/rules/README.md" ]
    [ -f "codex/workflows/README.md" ]
    [ -f "codex/behaviors/README.md" ]
    [ -f "codex/recipes/README.md" ]
    [[ "$(cat codex/README.md)" == *"Codex Version: 0.1.0"* ]]
}

@test "init: copies lore/README.md and saga/README.md" {
    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]
    [ -f "lore/README.md" ]
    [ -f "saga/README.md" ]
}

@test "init: does not overwrite existing lore/README.md or saga/README.md" {
    mkdir -p lore saga
    echo "existing lore" > lore/README.md
    echo "existing saga" > saga/README.md

    run "$FORGE_SCRIPT" init
    [ "$status" -eq 0 ]
    [ "$(cat lore/README.md)" = "existing lore" ]
    [ "$(cat saga/README.md)" = "existing saga" ]
}

@test "init: overwrites existing codex directory when confirmed" {
    mkdir -p codex
    echo "old codex" > codex/old_file.md

    run bash -c "echo 'y' | $FORGE_SCRIPT init"
    [ "$status" -eq 0 ]
    [ ! -f "codex/old_file.md" ]
    [ -f "codex/rules/README.md" ]
}

@test "init: does not overwrite existing codex if not confirmed" {
    mkdir -p codex
    echo "old codex" > codex/old_file.md
    mkdir -p codex/rules
    echo "old rules" > codex/rules/README.md

    run bash -c "echo 'n' | $FORGE_SCRIPT init"
    [ "$status" -eq 0 ]
    [ -f "codex/old_file.md" ]
    [ "$(cat codex/rules/README.md)" = "old rules" ]
    [[ "$output" == *"Overwrite not confirmed. Aborting init."* ]]
}
