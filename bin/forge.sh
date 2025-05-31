#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# The official AI Forge framework repository
AI_FORGE_REPO_URL="https://github.com/MarcelDanz/ai-forge.git"
CODEX_DIR="codex"
LORE_DIR="lore"
SAGA_DIR="saga"

# --- Helper Functions ---

# Function to print usage information
usage() {
    echo "Usage: forge <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init           Initialize a new project with AI Forge components (codex, lore/README.md, saga/README.md)."
    echo "  update         Update the project's codex from the AI Forge framework."
    echo "  suggest-changes Propose changes from the project's codex back to the AI Forge framework."
    echo "  help           Show this help message or help for a specific command."
    echo ""
    echo "Run 'forge help <command>' for more information on a specific command."
    exit 1
}

# Function for logging messages
log_info() {
    echo "INFO: $1"
}

log_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to check if git is installed
check_git_installed() {
    if ! command -v git &> /dev/null; then
        log_error "git is not installed. Please install git to continue."
    fi
}

# --- Init Command Functions ---
TEMP_DIR="" # Global for cleanup trap

cleanup_temp_dir() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        log_info "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Function to handle the init command logic
run_init() {
    check_git_installed
    TEMP_DIR=$(mktemp -d)
    # Ensure TEMP_DIR is set for the trap, even if mktemp fails (though set -e handles mktemp failure)
    if [ -z "$TEMP_DIR" ]; then
        log_error "Failed to create temporary directory."
    fi
    trap cleanup_temp_dir EXIT INT TERM

    log_info "Fetching required files from $AI_FORGE_REPO_URL into $TEMP_DIR..."

    # Paths to fetch from the repository
    local paths_to_fetch="$CODEX_DIR lore/README.md saga/README.md"

    if git archive --remote="$AI_FORGE_REPO_URL" HEAD $paths_to_fetch | tar -x -C "$TEMP_DIR"; then
        log_info "Successfully fetched files:"
        # List fetched top-level items in TEMP_DIR for confirmation
        ls "$TEMP_DIR"
    else
        log_error "Failed to fetch files from repository. Check URL and repository contents."
        # trap will ensure cleanup_temp_dir is called
    fi

    # Subsequent tasks (1.4-1.8) will handle copying from $TEMP_DIR to the current directory.
    # For now, this task is complete once files are fetched.
    log_info "Files are ready in temporary directory for processing."
}

# --- Main Command Dispatch ---

# Check if any command is provided
if [ -z "$1" ]; then
    usage
fi

COMMAND="$1"
shift # Remove command from arguments, rest are options for the command

case "$COMMAND" in
    init)
        run_init "$@" # Pass any further arguments if init were to accept them
        ;;
    update)
        log_info "Executing 'update' command..."
        # Placeholder for update command logic
        # Source: saga/tasks-prd-ai-forge-cli-tool.md - Task 2.0
        echo "forge update command - To be implemented"
        ;;
    suggest-changes)
        log_info "Executing 'suggest-changes' command..."
        # Placeholder for suggest-changes command logic
        # Source: saga/tasks-prd-ai-forge-cli-tool.md - Task 3.0
        echo "forge suggest-changes command - To be implemented"
        ;;
    help)
        if [ -n "$1" ]; then
            # Detailed help for a specific command
            case "$1" in
                init)
                    echo "Usage: forge init"
                    echo ""
                    echo "Initializes the current directory with AI Forge components:"
                    echo "  - Fetches and overwrites the '$CODEX_DIR' folder."
                    echo "  - Creates '$LORE_DIR' and '$SAGA_DIR' if they don't exist."
                    echo "  - Copies '$LORE_DIR/README.md' and '$SAGA_DIR/README.md' from the framework,"
                    echo "    without overwriting if they already exist."
                    ;;
                update)
                    echo "Usage: forge update"
                    echo ""
                    echo "Updates the project's '$CODEX_DIR' folder from the AI Forge framework."
                    echo "Prompts to back up the existing '$CODEX_DIR' to '$CODEX_DIR.bak'."
                    ;;
                suggest-changes)
                    echo "Usage: forge suggest-changes"
                    echo ""
                    echo "Proposes changes from the project's local '$CODEX_DIR' folder to the AI Forge framework."
                    echo "This involves:"
                    echo "  - Prompting for PR title, description, and your GitHub fork name."
                    echo "  - Automatically determining and applying a SemVer bump (PATCH or MINOR) to the Codex version."
                    echo "  - Pushing changes to your fork and attempting to create a Pull Request."
                    ;;
                *)
                    echo "Unknown command for help: $1"
                    usage
                    ;;
            esac
        else
            usage
        fi
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        usage
        ;;
esac

exit 0
