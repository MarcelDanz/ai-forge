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

# Function to extract Codex version from a README.md file
# $1: Path to the directory containing codex/README.md (e.g., "." or "$TEMP_DIR")
get_codex_version() {
    local dir_path="$1"
    local readme_path="$dir_path/$CODEX_DIR/README.md"
    if [ ! -f "$readme_path" ]; then
        log_error "Codex README not found at '$readme_path'."
    fi
    # Use grep and sed to extract the version number
    local version_line
    version_line=$(grep "Codex Version:" "$readme_path")
    if [ -z "$version_line" ]; then
        log_error "Could not find 'Codex Version:' line in '$readme_path'."
    fi
    # sed 's/.*Codex Version: \([0-9.]*\).*/\1/'
    local version
    version=$(echo "$version_line" | sed 's/.*Codex Version: //')
    if [ -z "$version" ]; then
        log_error "Could not parse version from line: '$version_line'"
    fi
    echo "$version"
}

# Function to compare two SemVer strings (e.g., 1.2.3 vs 1.3.0)
# Returns exit code:
#   0 if versions are equal
#   1 if version1 > version2
#   2 if version1 < version2
semver_compare() {
    local version1="$1"
    local version2="$2"

    # Using sort -V for version comparison. It handles different lengths correctly.
    local sorted_versions
    sorted_versions=$(printf "%s\n%s" "$version1" "$version2" | sort -V)
    
    local first_in_sort
    first_in_sort=$(echo "$sorted_versions" | head -n1)

    if [ "$version1" = "$version2" ]; then
        return 0 # equal
    elif [ "$version1" = "$first_in_sort" ]; then
        return 2 # v1 < v2
    else
        return 1 # v1 > v2
    fi
}

# Determines the version bump type (MINOR or PATCH) based on git diff.
# $1: Path to the temporary git repository
determine_bump_type() {
    local temp_repo_path="$1"
    local diff_stats
    local file_changes

    (
        cd "$temp_repo_path" || exit 1
        # Get summary of file changes (Added, Deleted, Modified) against the main branch
        file_changes=$(git diff --name-status main..HEAD -- "$CODEX_DIR")
        # Get summary of line changes
        diff_stats=$(git diff --shortstat main..HEAD -- "$CODEX_DIR")
    )

    # FR5.4: MINOR bump for file additions or removals.
    if echo "$file_changes" | grep -q -E '^[AD]\s'; then
        echo "MINOR"
        return
    fi

    # FR5.4: MINOR for substantial changes, PATCH for minor changes.
    # Heuristic: Use line count from --shortstat.
    if [ -z "$diff_stats" ]; then
        # This can happen if only file modes changed, or if there are no changes.
        # The no-change case is handled before this, but as a safeguard, default to PATCH.
        echo "PATCH"
        return
    fi

    local insertions
    insertions=$(echo "$diff_stats" | grep -o '[0-9]* insertion' | awk '{print $1}')
    local deletions
    deletions=$(echo "$diff_stats" | grep -o '[0-9]* deletion' | awk '{print $1}')
    
    local total_changes=0
    if [ -n "$insertions" ]; then
        total_changes=$((total_changes + insertions))
    fi
    if [ -n "$deletions" ]; then
        total_changes=$((total_changes + deletions))
    fi

    # Threshold for substantial change. Set to 10 lines based on FR5.4 interpretation.
    if [ "$total_changes" -gt 10 ]; then
        echo "MINOR"
    else
        echo "PATCH"
    fi
}

# Increments a SemVer string.
# $1: Full version string (e.g., 1.2.3)
# $2: Component to bump ("MINOR" or "PATCH")
bump_semver() {
    local version="$1"
    local component="$2"
    
    local major minor patch
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    patch=$(echo "$version" | cut -d. -f3)

    case "$component" in
        MINOR)
            minor=$((minor + 1))
            patch=0
            ;;
        PATCH)
            patch=$((patch + 1))
            ;;
        *)
            log_error "Invalid component for semver bump: $component"
            ;;
    esac
    echo "$major.$minor.$patch"
}

