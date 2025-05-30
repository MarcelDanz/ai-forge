
# Behaviors

> *A collection of defined behaviors, and response styles for AI agents that work within this project.*

The `behaviors/` directory describes **how the AI assistant should behave** when generating output, or when interacting with the user.

This includes:
- Tone of voice
- Levels of autonomy
- What to do when uncertain
- How to prioritize correctness, readability, and structure
- What language style to user
- How verbose or concise to answer

It ensures the agent behaves **predictably, helpfully, and respectfully**, while staying aligned with the `codex/`, `lore/`, and `saga/`. Additionally, it ensures that the user gets exactly the information they need. Nothing more, nothing less.

---

## Structure

Here is an example structure for this directory:

```
behaviors/
├── README.md
├── tone_and_voice.md # Preferred writing style for code and communication
├── prompt_rules.md # Guidelines for generating or interpreting prompts

└── ...
```

---

## Guidelines

- Behaviors should be **specific, teachable, and observable**
- Behaviors can evolve — treat this folder as versioned intent
- Write in a way that a junior developer would understand the instructions

