## Relevant Files

- `bin/forge.sh`: Main executable shell script for the CLI tool. This script will handle subcommand routing.
- `bin/forge-init.sh`: (Optional) Script dedicated to `init` command logic.
- `bin/forge-update.sh`: (Optional) Script dedicated to `update` command logic.
- `bin/forge-suggest-changes.sh`: (Optional) Script dedicated to `suggest-changes` command logic.
- `bin/forge-common.sh`: (Optional) Script for shared utility functions (logging, git interactions, version parsing).
- `README.md`: The main project README.md, to be updated with installation and usage instructions.
- `codex/README.md`: The README within the codex, which stores the version number.
- `tests/test_forge_init.sh`: Unit/integration tests for the `init` command.
- `tests/test_forge_update.sh`: Unit/integration tests for the `update` command.
- `tests/test_forge_suggest_changes.sh`: Unit/integration tests for the `suggest-changes` command, including versioning logic.
- `tests/test_shared_infra.sh`: Tests for shared CLI infrastructure like help and error handling.

### Notes

- Shell scripts should be placed in a `bin` directory.
- Ensure scripts are executable (e.g., `chmod +x bin/forge.sh`).
- `TEMP_DIR` is used by `init` and `update` for temporary storage of `git archive` contents, and by `suggest-changes` for the temporary `git clone` of the framework repository.
- Consider using a shell testing framework like `shunit2` or `bats-core` for automated tests.
- For `forge suggest-changes`, robust testing will require careful mocking of git remote operations or a dedicated test repository.
- All user-facing messages should be clear and informative, especially error messages.

## Tasks

- [x] 1.0 Implement `forge init` command functionality (FR1)
  - [x] 1.1 Create the main `bin/forge` script file with basic structure for subcommand dispatch.
  - [x] 1.2 Implement argument parsing within `bin/forge` to recognize the `init` subcommand and its options.
  - [x] 1.3 Implement logic to fetch/clone only the required `codex` folder, `lore/README.md`, and `saga/README.md` from `https://github.com/MarcelDanz/ai-forge.git` (FR1.1). (Consider `git archive` or sparse checkout).
  - [x] 1.4 Implement logic to copy the fetched `codex` folder to the current project directory, overwriting if it exists (FR1.3).
  - [x] 1.5 Implement logic to create the `lore` directory in the current project if it doesn't exist (FR1.2, FR1.4).
  - [x] 1.6 Implement logic to copy the fetched `lore/README.md` into the project's `lore` directory, only if `lore/README.md` doesn't already exist (FR1.2, FR1.5).
  - [x] 1.7 Implement logic to create the `saga` directory in the current project if it doesn't exist (FR1.2, FR1.4).
  - [x] 1.8 Implement logic to copy the fetched `saga/README.md` into the project's `saga` directory, only if `saga/README.md` doesn't already exist (FR1.2, FR1.5).
  - [x] 1.9 Add verbose error handling for git operations, file system operations, and network issues (FR4.2).
  - [x] 1.10 Add informative status messages for the user during the `init` process.

- [x] 2.0 Implement `forge update` command functionality (FR2)
  - [x] 2.1 Implement argument parsing within `bin/forge` for the `update` subcommand.
  - [x] 2.2 Implement logic to fetch the latest version of the `codex` folder from the framework repository (FR2.1).
  - [x] 2.3 Implement a user prompt: "Do you want to back up the existing 'codex' folder? [y/N]" (FR2.3).
  - [x] 2.4 If user confirms backup, implement logic to copy the existing `codex` folder to `codex.bak` before replacement (FR2.3).
  - [x] 2.5 Implement logic to completely replace the existing `codex` folder in the current project directory with the fetched version (FR2.2).
  - [x] 2.6 Ensure the `codex/README.md` in the project's updated `codex` folder correctly reflects the fetched version number (FR2.4).
  - [x] 2.7 Add verbose error handling for git operations, file system operations, and user input (FR4.2).
  - [x] 2.8 Add informative status messages for the user during the `update` process.
  - [x] 2.9 Implement cleanup of any temporary files or directories created during the fetch/update process.

