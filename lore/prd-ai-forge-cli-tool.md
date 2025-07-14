# Product Requirements Document: AI Forge CLI Tool

## 1. Introduction/Overview

This document outlines the requirements for the AI Forge Command Line Interface (CLI) tool. The primary problem this tool solves is the manual effort and potential inconsistency involved in setting up new software projects with the AI Forge framework's standard components (`codex`, `lore`, `saga` folders) and keeping the crucial `codex` folder (containing AI assistant conventions, rules, and workflows) synchronized between a central framework repository and individual projects.

The goal of the AI Forge CLI tool is to provide a simple, command-line interface for developers to easily initialize projects with AI Forge components, update their local `codex` from the central framework, and propose changes from their project's `codex` back to the framework in a structured manner.

## 2. Goals

*   **G1:** Provide three distinct CLI commands: `forge init`, `forge update`, and `forge suggest-changes`.
*   **G2:** Enable quick and consistent setup of new projects by copying the `codex`, `lore`, and `saga` folders from the AI Forge framework.
*   **G3:** Allow developers to easily update their project's `codex` folder to the latest version from the central AI Forge framework repository.
*   **G4:** Facilitate contributions of `codex` improvements from individual projects back to the AI Forge framework via GitHub Pull Requests.
*   **G5:** Ensure the CLI tool is user-friendly, especially for junior developers, with clear instructions and error messages.
*   **G6:** Implement and manage versioning for the `codex` itself, with the version number stored in `codex/README.md` and following Semantic Versioning 2.0.0.

## 3. User Stories

*   **US1:** As a developer starting a new project, I want to run `forge init` so that the `codex`, `lore`, and `saga` folders from the AI Forge framework are copied into my project, allowing me to quickly set up my AI coding assistant according to standard practices.
*   **US2:** As a developer working on an existing project, I want to run `forge update` so that my project's `codex` folder is updated with the latest version from the AI Forge framework, ensuring I have the most current conventions and workflows, and I want an option to back up my existing `codex` before it's replaced.
*   **US3:** As a developer who has made improvements to the `codex` in my project, I want to run `forge suggest-changes` so that my modifications are packaged into a pull request against the AI Forge framework repository, allowing for review and potential integration of my improvements.
*   **US4:** As a junior developer, I want the CLI tool to provide a `help` command or option and output verbose error messages so I can understand how to use each command, its consequences, and how to troubleshoot any issues I encounter.

## 4. Functional Requirements

### FR1: `forge init` Command
*   **FR1.1:** The `forge init` command SHALL fetch the `codex` folder, the `lore/README.md` file, and the `saga/README.md` file from the official AI Forge framework repository located at `https://github.com/fork-base/ai-forge.git`.
*   **FR1.2:** The command SHALL copy the fetched `codex` folder into the current directory. It SHALL create the `lore` and `saga` directories if they do not exist. It SHALL then copy the fetched `lore/README.md` into the `lore` directory and `saga/README.md` into the `saga` directory.
*   **FR1.3:** If a `codex` folder already exists in the target project directory, the user SHALL be prompted for confirmation before it is overridden by the version from the framework.
*   **FR1.4:** The `lore` and `saga` directories SHALL be created if they do not exist in the target project directory. The `lore/README.md` and `saga/README.md` files from the framework SHALL be copied into their respective directories.
*   **FR1.5:** If `lore/README.md` or `saga/README.md` files already exist in the target project directory, they SHALL NOT be overwritten. Other contents within existing `lore` or `saga` folders SHALL NOT be modified by this command.

### FR2: `forge update` Command
*   **FR2.1:** The `forge update` command SHALL fetch the latest version of the `codex` folder from the AI Forge framework repository.
*   **FR2.2:** The command SHALL completely replace the existing `codex` folder in the current project directory with the fetched version.
*   **FR2.3:** The command SHALL prompt the user (e.g., "Do you want to back up the existing 'codex' folder? [y/N]") to confirm if they want to create a backup. If confirmed, the backup SHALL be named `codex.bak` and created before replacement.
*   **FR2.4:** The command SHALL ensure the `codex/README.md` file within the project's newly updated `codex` folder reflects the correct SemVer version number of the fetched `codex`.

### FR3: `forge suggest-changes` Command
*   **FR3.1:** The `forge suggest-changes` command SHALL facilitate proposing changes from the project's local `codex` folder to the AI Forge framework repository.
*   **FR3.2:** The command SHALL (internally) clone the AI Forge framework repository, create a new branch, and replace the `codex` folder in this branch with the project's local `codex` folder.
*   **FR3.3:** The command SHALL prompt the user for a title and a description for the pull request. It SHALL rely on the GitHub CLI (`gh`) to handle forking the repository, pushing the new branch, and creating the pull request. The user must have `gh` installed and authenticated.
*   **FR3.4:** If the `gh pr create` process fails, the command SHALL inform the user with a verbose error message from the `gh` tool. It SHOULD advise the user to ensure their local `codex` is up-to-date with the framework and that their `gh` CLI is properly authenticated.
*   **FR3.5:** The pull request created SHALL use the title and description provided by the user.

### FR4: General CLI Behavior
*   **FR4.1:** The CLI tool SHALL be implemented as one or more simple `.sh` (shell script) files.
*   **FR4.2:** All commands SHALL provide verbose error messages to assist the user in diagnosing and resolving issues.
*   **FR4.3:** The CLI tool SHALL provide a help mechanism (e.g., `forge --help`, `forge <command> --help`, or a dedicated `forge help <command>`) that explains the purpose, usage, and potential consequences of each command.
*   **FR4.4:** Commands SHALL generally execute their primary actions without requiring interactive confirmation prompts. However, `forge init` SHALL prompt for overwrite confirmation, `forge update` SHALL prompt for backup confirmation, and `forge suggest-changes` SHALL prompt for pull request title, description, and fork information. The help documentation should serve as the primary source of information regarding command consequences for other actions.

