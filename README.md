# ai-forge
A simple language agnostic framework to turn your vanilla coding assistant into a true software developer.


## Feature description

I created this project as a framework to share ai coding assistents between my software projects. 

1. I want to be able to copy the folders `codex`, `lore`, and `saga` through a cli command to a new project. Then the coding assistant I use in that project can use these code conventions, workflows etc. and I don't need to do it manually. 
2. Additionally I want to be able to update the `codex` folder in an existing project with the newest version of the folder from the framework project. I want to do this also with a cli command. 
3. And last I want to use a third cli command to push changes to the `codex` folder from my new projects to the framework. This will come in handy when I find new rules the ai assistant should follow while developing the new projects. Then I want an easy way to push these new rules to the framework. 


# AI Forge

AI Forge is a framework for standardizing the use of AI coding assistants in software development projects. It provides a `codex` — a set of rules, conventions, and workflows — that ensures consistency and quality when working with AI.

This repository contains the `forge` CLI tool, a simple utility to help you manage the AI Forge components in your own projects.

## Prerequisites

Before you begin, ensure you have the following installed:
- **git**: The `forge` tool relies on `git` to fetch framework components.
- **GitHub CLI (`gh`)**: (Optional, but recommended) The `gh` tool is used by `forge suggest-changes` to automatically create pull requests. If it's not installed, you will be given manual instructions.

## Installation

To use the `forge` CLI tool, you need to make the `bin/forge.sh` script available in your system's PATH.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/MarcelDanz/ai-forge.git
    cd ai-forge
    ```

2.  **Make the script executable:**
    ```bash
    chmod +x bin/forge.sh
    ```

3.  **Add the `bin` directory to your PATH:**
    For the current session, you can run:
    ```bash
    export PATH="$(pwd)/bin:$PATH"
    ```

    To make this change permanent, add the line above to your shell's configuration file (e.g., `~/.zshrc`, `~/.bashrc`, or `~/.bash_profile`), using the absolute path to the `bin` directory.

    Example for `~/.zshrc`:
    ```bash
    echo 'export PATH="/path/to/your/ai-forge/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ```
    Replace `/path/to/your/ai-forge` with the actual absolute path.

4.  **(Optional) Create a symlink for convenience:**
    You can create a symbolic link to call the script simply as `forge` instead of `forge.sh`.
    ```bash
    # Inside the bin/ directory:
    cd bin
    ln -s forge.sh forge
    ```

## Usage

The `forge` CLI tool helps you manage AI Forge components in your project.

### `forge init`
Initializes a new or existing project with the standard AI Forge components (`codex`, `lore`, `saga`).

**Example:**
```bash
# Navigate to your project directory
cd /path/to/my-project

# Run init
forge init
```
This will copy the `codex` folder and create the `lore` and `saga` directories with their respective `README.md` files.

### `forge update`
Updates your project's `codex` to the latest version from the framework.

**Example:**
```bash
# Navigate to your project directory
cd /path/to/my-project

# Run update
forge update
```
You will be prompted to back up your existing `codex` folder before it is replaced.

### `forge suggest-changes`
Proposes your local `codex` improvements back to the AI Forge framework by creating a pull request.

**Example:**
```bash
# Navigate to your project directory
cd /path/to/my-project

# Run suggest-changes
forge suggest-changes
```
The tool will prompt you for a PR title, a multiline body, and your GitHub fork name (e.g., `your-username/ai-forge`). It will then guide you through the process.

### Getting Help
You can get help for the main command or any subcommand using `--help`.

**Examples:**
```bash
forge --help
forge init --help
forge update --help
```
