---
name: skill-routing
description: Routes each task to the matching workflow skill before any action when the user does not name a /skill. Use for understanding code (how), impact checks (blast-radius), new or vague features (grill-with-docs then to-spec), implementation and bug fixes (tdd), refactoring (improve-codebase-architecture), and pre-PR or pre-commit review (interrogate then unslop).
---

# Agent Skill Routing & Execution Policy

You have access to 8 specialized workflow skills (`how`, `blast-radius`, `grill-with-docs`, `to-spec`, `tdd`, `improve-codebase-architecture`, `interrogate`, `unslop`).

## Automatic Skill Selection Rule
When the user asks you to perform a task **without** explicitly naming a `/skill`, automatically select and follow the matching skill(s) from the table below before taking action. Announce which skill you are activating in one brief line before proceeding.

| User Intent / Task Type | Required Skill(s) to Load | Trigger Condition |
| :--- | :--- | :--- |
| **Understanding code** ("how does X work", "where is Y handled") | `how` | User asks about unfamiliar modules, data flow, or architecture. |
| **Impact check** ("what happens if I change X", "is it safe to edit Y") | `blast-radius` | User plans to modify shared utilities, APIs, schemas, or core types. |
| **New feature or vague idea** ("build X", "let's add Y") | `grill-with-docs` -> `to-spec` | Requirements are ambiguous, span multiple files, or lack a written spec. |
| **Writing code or fixing bugs** ("implement X", "fix bug Y") | `tdd` | Any task that creates or modifies application logic or behavior. |
| **Refactoring or cleanup** ("clean up this module", "refactor X") | `improve-codebase-architecture` | User asks to restructure, modularize, or simplify existing architecture. |
| **Pre-PR / pre-commit review** ("review my changes", "check this diff") | `interrogate` -> `unslop` | User asks to audit, review, or finalize code before committing or merging. |

## Execution Guardrails
1. **Explicit overrides:** If the user explicitly invokes a `/skill`, follow that skill directly.
2. **Trivial edits exception:** Skip heavy planning (`grill-with-docs`, `to-spec`) for single-line typo fixes, comment updates, or formatting tweaks, though `unslop` still applies to generated text.
3. **Chaining order:** For full-lifecycle feature requests ("build X from scratch"), follow the sequence: `how` -> `grill-with-docs` -> `to-spec` -> `tdd` -> `interrogate` -> `unslop`.
