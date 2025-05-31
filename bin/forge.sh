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

    # Copy codex folder
    if [ -d "$TEMP_DIR/$CODEX_DIR" ]; then
        log_info "Copying '$CODEX_DIR' folder to current directory..."
        # Remove existing codex dir first to ensure clean overwrite, then copy.
        if [ -d "./$CODEX_DIR" ]; then
            log_info "Removing existing './$CODEX_DIR' before copying."
            rm -rf "./$CODEX_DIR"
        fi
        cp -R "$TEMP_DIR/$CODEX_DIR" "./$CODEX_DIR"
        log_info "'$CODEX_DIR' folder copied successfully."
    else
        log_info "No '$CODEX_DIR' folder found in fetched files. Skipping copy."
    fi

    # Create lore directory if it doesn't exist
    if [ ! -d "./$LORE_DIR" ]; then
        log_info "Creating './$LORE_DIR' directory..."
        mkdir -p "./$LORE_DIR"
        log_info "'./$LORE_DIR' directory created."
    else
        log_info "'./$LORE_DIR' directory already exists. Skipping creation."
    fi

    # Copy lore/README.md
    local lore_readme_path_temp="$TEMP_DIR/$LORE_DIR/README.md"
    local lore_readme_path_project="./$LORE_DIR/README.md"
    if [ -f "$lore_readme_path_temp" ]; then
        if [ ! -f "$lore_readme_path_project" ]; then
            log_info "Copying '$LORE_DIR/README.md' to './$LORE_DIR'..."
            cp "$lore_readme_path_temp" "$lore_readme_path_project"
            log_info "'$LORE_DIR/README.md' copied successfully."
        else
            log_info "'./$LORE_DIR/README.md' already exists. Skipping copy."
        fi
    else
        log_info "No '$LORE_DIR/README.md' found in fetched files. Skipping copy."
    fi

    # Create saga directory if it doesn't exist
    if [ ! -d "./$SAGA_DIR" ]; then
        log_info "Creating './$SAGA_DIR' directory..."
        mkdir -p "./$SAGA_DIR"
        log_info "'./$SAGA_DIR' directory created."
    else
        log_info "'./$SAGA_DIR' directory already exists. Skipping creation."
    fi

    # Copy saga/README.md
    local saga_readme_path_temp="$TEMP_DIR/$SAGA_DIR/README.md"
    local saga_readme_path_project="./$SAGA_DIR/README.md"
    if [ -f "$saga_readme_path_temp" ]; then
        if [ ! -f "$saga_readme_path_project" ]; then
            log_info "Copying '$SAGA_DIR/README.md' to './$SAGA_DIR'..."
            cp "$saga_readme_path_temp" "$saga_readme_path_project"
            log_info "'$SAGA_DIR/README.md' copied successfully."
        else
            log_info "'./$SAGA_DIR/README.md' already exists. Skipping copy."
        fi
    else
        log_info "No '$SAGA_DIR/README.md' found in fetched files. Skipping copy."
    fi

    log_info "Forge init process completed successfully."
}

# --- Update Command Functions ---

# Function to handle the update command logic
run_update() {
    check_git_installed
    # TEMP_DIR is global and will be set here for cleanup by the existing trap
    TEMP_DIR=$(mktemp -d)
    if [ -z "$TEMP_DIR" ]; then
        log_error "Failed to create temporary directory for update."
    fi
    trap cleanup_temp_dir EXIT INT TERM # Ensure trap is set for this function's scope

    log_info "Fetching latest '$CODEX_DIR' from $AI_FORGE_REPO_URL into $TEMP_DIR..."

    if git archive --remote="$AI_FORGE_REPO_URL" HEAD "$CODEX_DIR" | tar -x -C "$TEMP_DIR"; then
        log_info "Successfully fetched '$CODEX_DIR'."
        if [ -d "$TEMP_DIR/$CODEX_DIR" ]; then
            ls "$TEMP_DIR/$CODEX_DIR" # List contents of fetched codex for confirmation
        else
            log_error "Fetched archive, but '$CODEX_DIR' not found within it."
        fi
    else
        log_error "Failed to fetch '$CODEX_DIR' from repository."
    fi

    # Subsequent tasks will handle backup, replacement, version check, and cleanup.

    local backup_confirmed=""
    if [ -d "./$CODEX_DIR" ]; then # Only ask if there's something to back up
        read -r -p "Do you want to back up the existing '$CODEX_DIR' folder? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            backup_confirmed="yes"
            local backup_dir="${CODEX_DIR}.bak"
            log_info "Backing up existing './$CODEX_DIR' to './$backup_dir'..."
            if [ -d "./$backup_dir" ]; then
                log_info "Removing existing backup directory './$backup_dir'..."
                rm -rf "./$backup_dir"
            fi
            cp -R "./$CODEX_DIR" "./$backup_dir"
            log_info "Backup complete: './$CODEX_DIR' copied to './$backup_dir'."
        else
            log_info "Skipping backup of existing '$CODEX_DIR'."
        fi
    fi

    if [ -d "$TEMP_DIR/$CODEX_DIR" ]; then
        log_info "Replacing './$CODEX_DIR' with the fetched version..."
        if [ -d "./$CODEX_DIR" ]; then
            rm -rf "./$CODEX_DIR" # Remove current codex before copying new one
        fi
        cp -R "$TEMP_DIR/$CODEX_DIR" "./$CODEX_DIR"
        log_info "'./$CODEX_DIR' has been updated."
    else
        # This case should ideally be caught earlier by the fetch logic,
        # but as a safeguard:
        log_error "Fetched '$CODEX_DIR' not found in temporary directory. Update aborted before replacement."
    fi
    
    log_info "Forge update process completed successfully."
}

