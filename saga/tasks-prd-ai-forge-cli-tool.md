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
- Consider using a shell testing framework like `shunit2` or `bats-core` for automated tests.
- For `forge suggest-changes`, robust testing will require careful mocking of git remote operations or a dedicated test repository.
- All user-facing messages should be clear and informative, especially error messages.

## Tasks

- [ ] 1.0 Implement `forge init` command functionality (FR1)
  - [x] 1.1 Create the main `bin/forge` script file with basic structure for subcommand dispatch.
  - [x] 1.2 Implement argument parsing within `bin/forge` to recognize the `init` subcommand and its options.
  - [x] 1.3 Implement logic to fetch/clone only the required `codex` folder, `lore/README.md`, and `saga/README.md` from `https://github.com/MarcelDanz/ai-forge.git` (FR1.1). (Consider `git archive` or sparse checkout).
  - [x] 1.4 Implement logic to copy the fetched `codex` folder to the current project directory, overwriting if it exists (FR1.3).
  - [ ] 1.5 Implement logic to create the `lore` directory in the current project if it doesn't exist (FR1.2, FR1.4).
  - [ ] 1.6 Implement logic to copy the fetched `lore/README.md` into the project's `lore` directory, only if `lore/README.md` doesn't already exist (FR1.2, FR1.5).
  - [ ] 1.7 Implement logic to create the `saga` directory in the current project if it doesn't exist (FR1.2, FR1.4).
  - [ ] 1.8 Implement logic to copy the fetched `saga/README.md` into the project's `saga` directory, only if `saga/README.md` doesn't already exist (FR1.2, FR1.5).
  - [ ] 1.9 Add verbose error handling for git operations, file system operations, and network issues (FR4.2).
  - [ ] 1.10 Add informative status messages for the user during the `init` process.

- [ ] 2.0 Implement `forge update` command functionality (FR2)
  - [ ] 2.1 Implement argument parsing within `bin/forge` for the `update` subcommand.
  - [ ] 2.2 Implement logic to fetch the latest version of the `codex` folder from the framework repository (FR2.1).
  - [ ] 2.3 Implement a user prompt: "Do you want to back up the existing 'codex' folder? [y/N]" (FR2.3).
  - [ ] 2.4 If user confirms backup, implement logic to copy the existing `codex` folder to `codex.bak` before replacement (FR2.3).
  - [ ] 2.5 Implement logic to completely replace the existing `codex` folder in the current project directory with the fetched version (FR2.2).
  - [ ] 2.6 Ensure the `codex/README.md` in the project's updated `codex` folder correctly reflects the fetched version number (FR2.4).
  - [ ] 2.7 Add verbose error handling for git operations, file system operations, and user input (FR4.2).
  - [ ] 2.8 Add informative status messages for the user during the `update` process.
  - [ ] 2.9 Implement cleanup of any temporary files or directories created during the fetch/update process.

