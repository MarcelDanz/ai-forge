
# Recipes

> *Practical examples, code snippets, and reusable patterns to help create code in alignment with the Codex.*

The `recipes/` folder is a collection of **canonical examples** — ready-to-use code patterns that show how to apply the rules in real-world scenarios. These examples also prevent the user and AI agent from reinventing solutions for problems that have already been solved. Leading to simpler code.

Recipes support both developers and AI agents by providing:

- Idiomatic code examples in supported languages
- Common building blocks (e.g. pipelines, pure functions, ECS systems)
- Canonical patterns for formatting, naming, error handling

These examples **demonstrate the correct way to build.**

---

## Structure

Here is an example structure of this directory:

```
recipes/
├── rust/
│ ├── pure_function.rs
│ ├── data_pipeline.rs
│ └── ecs_system.rs
├── typescript/
│ └── form_validation.ts
└── ...
```

---

## Guidelines

- Every recipe should be **minimal, idiomatic, and self-contained**
- Refer to the rule(s) it demonstrates with comments
- Prefer real, runnable examples over abstract pseudocode
- Include comments to guide understanding — for user and AI agents alike
- Write in a way that a junior developer can understand it.


