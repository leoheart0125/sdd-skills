---
name: sdd-guardrails
description: "Continuous validation running inside every stage to prevent errors early. 'Guardrails, not Gates'."
dependencies: []
---

# SDD Guardrails

Unlike a traditional review engine that acts as a blocker at the end of a process, Guardrails run continuously *inside* other skills to provide immediate feedback.

## Core Responsibilities

1.  **Continuous Validation**: Validate artifacts (JSON, YAML, Code) as they are created.
2.  **Drift Detection**: Compare Implementation vs. Specification.
3.  **Rule Enforcement**: Ensure compliance with `project_rules.md`.
4.  **Security Scans**: Detect basic security flaws in design/code.

## Commands

-   `/sdd-guard-check <context>`: Run a specific set of checks for the given context (requirements | architecture | api | code).
-   `/sdd-guard-drift`: Compare the current codebase against `openapi.yaml` and `architecture.json`.
-   `/sdd-guard-report`: Generate a summary of active violations.

## Check Types

### 1. Design Checks (Called by `sdd-design-engine`)
-   **Ambiguity Check**: "Are requirements specific enough?"
-   **Coverage Check**: "Do all Use Cases have a Component?"
-   **Contract Check**: "Do API inputs match Database columns?"

### 2. Implementation Checks (Called by `sdd-implementer`)
-   **Linting**: "Does code follow project style?"
-   **Spec Match**: "Does the endpoint accept the defined DTO?"
-   **Test Coverage**: "Are tests generated for this task?"

## Drift Detection Logic

When `/sdd-guard-drift` is called:
1.  Parse `openapi.yaml`.
2.  Parse implemented Controller/Handler code.
3.  Compare:
    -   Parameters (Name, Type, Required)
    -   Responses (Code, Schema)
4.  If mismatch found -> Report Drift -> Recommend `/sdd-spec-update` or Implementation Fix.

## Integration

-   **Invoked by**: `sdd-design-engine` (pre-save), `sdd-implementer` (pre-complete).
-   **Consumes**: `project_rules.md`, `context.json`, Artifacts.
