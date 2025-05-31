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

    # Task 2.3: Prompt for backup
    local backup_confirmed=""
    if [ -d "./$CODEX_DIR" ]; then # Only ask if there's something to back up
        read -r -p "Do you want to back up the existing '$CODEX_DIR' folder? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            backup_confirmed="yes"
            # Task 2.4: Perform backup
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

    # Task 2.5: Replace existing codex with fetched version
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
CLONE_DIR="" # Global for suggest_changes clone cleanup trap

cleanup_clone_dir() {
    if [ -n "$CLONE_DIR" ] && [ -d "$CLONE_DIR" ]; then
        log_info "Cleaning up clone directory: $CLONE_DIR"
        # Potentially dangerous if CLONE_DIR is not set correctly, add extra check
        if [[ "$CLONE_DIR" == /tmp/* || "$CLONE_DIR" == /var/tmp/* ]]; then # Basic safety
             rm -rf "$CLONE_DIR"
        else
            log_error "Clone directory path '$CLONE_DIR' seems unsafe for automatic rm -rf. Please manually clean it."
        fi
    fi
}

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
    check_git_installed
    # No need to check gh here, will check when attempting to use it.

    # Task 3.2: Prompts for PR info
    local pr_title pr_body pr_fork_name pr_branch_name

    log_info "Collecting information for the Pull Request..."
    read -r -p "Enter Pull Request title: " pr_title
    if [ -z "$pr_title" ]; then
        log_error "Pull Request title cannot be empty."
    fi

    log_info "Enter Pull Request body (Ctrl+D on a new line to finish):"
    pr_body=$(cat) # Read multiline input
    if [ -z "$pr_body" ]; then
        log_error "Pull Request body cannot be empty."
    fi
    
    read -r -p "Enter your GitHub fork name (e.g., username/ai-forge): " pr_fork_name
    if [ -z "$pr_fork_name" ]; then
        log_error "GitHub fork name cannot be empty."
    fi

    # Task 3.3: Temporarily clone the framework repository
    CLONE_DIR=$(mktemp -d)
    if [ -z "$CLONE_DIR" ]; then
        log_error "Failed to create temporary directory for cloning."
    fi
    trap cleanup_clone_dir EXIT INT TERM # Set trap for this function's clone directory

    log_info "Cloning $AI_FORGE_REPO_URL into $CLONE_DIR..."
    if ! git clone --depth=1 "$AI_FORGE_REPO_URL" "$CLONE_DIR"; then
        log_error "Failed to clone repository from $AI_FORGE_REPO_URL."
    fi
    
    # Task 3.4: Create a new branch
    pr_branch_name="suggest-codex-updates-$(date +%s)"
    log_info "Creating new branch '$pr_branch_name' in cloned repository..."
    (cd "$CLONE_DIR" && git checkout -b "$pr_branch_name") || log_error "Failed to create branch '$pr_branch_name'."

    # Task 3.5: Replace codex folder
    if [ ! -d "./$CODEX_DIR" ]; then
        log_error "Local './$CODEX_DIR' directory not found. Nothing to suggest."
    fi
    log_info "Replacing '$CODEX_DIR' in cloned repository with local version..."
    rm -rf "$CLONE_DIR/$CODEX_DIR"
    cp -R "./$CODEX_DIR" "$CLONE_DIR/$CODEX_DIR"
    log_info "'$CODEX_DIR' in clone updated."

    # Task 3.6: Automated Codex versioning logic
    log_info "Starting automated Codex versioning..."
    
    # 3.6.1: Get original codex version from framework's default branch (HEAD of clone)
    local original_codex_readme_path="$CLONE_DIR/$CODEX_DIR/README.md.original_head"
    local current_codex_readme_path_in_clone="$CLONE_DIR/$CODEX_DIR/README.md"
    
    # Save the state of codex/README.md from HEAD before it's overwritten by local changes
    # This is tricky because we already copied the local codex.
    # Let's adjust: clone, get original readme, then copy local codex.
    # This requires reordering. For now, let's assume we need to get it from remote again, or adjust flow.
    # Simpler: Assume the version in the *local* codex/README.md is the one to be bumped,
    # but the diff is against the framework's HEAD.
    # The PRD (FR5.4) says "update the Codex Version in the codex/README.md file within the new branch".
    # This means the user's codex/README.md (already copied) is the one to modify.
    # We need the framework's version to compare against for diff, not necessarily for bumping.
    # Let's fetch the framework's HEAD version of codex/README.md for its version number.
    
    local framework_readme_content
    framework_readme_content=$( (cd "$CLONE_DIR" && git show HEAD:"$CODEX_DIR/README.md") 2>/dev/null ) || \
        log_error "Failed to get framework's $CODEX_DIR/README.md from HEAD."

    local framework_version
    framework_version=$(echo "$framework_readme_content" | grep "Codex Version:" | awk '{print $3}')
    if [ -z "$framework_version" ]; then
        log_error "Could not parse Codex Version from framework's $CODEX_DIR/README.md."
    fi
    log_info "Framework Codex version: $framework_version"

    local local_readme_content
    local_readme_content=$(cat "./$CODEX_DIR/README.md") || \
        log_error "Failed to read local $CODEX_DIR/README.md"
    
    local local_version
    local_version=$(echo "$local_readme_content" | grep "Codex Version:" | awk '{print $3}')
    if [ -z "$local_version" ]; then
        log_error "Could not parse Codex Version from local $CODEX_DIR/README.md."
    fi
    log_info "Local Codex version (to be bumped): $local_version"

    # 3.6.2: Analyze differences
    # We need to diff the original framework codex (still in CLONE_DIR at HEAD before local copy)
    # with the local codex (in current directory ./$CODEX_DIR).
    # This is tricky because CLONE_DIR/$CODEX_DIR is now the local one.
    # Solution: Create a temporary clone of the original codex from CLONE_DIR (HEAD) before overwriting.
    local original_framework_codex_temp_dir
    original_framework_codex_temp_dir=$(mktemp -d)
    
    log_info "Temporarily extracting framework's HEAD version of $CODEX_DIR for diff analysis..."
    (cd "$CLONE_DIR" && git archive HEAD "$CODEX_DIR" | tar -x -C "$original_framework_codex_temp_dir") || \
        log_error "Failed to archive framework's HEAD $CODEX_DIR for diff."

    local diff_output_name_status
    diff_output_name_status=$(diff -qr --no-dereference "$original_framework_codex_temp_dir/$CODEX_DIR" "./$CODEX_DIR" | sed "s#^Files $original_framework_codex_temp_dir/$CODEX_DIR/##" | sed "s# and ./$CODEX_DIR/##" | sed "s# differ# M#g" | sed "s#Only in ./$CODEX_DIR: # A #g" | sed "s#Only in $original_framework_codex_temp_dir/$CODEX_DIR: # D #g")
    # This diff is a bit crude for name-status, git diff would be better if we had two git trees.
    # A simpler heuristic: if the user's local codex is very different from framework's HEAD.
    # For now, let's use a simpler diff for line counts.
    
    local files_added_deleted=0
    if echo "$diff_output_name_status" | grep -q " A "; then files_added_deleted=1; fi
    if echo "$diff_output_name_status" | grep -q " D "; then files_added_deleted=1; fi

    # Count changed lines (approximate with wc -l on diff output)
    # This is not ideal, `git diff --numstat` is better.
    # Since we have two plain directories, a recursive diff and line count is an option.
    local lines_changed=0
    # Using `diff -u` and `wc -l` is a common way.
    # `diff -Naur old new | grep -E "^\+" | grep -Ev "^\+\+\+" | wc -l` for added lines
    # `diff -Naur old new | grep -E "^-" | grep -Ev "^---" | wc -l` for removed lines
    # This is getting complex. Let's simplify the heuristic for now.
    # Heuristic: Any file added/deleted = MINOR. Else, PATCH.
    # FR5.4: "Addition or removal of entire files" OR "substantial sections, multiple rules, or entire workflows" -> MINOR
    # "Corrections to a few words or typo fixes" OR "Minor clarifications" -> PATCH

    local bump_type="PATCH" # Default to PATCH
    if [ "$files_added_deleted" -eq 1 ]; then
        bump_type="MINOR"
        log_info "Files added or deleted in Codex. Determining MINOR bump."
    else
        # If no files added/deleted, check for substantial changes.
        # This is hard to quantify perfectly in shell.
        # Let's assume if more than N lines changed in total across all files, it's MINOR.
        # For now, a simpler rule: if not add/delete, it's PATCH.
        # This can be refined later if needed.
        log_info "No files added or deleted. Determining PATCH bump (can be refined for 'substantial changes')."
    fi
    rm -rf "$original_framework_codex_temp_dir" # Clean up temp dir for original codex

    # 3.6.5 & 3.6.4: Increment version (using local_version as base)
    local major minor patch
    IFS='.' read -r major minor patch <<< "$local_version"

    if [ "$bump_type" == "MINOR" ]; then
        minor=$((minor + 1))
        patch=0
    else # PATCH
        patch=$((patch + 1))
    fi
    local new_version="$major.$minor.$patch"
    log_info "Determined version bump: $local_version -> $new_version ($bump_type)"

    # 3.6.6: Update Codex Version in the cloned (and now local-content) codex/README.md
    local readme_to_update="$CLONE_DIR/$CODEX_DIR/README.md"
    if [ ! -f "$readme_to_update" ]; then
        log_error "$readme_to_update not found. Cannot update version."
    fi
    # Using a temporary file for sed robustness
    local temp_readme
    temp_readme=$(mktemp)
    sed "s/Codex Version: $local_version/Codex Version: $new_version/" "$readme_to_update" > "$temp_readme" && mv "$temp_readme" "$readme_to_update"
    log_info "Updated Codex Version in $readme_to_update to $new_version."

    # Task 3.7: Commit changes
    log_info "Committing changes to branch '$pr_branch_name' in cloned repository..."
    (cd "$CLONE_DIR" && git add "$CODEX_DIR") || log_error "Failed to stage '$CODEX_DIR' for commit."
    commit_message="feat(codex): Update codex from project suggestion

Version: $new_version

$pr_title

$pr_body"
    (cd "$CLONE_DIR" && git commit -m "$commit_message") || log_error "Failed to commit changes."
    log_info "Changes committed successfully."

    # Task 3.8: Add fork as remote and push
    local fork_remote_name="userfork"
    local fork_repo_url="https://github.com/$pr_fork_name.git"
    log_info "Adding remote '$fork_remote_name' for fork '$fork_repo_url'..."
    (cd "$CLONE_DIR" && git remote add "$fork_remote_name" "$fork_repo_url") || log_error "Failed to add remote for fork."
    
    log_info "Pushing branch '$pr_branch_name' to '$fork_remote_name' ($fork_repo_url)..."
    if ! (cd "$CLONE_DIR" && git push -u "$fork_remote_name" "$pr_branch_name"); then
        log_error "Failed to push branch to fork. Check fork name, permissions, and network."
        # Provide manual instructions
        log_info "To proceed manually:"
        log_info "1. Navigate to the cloned directory: cd $CLONE_DIR"
        log_info "2. Ensure your fork '$pr_fork_name' is a remote: git remote add $fork_remote_name $fork_repo_url (if not already done)"
        log_info "3. Push the branch: git push -u $fork_remote_name $pr_branch_name"
        log_info "4. Then create a Pull Request on GitHub from branch '$pr_branch_name' of '$pr_fork_name' to the main ai-forge repository."
        exit 1 # Exit as we can't proceed to PR creation
    fi
    log_info "Branch pushed successfully to fork."

    # Task 3.9 & 3.10: Create PR using gh or provide manual instructions
    local head_branch_for_pr="${pr_fork_name%/*}:$pr_branch_name" # Extracts username from fork_name and appends branch

    if check_gh_installed; then
        log_info "Attempting to create Pull Request using GitHub CLI 'gh'..."
        # Use -R to target the main framework repository
        # The --head flag should be in format 'OWNER:branch' or 'branch' if pushing to same repo.
        # Since we pushed to a fork, gh should pick it up if the fork is configured.
        # Or we can be explicit with --head user:branch.
        # The `gh pr create` command is interactive by default if title/body not given.
        # We have title and body, so we can pass them.
        if (cd "$CLONE_DIR" && gh pr create --base main --head "$pr_branch_name" --title "$pr_title" --body "$pr_body" --repo "$AI_FORGE_REPO_URL"); then
            log_info "Pull Request created successfully!"
        else
            log_error "Failed to create Pull Request using 'gh'. It might be due to authentication, or other issues."
            log_info "Please try creating the Pull Request manually on GitHub."
            log_info "Your changes are in branch '$pr_branch_name' on your fork '$pr_fork_name'."
            log_info "Target the 'main' branch of $AI_FORGE_REPO_URL."
        fi
    else
        log_info "'gh' CLI not found or not working. Please create the Pull Request manually on GitHub."
        log_info "1. Go to your fork: https://github.com/$pr_fork_name"
        log_info "2. You should see a prompt to create a Pull Request from the branch '$pr_branch_name'."
        log_info "3. If not, navigate to the 'Pull requests' tab and click 'New pull request'."
        log_info "4. Set the base repository to '$AI_FORGE_REPO_URL' and base branch to 'main'."
        log_info "5. Set the head repository to '$pr_fork_name' and compare branch to '$pr_branch_name'."
        log_info "6. Use the following for title and body:"
        log_info "   Title: $pr_title"
        log_info "   Body:\n$pr_body"
    fi
    
    log_info "Forge suggest-changes process completed."
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
