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

# --- Main Command Dispatch ---

# Check if any command is provided
if [ -z "$1" ]; then
    usage
fi

COMMAND="$1"
shift # Remove command from arguments, rest are options for the command

case "$COMMAND" in
    init)
        log_info "Executing 'init' command..."
        # Placeholder for init command logic
        # Source: saga/tasks-prd-ai-forge-cli-tool.md - Task 1.0
        echo "forge init command - To be implemented"
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
