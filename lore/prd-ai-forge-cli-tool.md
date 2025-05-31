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
*   **FR1.1:** The `forge init` command SHALL fetch the `codex`, `lore`, and `saga` folders from the official AI Forge framework repository located at `https://github.com/MarcelDanz/ai-forge.git`.
*   **FR1.2:** The command SHALL copy these folders into the current directory where the command is executed.
*   **FR1.3:** If a `codex` folder already exists in the target project directory, it SHALL be overridden by the version from the framework.
*   **FR1.4:** If `lore` or `saga` folders do not exist in the target project directory, they SHALL be created and populated from the framework.
*   **FR1.5:** If `lore` or `saga` folders already exist, their existing content SHALL NOT be modified by this command.

### FR2: `forge update` Command
*   **FR2.1:** The `forge update` command SHALL fetch the latest version of the `codex` folder from the AI Forge framework repository.
*   **FR2.2:** The command SHALL completely replace the existing `codex` folder in the current project directory with the fetched version.
*   **FR2.3:** The command SHALL offer an option (e.g., a flag like `--backup`) to automatically create a backup of the project's existing `codex` folder, naming it `codex.bak`, before replacement.
*   **FR2.4:** The command SHALL ensure the `codex/README.md` file within the project's newly updated `codex` folder reflects the correct SemVer version number of the fetched `codex`.

### FR3: `forge suggest-changes` Command
*   **FR3.1:** The `forge suggest-changes` command SHALL facilitate proposing changes from the project's local `codex` folder to the AI Forge framework repository.
*   **FR3.2:** The command SHALL (internally) clone the AI Forge framework repository, create a new branch, and replace the `codex` folder in this branch with the project's local `codex` folder.
*   **FR3.3:** The command SHALL then commit these changes and attempt to create a pull request on the `https://github.com/MarcelDanz/ai-forge.git` repository. The user must have `git` and potentially GitHub CLI (`gh`) configured for authentication.
*   **FR3.4:** If the process of preparing changes (e.g., pushing the new branch or creating the PR) fails (e.g., due to inability to push to a remote, or other git errors), the command SHALL inform the user with a verbose error message. It SHOULD advise the user to ensure their project's `codex` is up-to-date with the framework (e.g., by running `forge update`, manually resolving any conflicts) and then try `forge suggest-changes` again.
*   **FR3.5:** The pull request created SHALL be clearly titled and described, indicating it contains suggested changes to the `codex` from a project.

### FR4: General CLI Behavior
*   **FR4.1:** The CLI tool SHALL be implemented as one or more simple `.sh` (shell script) files.
*   **FR4.2:** All commands SHALL provide verbose error messages to assist the user in diagnosing and resolving issues.
*   **FR4.3:** The CLI tool SHALL provide a help mechanism (e.g., `forge --help`, `forge <command> --help`, or a dedicated `forge help <command>`) that explains the purpose, usage, and potential consequences of each command.
*   **FR4.4:** Commands SHALL execute their primary actions without requiring interactive confirmation prompts from the user. The help documentation should serve as the primary source of information regarding command consequences.

### FR5: Codex Versioning
*   **FR5.1:** The `codex` folder within the main AI Forge framework repository MUST contain a `README.md` file.
*   **FR5.2:** This `codex/README.md` file MUST include a version identifier for the codex (e.g., `Codex Version: 1.0.0`). This version MUST follow the Semantic Versioning 2.0.0 standard (MAJOR.MINOR.PATCH).
*   **FR5.3:** The `forge update` command (as per FR2.4) MUST ensure the version number in the project's local `codex/README.md` is updated to match the version of the `codex` it fetched.
*   **FR5.4:** When changes are proposed via `forge suggest-changes`, the review process for the pull request should include consideration of whether the changes warrant an increment to the `codex` version number according to SemVer rules. The CLI tool itself is not required to automatically bump the version in the PR.

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
    *   `gh` (GitHub CLI) is highly recommended for seamless pull request creation by `forge suggest-changes`. If not available, the script should inform the user about alternative steps.
*   **TC3:** **Framework Source:** The hardcoded URL for the AI Forge framework repository is `https://github.com/MarcelDanz/ai-forge.git`.
*   **TC4:** **`forge init` & `forge update` Data Fetching:** These commands will likely use `git clone --depth=1 --sparse` followed by `git sparse-checkout set codex lore saga` (or similar) or `git archive` to efficiently download only the required folders.
*   **TC5:** **`forge suggest-changes` Workflow:**
    1.  Temporarily clone the framework repository.
    2.  Create a new branch (e.g., `suggest-codex-updates-<timestamp>`).
    3.  Replace the `codex` directory in the cloned repository with the user's local `codex`.
    4.  Commit the changes.
    5.  Push the new branch to a remote (ideally the user's fork, or directly if they have permissions and choose to do so).
    6.  Create a pull request using `gh pr create` or provide instructions if `gh` is not available.
*   **TC6:** **Error Handling:** Scripts should use exit codes appropriately to signal success or failure.

## 8. Success Metrics

*   **SM1:** Number of active projects utilizing the AI Forge CLI tool for initialization and updates.
*   **SM2:** Positive qualitative feedback from junior developers regarding the tool's ease of use and clarity of documentation/messages.
*   **SM3:** Number of pull requests successfully generated by `forge suggest-changes` that are reviewed and merged into the main framework.
*   **SM4:** Observed reduction in inconsistencies in `codex` usage across projects.
*   **SM5:** Maintainability of the CLI tool itself, indicated by ease of bug fixing and feature additions.

## 9. Open Questions

*   **OQ1:** For `forge suggest-changes`: Should the script explicitly ask the user for the name of their fork or attempt to infer it? (Current assumption: relies on user's `git` remote configuration or `gh`'s ability to handle forks).
*   **OQ2:** For `codex` versioning (related to FR5.4): While the PR submitter isn't required to bump the version, should `forge suggest-changes` include a reminder in its output or in the PR body to consider a version bump if the changes are significant?

---
This PRD is based on the initial feature description and subsequent clarifications. It should be considered a living document and may be updated as the project progresses.