- [x] 3.0 Implement `forge suggest-changes` command functionality (FR3) (Note: Tasks below are re-structured based on feedback)
  - Note: Refer to `gh pr create` manual for detailed options: https://cli.github.com/manual/gh_pr_create
  - [x] 3.1 Implement argument parsing within `bin/forge.sh` for the `suggest-changes` subcommand.
  - [x] 3.2 Implement prompts for PR information:
    - [x] 3.2.1 Prompt for PR title.
    - [x] 3.2.2 Prompt for PR body (multiline).
    - [x] 3.2.3 Prompt for user's GitHub fork name (e.g., `username/ai-forge`).
    - [x] 3.2.4 Implement re-prompting loop for title, body, and fork name if initial input is invalid (empty or incorrect format).
    - [x] 3.2.5 Implement validation for GitHub fork name format (e.g., `owner/repo`, checking for valid characters).
  - [x] 3.3 Implement logic to temporarily clone the framework repository (`https://github.com/MarcelDanz/ai-forge.git`) into `TEMP_DIR` (FR3.2). The `TEMP_DIR` should be created by this step and cleaned up by step 3.12.
  - [x] 3.4 Implement pre-change checks:
    - [x] 3.4.1 Fetch framework's `codex/README.md` from its default branch (e.g., `main` or `HEAD` of the clone in `TEMP_DIR`) to get the current framework Codex version.
    - [x] 3.4.2 Read local project's `codex/README.md` to get the local Codex version.
    - [x] 3.4.3 Compare local Codex version with framework's version. If local version is older (e.g., 0.1.0 vs 0.2.0), log error instructing user to run `forge update` first, then exit. (Requires SemVer comparison logic).
    - [x] 3.4.4 Check if local `./$CODEX_DIR` directory exists. If not, log error "Local './$CODEX_DIR' directory not found. Nothing to suggest." and exit.
  - [x] 3.5 Create a new branch in the cloned repository (e.g., `suggest-codex-updates-<timestamp>`) (FR3.2).
  - [x] 3.6 Apply and commit local codex changes:
    - [x] 3.6.1 Replace the `codex` folder in the new branch of the cloned repository with the project's local `codex` folder.
    - [x] 3.6.2 Commit these `codex` changes to the new branch (e.g., "feat(codex): Apply local codex changes").
  - [x] 3.7 Determine and apply Codex version bump (FR5.4):
    - [x] 3.7.1 Analyze differences between the new branch (with local changes) and the framework's main branch using `git diff` (e.g., `git diff --name-status main..HEAD` or `git diff --shortstat main..HEAD` within `TEMP_DIR`).
    - [x] 3.7.2 Based on FR5.4 rules (file additions/removals, substantial content changes vs. minor textual changes), determine if a MINOR or PATCH version bump is needed.
    - [x] 3.7.3 Read the current version from `codex/README.md` in the new branch (this is the user's local version before bumping).
    - [x] 3.7.4 Increment the version number according to SemVer rules.
    - [x] 3.7.5 Update the `Codex Version:` line in the `codex/README.md` file (in the new branch within `TEMP_DIR`).
    - [x] 3.7.6 Commit the version bump to the new branch (e.g., "chore(codex): Bump version to X.Y.Z").
  - [x] 3.8 Add user's specified fork as a remote and push the new branch (with both commits) to that fork (FR3.3).
  - [x] 3.9 Create Pull Request:
    - [x] 3.9.1 Attempt to create a pull request to the main `ai-forge` repository using GitHub CLI (`gh pr create`) with the user-provided title and description (FR3.3, FR3.5).
    - [x] 3.9.2 If `gh` is not available or PR creation fails, provide clear instructions for the user to create the PR manually, including the branch name pushed to their fork (FR3.4, TC2).
  - [x] 3.10 Add verbose error handling for all git operations, GitHub CLI commands, version parsing, and user input throughout the `suggest-changes` process. If critical steps fail (e.g., push, PR creation), advise user appropriately (FR3.4, FR4.2).
  - [x] 3.11 Add informative status messages for the user throughout the `suggest-changes` process.
  - [x] 3.12 Implement cleanup of the temporary directory (`TEMP_DIR`) used for cloning, upon exit or interruption (ensure this reuses or is compatible with the existing `cleanup_temp_dir` function and `TEMP_DIR` variable).

- [x] 4.0 Implement shared CLI infrastructure (FR4)
  - [x] 4.1 Refine `bin/forge.sh` to robustly handle subcommand dispatching (current single-file structure is acceptable for now, but consider future refactor to separate script files or functions if complexity grows).
  - [x] 4.2 Implement a comprehensive help system:
    - [x] 4.2.1 `forge --help` or `forge help`: General usage, list of commands.
    - [x] 4.2.2 `forge <command> --help` or `forge help <command>`: Detailed help for each command (FR4.3).
  - [x] 4.3 Standardize error message formatting (e.g., `ERROR: <message>`) and ensure verbosity (FR4.2).
  - [x] 4.4 Create common utility functions (e.g., in `bin/forge-common.sh`) for logging, checking `git` and `gh` dependencies, and other shared logic.
  - [x] 4.5 Ensure all scripts use appropriate exit codes to signal success or failure (TC6).
  - [x] 4.6 Apply shell scripting best practices (e.g., `set -e`, `set -u`, `set -o pipefail` where appropriate) (DC2).

- [x] 5.0 Update main `README.md` with installation and usage instructions
  - [x] 5.1 Add a "Prerequisites" section to `README.md` (e.g., `git`, optionally `gh`).
  - [x] 5.2 Draft "Installation" section in `README.md`:
    - [x] 5.2.1 Explain cloning the `ai-forge` repository.
    - [x] 5.2.2 Explain creating a `bin` directory if it doesn't exist and placing the `forge.sh` script there. Suggest creating a symlink for convenience (e.g., `cd bin; ln -s forge.sh forge`) so the command can be called as `forge`.
    - [x] 5.2.3 Explain making the `forge.sh` script executable (e.g., `chmod +x bin/forge.sh`).
    - [x] 5.2.4 Provide clear instructions on adding the `bin` directory to the system's PATH for common shells (e.g., bash, zsh), including adding the export command to `.bashrc`/`.zshrc`. This allows calling `forge.sh` (or `forge` if symlinked) from any directory.
  - [x] 5.3 Draft "Usage" section in `README.md`:
    - [x] 5.3.1 Brief overview of the `forge` CLI tool (mentioning it can be called as `forge` if symlinked/aliased or `forge.sh` directly).
    - [x] 5.3.2 Example for `forge init`.
    - [x] 5.3.3 Example for `forge update`, mentioning the backup prompt.
    - [x] 5.3.4 Example for `forge suggest-changes`, mentioning prompts for PR title, description, and fork name.
    - [x] 5.3.5 Example for accessing help (`forge --help`, `forge init --help`, etc.).
  - [x] 5.4 Review all `README.md` additions for clarity, accuracy, and completeness, targeting a junior developer audience.

- [ ] 6.0 Implement automated tests for the CLI tool
  - [ ] 6.1 Set up a testing framework (e.g., `bats-core` or `shunit2`) and create a test runner script.
  - [ ] 6.2 Create `tests/test_shared_infra.sh` to test help commands and error handling.
  - [ ] 6.3 Create `tests/test_forge_init.sh` to test the `init` command functionality.
  - [ ] 6.4 Create `tests/test_forge_update.sh` to test the `update` command functionality.
  - [ ] 6.5 Create `tests/test_forge_suggest_changes.sh` to test the `suggest-changes` command functionality.