### FR5: Codex Versioning
*   **FR5.1:** The `codex` folder within the main AI Forge framework repository MUST contain a `README.md` file.
*   **FR5.2:** This `codex/README.md` file MUST include a version identifier for the codex (e.g., `Codex Version: 1.0.0`). This version MUST follow the Semantic Versioning 2.0.0 standard (MAJOR.MINOR.PATCH).
*   **FR5.3:** The `forge update` command (as per FR2.4) MUST ensure the version number in the project's local `codex/README.md` is updated to match the version of the `codex` it fetched.
*   **FR5.4:** When changes are proposed via `forge suggest-changes`, the CLI tool SHALL automatically determine and apply the appropriate Semantic Version bump (PATCH or MINOR only) for the `codex`. Major version changes are outside the scope of this automated feature. It SHALL update the `Codex Version` in the `codex/README.md` file within the new branch before creating the pull request. The determination SHALL follow these rules:
    *   A **MINOR** version bump (e.g., 0.1.0 to 0.2.0) is applied if significant changes are detected. This includes:
        *   Addition or removal of entire files within the `codex` directory.
        *   Addition or removal of substantial sections, multiple rules, or entire workflows in existing `codex` files.
    *   A **PATCH** version bump (e.g., 0.1.0 to 0.1.1) is applied if only minor changes are detected. This includes:
        *   Corrections to a few words or typo fixes.
        *   Minor clarifications that do not alter core rules or add/remove functionality.
    *   The tool will analyze the diff of the `codex` directory to make this determination.

## 5. Non-Goals (Out of Scope)

*   **NG1:** The CLI tool will not automatically resolve merge conflicts when `forge suggest-changes` encounters issues. Users will be directed to update their local `codex` and resolve conflicts manually before retrying.
*   **NG2:** The CLI tool will not manage versioning for the `lore` or `saga` folders. Versioning is specific to the `codex` folder.
*   **NG3:** The CLI tool will not provide a graphical user interface (GUI). It is purely a command-line utility.
*   **NG4:** The CLI tool will not manage complex GitHub authentication. It will rely on the user's existing `git` credential manager or GitHub CLI (`gh`) setup for operations requiring authentication (like creating pull requests).

## 6. Design Considerations (Optional)

*   **DC1:** CLI output should be clear, concise, and informative, using standard conventions for messages (e.g., INFO, WARN, ERROR prefixes).
*   **DC2:** Shell scripts should adhere to good practices for readability, maintainability, and error handling (e.g., `set -e`, `set -u`, `set -o pipefail` where appropriate).
*   **DC3:** The use of standard `git` commands is expected. For PR creation, integration with the GitHub CLI (`gh`) is recommended if available; otherwise, users might be guided through a more manual PR creation process after a branch is pushed.

## 7. Technical Considerations (Optional)

*   **TC1:** **Implementation:** The CLI tool will be developed as `.sh` (shell script) files.
*   **TC2:** **Dependencies:**
    *   `git` (command-line tool) is a mandatory dependency.
    *   `gh` (GitHub CLI) is a mandatory dependency for the `forge suggest-changes` command.
*   **TC3:** **Framework Source:** The hardcoded URL for the AI Forge framework repository is `https://github.com/fork-base/ai-forge.git`.
*   **TC4:** **`forge init` & `forge update` Data Fetching:** These commands will likely use `git clone --depth=1 --sparse` followed by `git sparse-checkout set codex lore saga` (or similar) or `git archive` to efficiently download only the required folders.
*   **TC5:** **`forge suggest-changes` Workflow:**
    1.  Ensure the user has a fork of the framework repository using `gh repo fork`.
    2.  Clone the user's fork into a temporary directory.
    3.  Configure the original framework repository as the `upstream` remote and fetch it.
    4.  Create a new branch from the latest `upstream/main`.
    5.  Replace the `codex` directory in the new branch with the user's local `codex`.
    6.  Commit the changes (including the automated version bump).
    7.  Push the new branch to the user's fork (`origin`).
    8.  Invoke `gh pr create` to open the pull request from the fork's new branch to the `upstream` repository's main branch.
*   **TC6:** **Error Handling:** Scripts should use exit codes appropriately to signal success or failure.

## 8. Success Metrics

*   **SM1:** Number of active projects utilizing the AI Forge CLI tool for initialization and updates.
*   **SM2:** Positive qualitative feedback from junior developers regarding the tool's ease of use and clarity of documentation/messages.
*   **SM3:** Number of pull requests successfully generated by `forge suggest-changes` that are reviewed and merged into the main framework.
*   **SM4:** Observed reduction in inconsistencies in `codex` usage across projects.
*   **SM5:** Maintainability of the CLI tool itself, indicated by ease of bug fixing and feature additions.

## 9. Open Questions

*   **OQ1 (Resolved):** For `forge suggest-changes`, the tool will prompt the user for their fork name (see FR3.3).
*   **OQ2 (Resolved):** For `codex` versioning, the tool will automatically handle version bumping as per FR5.4.

---
This PRD is based on the initial feature description and subsequent clarifications. It should be considered a living document and may be updated as the project progresses.
