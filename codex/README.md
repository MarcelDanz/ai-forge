
# Codex

The Codex is the AI agent’s rulebook -- a canonical source of truth for:

- coding standards,
- design principles,
- workflows,
- and code examples

used in this project.

## Purpose

This directory exists to guide and constrain AI-assisted development. Whether used with Aider, or custom autonomous development assistants, and any LLM, the Codex defines:

- How code should be written
- What architectural decisions must be followed
- Which patterns (recipes) are acceptable -- and which are not
- Standard workflows and naming conventions
- How the AI agent should respond -- and what to omit.

## Usage

- The AI agent should read the files in `/rules`, and `/behaviors` **always before** suggesting or making changes.
- The user may also reference them when reviewing AI contributions.
- Keep entries **short, declarative, and enforceable**.

## Files

Each sub-directory contains `.md` files that cover the different aspects of what we define as production-ready code:

- `/workflows` -- these workflows can be referenced by the user to be applied by the AI agent. The purpose is to streamline exection and reduce misunderstandings. 
- `/rules` -- these rules _must_ be applied every time the AI agent makes changes to the code-base.
- `/recipes` -- a collection of code snippets and examples. These examples can be referenced by the user to be applied by the AI agent. It is easier for the AI to follow example code instead of coming up with new solutions.
- `/behaviors` -- describe how the AI agent _must_ behave when responding to user input. 