# --- Suggest Changes Command Functions ---

check_gh_installed() {
    if ! command -v gh &> /dev/null; then
        log_info "GitHub CLI 'gh' is not installed. Some operations like automatic PR creation will be affected."
        log_info "Please install gh from https://cli.github.com/ for the best experience."
        return 1 # Indicates gh is not installed
    fi
    return 0 # Indicates gh is installed
}

# Function to handle the suggest-changes command logic
run_suggest_changes() {
    # Content to be re-implemented based on revised tasks
    log_info "Executing 'suggest-changes' command..."

    local pr_title
    while true; do
        read -r -p "Enter the title for your Pull Request: " pr_title
        if [ -n "$pr_title" ]; then
            break
        else
            log_info "PR title cannot be empty. Please try again."
        fi
    done
    log_info "PR Title entered: '$pr_title'"

    local pr_body_lines=()
    local line
    log_info "Enter the body for your Pull Request (leave an empty line to finish):"
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            break
        fi
        pr_body_lines+=("$line")
    done
    local pr_body
    while true; do
        # Join array elements with newline
        printf -v pr_body '%s\n' "${pr_body_lines[@]}"
        # Remove trailing newline if present from printf
        pr_body="${pr_body%\\n}"
        
        if [ -n "$pr_body" ]; then # Check if body is non-empty
            break
        else
            log_info "PR body cannot be empty. Please enter at least one line for the body."
            # Reset for re-prompting
            pr_body_lines=() 
            log_info "Enter the body for your Pull Request (leave an empty line to finish):"
            while IFS= read -r line; do
                if [ -z "$line" ]; then
                    break
                fi
                pr_body_lines+=("$line")
            done
        fi
    done
    log_info "PR Body entered." # Not logging the body itself to keep logs concise

    local user_fork
    while true; do
        read -r -p "Enter your GitHub fork name (e.g., username/ai-forge): " user_fork
        if [ -z "$user_fork" ]; then
            log_info "GitHub fork name cannot be empty. Please try again."
            continue
        fi

        # Validate format: owner/repo
        if ! [[ "$user_fork" =~ ^[a-zA-Z0-9-]+/[a-zA-Z0-9_.-]+$ ]]; then
            log_info "Invalid GitHub fork name format. Expected 'owner/repo'."
            log_info "Owner and repo names can contain alphanumeric characters and hyphens."
            log_info "Repo names can additionally contain underscores and periods."
            log_info "Example: 'your-username/ai-forge-fork'. Please try again."
            continue
        fi
        
        # Further check: ensure owner and repo parts are not empty (covered by regex for non-empty before/after slash)
        # The regex ^[a-zA-Z0-9-]+/[a-zA-Z0-9_.-]+$ ensures:
        # 1. Owner part: one or more alphanumeric or hyphen.
        # 2. Repo part: one or more alphanumeric, underscore, period, or hyphen.
        # This implicitly checks that neither part is empty and that there's exactly one slash.

        break # Valid format
    done
    log_info "User fork entered: '$user_fork'"

    # Further implementation will follow in subsequent tasks.
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
        run_update "$@" # Pass any further arguments if update were to accept them
        ;;
    suggest-changes)
        run_suggest_changes "$@"
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