- [ ] 3.0 Implement `forge suggest-changes` command functionality (FR3)
  - Note: Refer to `gh pr create` manual for detailed options: https://cli.github.com/manual/gh_pr_create
  - [ ] 3.1 Implement argument parsing within `bin/forge` for the `suggest-changes` subcommand.
  - [ ] 3.2 Implement prompts to get PR title, description, and user's GitHub fork name (e.g., `username/ai-forge`) (FR3.3).
  - [ ] 3.3 Implement logic to temporarily clone the framework repository (`https://github.com/MarcelDanz/ai-forge.git`) (FR3.2).
  - [ ] 3.4 Implement logic to create a new branch in the cloned repository (e.g., `suggest-codex-updates-<timestamp>`) (FR3.2).
  - [ ] 3.5 Implement logic to replace the `codex` folder in the new branch of the cloned repository with the project's local `codex` folder (FR3.2).
  - [ ] 3.6 **Implement automated Codex versioning logic (FR5.4):**
    - [ ] 3.6.1 Fetch the original `codex/README.md` from the framework's default branch to get the current version before user's changes are applied.
    - [ ] 3.6.2 Analyze the differences between the original framework `codex` (from cloned repo, default branch) and the user's local `codex` (to be committed).
    - [ ] 3.6.3 Based on FR5.4 rules (file additions/removals, substantial content changes vs. minor textual changes), determine if a MINOR or PATCH version bump is needed.
    - [ ] 3.6.4 Read the current version from the `codex/README.md` (that is now the user's version, copied in step 3.5).
    - [ ] 3.6.5 Increment the version number according to SemVer rules (e.g., 0.1.0 -> 0.1.1 for PATCH, 0.1.0 -> 0.2.0 for MINOR).
    - [ ] 3.6.6 Update the `Codex Version:` line in the `codex/README.md` file within the new branch of the cloned repository.
  - [ ] 3.7 Implement logic to commit all changes (updated `codex` folder and version-bumped `codex/README.md`) to the new branch in the cloned repository.
  - [ ] 3.8 Implement logic to add the user's specified fork as a remote and push the new branch to that fork (FR3.3).
  - [ ] 3.9 Implement logic to create a pull request to the main `ai-forge` repository using the GitHub CLI (`gh pr create`) with the user-provided title and description (FR3.3, FR3.5).
  - [ ] 3.10 If `gh` is not available or PR creation fails, provide clear instructions for the user to create the PR manually, including the branch name pushed to their fork (FR3.4, TC2).
  - [ ] 3.11 Add verbose error handling for git operations, GitHub CLI commands, version parsing, and user input. If PR creation fails, advise user to update their local `codex` and resolve conflicts if necessary (FR3.4, FR4.2).
  - [ ] 3.12 Add informative status messages for the user throughout the `suggest-changes` process.
  - [ ] 3.13 Implement cleanup of any temporary files or directories created during the clone/branch/PR creation process (e.g., the temporary clone of the framework repository).

- [ ] 4.0 Implement shared CLI infrastructure (FR4)
  - [ ] 4.1 Refine `bin/forge` to robustly handle subcommand dispatching to separate script files or functions.
  - [ ] 4.2 Implement a comprehensive help system:
    - [ ] 4.2.1 `forge --help` or `forge help`: General usage, list of commands.
    - [ ] 4.2.2 `forge <command> --help` or `forge help <command>`: Detailed help for each command (FR4.3).
  - [ ] 4.3 Standardize error message formatting (e.g., `ERROR: <message>`) and ensure verbosity (FR4.2).
  - [ ] 4.4 Create common utility functions (e.g., in `bin/forge-common.sh`) for logging, checking `git` and `gh` dependencies, and other shared logic.
  - [ ] 4.5 Ensure all scripts use appropriate exit codes to signal success or failure (TC6).
  - [ ] 4.6 Apply shell scripting best practices (e.g., `set -e`, `set -u`, `set -o pipefail` where appropriate) (DC2).

- [ ] 5.0 Update main `README.md` with installation and usage instructions
  - [ ] 5.1 Add a "Prerequisites" section to `README.md` (e.g., `git`, optionally `gh`).
  - [ ] 5.2 Draft "Installation" section in `README.md`:
    - [ ] 5.2.1 Explain cloning the `ai-forge` repository.
    - [ ] 5.2.2 Explain creating a `bin` directory if it doesn't exist and placing the `forge.sh` script there. Suggest creating a symlink for convenience (e.g., `cd bin; ln -s forge.sh forge`) so the command can be called as `forge`.
    - [ ] 5.2.3 Explain making the `forge.sh` script executable (e.g., `chmod +x bin/forge.sh`).
    - [ ] 5.2.4 Provide clear instructions on adding the `bin` directory to the system's PATH for common shells (e.g., bash, zsh), including adding the export command to `.bashrc`/`.zshrc`. This allows calling `forge.sh` (or `forge` if symlinked) from any directory.
  - [ ] 5.3 Draft "Usage" section in `README.md`:
    - [ ] 5.3.1 Brief overview of the `forge` CLI tool (mentioning it can be called as `forge` if symlinked/aliased or `forge.sh` directly).
    - [ ] 5.3.2 Example for `forge init`.
    - [ ] 5.3.3 Example for `forge update`, mentioning the backup prompt.
    - [ ] 5.3.4 Example for `forge suggest-changes`, mentioning prompts for PR title, description, and fork name.
    - [ ] 5.3.5 Example for accessing help (`forge --help`, `forge init --help`, etc.).
  - [ ] 5.4 Review all `README.md` additions for clarity, accuracy, and completeness, targeting a junior developer audience.