# Updates the Codex Version in the specified README.md file.
# $1: Path to the codex/README.md file
# $2: The new version string
update_codex_version_file() {
    local readme_path="$1"
    local new_version="$2"

    if [ ! -f "$readme_path" ]; then
        log_error "Cannot update version: README file not found at $readme_path"
    fi

    # Using sed to replace the version line. This approach with a temp file is portable (macOS/Linux).
    local temp_file
    temp_file=$(mktemp)
    sed "s/^\(Codex Version: \).*/\1$new_version/" "$readme_path" > "$temp_file" && mv "$temp_file" "$readme_path"
    
    # Check if replacement was successful
    if ! grep -q "Codex Version: $new_version" "$readme_path"; then
        log_error "Failed to update version in $readme_path"
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
        
        break # Valid format
    done
    log_info "User fork entered: '$user_fork'"

    check_git_installed

    # TEMP_DIR is global and will be set here for cleanup by the existing trap
    TEMP_DIR=$(mktemp -d)
    if [ -z "$TEMP_DIR" ]; then
        log_error "Failed to create temporary directory."
    fi
    trap cleanup_temp_dir EXIT INT TERM # Ensure trap is set for this function's scope

    log_info "Cloning framework repository from $AI_FORGE_REPO_URL into a temporary directory..."
    if ! git clone --depth=1 "$AI_FORGE_REPO_URL" "$TEMP_DIR"; then
        log_error "Failed to clone the repository. Please check the URL and your network connection."
    fi
    log_info "Repository cloned successfully into $TEMP_DIR"

    # --- Pre-change checks ---
    log_info "Performing pre-change checks..."

    # 3.4.4: Check if local ./codex directory exists
    if [ ! -d "./$CODEX_DIR" ]; then
        log_error "Local './$CODEX_DIR' directory not found. Nothing to suggest."
    fi
    if [ ! -f "./$CODEX_DIR/README.md" ]; then
        log_error "Local './$CODEX_DIR/README.md' not found. Cannot determine local codex version."
    fi

    # 3.4.1 & 3.4.2: Get framework and local codex versions
    local framework_version
    framework_version=$(get_codex_version "$TEMP_DIR")
    log_info "Framework codex version: $framework_version"

    local local_version
    local_version=$(get_codex_version ".")
    log_info "Local codex version: $local_version"

    # 3.4.3: Compare versions
    semver_compare "$local_version" "$framework_version"
    local comparison_result=$?

    if [ $comparison_result -eq 2 ]; then # local_version < framework_version
        log_error "Your local codex version ($local_version) is older than the framework's version ($framework_version)."
        log_error "Please run 'forge update' first, resolve any conflicts, and then try again."
    fi

    log_info "Pre-change checks passed."

    # --- Create new branch in temp repo ---
    local timestamp
    timestamp=$(date +%s)
    local new_branch_name="suggest-codex-updates-$timestamp"
    
    log_info "Creating new branch '$new_branch_name' in the temporary repository..."
    (
        cd "$TEMP_DIR" || exit 1
        if ! git checkout -b "$new_branch_name"; then
            log_error "Failed to create new branch '$new_branch_name' in $TEMP_DIR."
        fi
        log_info "Successfully created and switched to branch '$new_branch_name'."
    )

    # --- Apply and commit local codex changes ---
    log_info "Applying local codex changes to the temporary repository..."
    
    # Remove the old codex from the temp repo and copy the new one in
    rm -rf "$TEMP_DIR/$CODEX_DIR"
    cp -R "./$CODEX_DIR" "$TEMP_DIR/$CODEX_DIR"
    log_info "Local '$CODEX_DIR' copied to temporary repository."

    log_info "Committing codex changes..."
    (
        cd "$TEMP_DIR" || exit 1
        # Check if there are any changes to commit.
        # `git status --porcelain` will be empty if there are no changes.
        if [ -z "$(git status --porcelain)" ]; then
            log_info "No codex changes detected to commit. Your local codex might be identical to the framework's."
            # We already confirmed local version >= framework version.
            # If versions are equal and there are no changes, we could exit, but for now we'll continue.
            # This allows for suggesting changes even if the version hasn't been bumped locally.
        else
            git add "$CODEX_DIR"
            git commit -m "feat(codex): Apply local codex changes"
            log_info "Codex changes committed successfully."
        fi
    )

    # --- Determine and apply Codex version bump ---
    log_info "Determining required SemVer bump..."
    local bump_type
    bump_type=$(determine_bump_type "$TEMP_DIR")
    log_info "Change analysis suggests a '$bump_type' version bump."

    # Read current version from the file in the temp repo (which is the user's local version)
    local current_version
    current_version=$(get_codex_version "$TEMP_DIR")
    log_info "Current codex version is $current_version."

    # Increment version
    local new_version
    new_version=$(bump_semver "$current_version" "$bump_type")
    log_info "Bumping version to $new_version."

    # Update the README file in the temp repo
    local temp_readme_path="$TEMP_DIR/$CODEX_DIR/README.md"
    update_codex_version_file "$temp_readme_path" "$new_version"
    log_info "Updated version in '$CODEX_DIR/README.md'."

    # Commit the version bump
    log_info "Committing version bump..."
    (
        cd "$TEMP_DIR" || exit 1
        git add "$CODEX_DIR/README.md"
        git commit -m "chore(codex): Bump version to $new_version"
        log_info "Version bump committed successfully."
    )

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
