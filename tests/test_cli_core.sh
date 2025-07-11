#!/usr/bin/env bats

load 'helpers'

@test "core: shows main help with --help" {
    run "$FORGE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: forge <command> [options]" ]
}

@test "core: shows main help with 'help'" {
    run "$FORGE_SCRIPT" help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: forge <command> [options]" ]
}

@test "core: shows help for 'init' command" {
    run "$FORGE_SCRIPT" init --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: forge init" ]
}

@test "core: shows help for 'update' command" {
    run "$FORGE_SCRIPT" update --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: forge update" ]
}

@test "core: shows help for 'suggest-changes' command" {
    run "$FORGE_SCRIPT" suggest-changes --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: forge suggest-changes" ]
}

@test "core: errors on unknown command" {
    run "$FORGE_SCRIPT" foobar
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "ERROR: Unknown command: 'foobar'" ]
}

@test "core: errors on unknown help topic" {
    run "$FORGE_SCRIPT" help foobar
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "ERROR: Unknown help topic: 'foobar'" ]
}
