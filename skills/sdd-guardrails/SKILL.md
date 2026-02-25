---
name: sdd-guardrails
description: "Continuous validation running inside every stage to prevent errors early. 'Guardrails, not Gates'."
dependencies:
  - sdd-knowledge-base
---

# SDD Guardrails

Unlike a traditional review engine that acts as a blocker at the end of a process, Guardrails run continuously *inside* other skills to provide immediate feedback. Every guardrail failure is a potential lesson.

## Core Responsibilities

1.  **Continuous Validation**: Validate artifacts (JSON, YAML, Code) as they are created.
2.  **Rule Compliance**: Enforce `project_rules.md` programmatically at every stage — design, plan, and implementation.
3.  **Drift Detection**: Compare Implementation vs. Specification.
4.  **Security Scans**: Detect basic security flaws in design/code.
5.  **Lesson Triggers**: Every guardrail fail → fix → pass cycle triggers `/sdd-learn`.

## Commands

-   `/sdd-guard-check <context>`: Run a specific set of checks for the given context (requirements | architecture | api | plan | code).
-   `/sdd-guard-drift`: Compare the current codebase against `openapi.yaml` and `architecture.json`.
-   `/sdd-guard-report`: Generate a summary of active violations.

## Check Types

### 1. Design Checks (Called by `sdd-design-engine`)
-   **Ambiguity Check**: "Are requirements specific enough?" (flag items with low `confidence_score`)
-   **Coverage Check**: "Do all Use Cases have a Component?"
-   **Contract Check**: "Do API inputs match Database columns?"
-   **Rule Conflict Check**: "Do generated specs conflict with `project_rules.md`?" — If yes, raise as BLOCKING concern.

### 2. Plan Checks (Called by `sdd-task-planner`) — NEW
-   **Path Convention Check**: Verify each task's `target_path` conforms to the architecture conventions declared in `project_rules.md`.
    -   Read `architecture_style` and `project_structure_convention` from `context.json` and the Architecture section of `project_rules.md`
    -   Validate that all `target_path` values follow the declared convention
-   **Rule Compliance Check**: Ensure task descriptions align with project rules (naming conventions, testing requirements, etc.)
-   **Dependency Check**: Verify no circular dependencies in task graph

### 3. Implementation Checks (Called by `sdd-implementer`)
-   **Linting**: "Does code follow project style?"
-   **Spec Match**: "Does the endpoint accept the defined DTO?" — Validate against `openapi.yaml` request/response schemas.
-   **Object Design Match**: "Do implemented classes match `object_design.json`?" — Verify class names, method signatures, properties, and layer placement.
-   **Schema Match**: "Do data-layer implementations match `data_api.json`?" — Verify entity fields, types, and relationships.
-   **Test Coverage**: "Are tests generated for this task?"
-   **File Placement**: "Is the file at the `target_path` specified in `tasks.json`?"
-   **Rule Compliance**: "Does the generated code follow Coding Standards, Architecture patterns, and naming conventions declared in `project_rules.md`?" — If violations found, raise as failure and fix before proceeding.

### 4. Artifact Integrity Check (All Phases)
-   **JSON Validity**: All `.json` artifacts (task.json, lesson.json, pattern.json, concerns.json, etc.) MUST be valid JSON parseable by a standard JSON parser.
-   **String Escaping**: String values MUST properly escape: double quotes (`\"`), backslashes (`\\`), newlines (`\n`), tabs (`\t`), and other control characters.
-   **Pre-Write Validation**: Before writing any `.json` file, validate it is well-formed JSON. If validation fails, fix escaping issues before saving.
-   **Failure Protocol**: If a JSON artifact fails validation, treat it as a guardrail failure — fix immediately and record via `/sdd-learn`.

## Rule Compliance Engine

### How It Works

The Rule Compliance Engine is a **programmatic check**, not just a declaration. It runs at specific moments:

#### Timing
| When | Trigger | What is Checked |
|------|---------|-----------------|
| After requirements generated | `sdd-design-engine` calls `/sdd-guard-check requirements` | Spec conflicts with project_rules |
| After architecture generated | `sdd-design-engine` calls `/sdd-guard-check architecture` | Architecture style compliance |
| After tasks generated | `sdd-task-planner` calls `/sdd-guard-check plan` | `target_path` conventions |
| After code generated | `sdd-implementer` calls `/sdd-guard-check code` | File placement, naming, spec match |

#### Architecture Style Compliance

The guardrail check procedure:
1.  Read `context.json.architecture_style` and `context.json.project_structure_convention`.
2.  Read `project_rules.md` Architecture section to understand the declared conventions.
3.  For each task in `tasks.json`, validate `target_path` against the declared conventions.
4.  For `architecture.json`, validate component grouping matches the declared style.

> **Example**: If `project_rules.md` declares Screaming Architecture:
> -   ✅ `src/auth/domain/auth-token.ts` → domain concept first
> -   ❌ `src/domain/auth-token.ts` → layer first (violates convention)

## Drift Detection Logic

When `/sdd-guard-drift` is called:
1.  Parse spec artifacts from `.sdd/spec/<feature-id>/`: `openapi.yaml`, `object_design.json`, `data_api.json`.
2.  Parse implemented code (Controllers, Services, Repositories, Entities).
3.  Compare against each spec:
    -   `object_design.json`: Class names, method signatures, properties, layer assignments.
    -   `data_api.json`: Entity fields, types, relationships vs DB schemas/models.
    -   `openapi.yaml`: Parameters (Name, Type, Required), Responses (Code, Schema).
4.  If mismatch found → Report Drift → Recommend `/sdd-spec-update` or Implementation Fix.

## Lesson Trigger Protocol

**Every guardrail failure that gets fixed is a lesson.** When a check fails and is subsequently resolved:

1.  Record the violation and fix as a lesson via `/sdd-learn`:
    ```json
    {
        "trigger": "guard-check-<context>",
        "advice": "Response DTO must exactly match OpenAPI schema. Do not add extra wrappers."
    }
    ```
2.  If the **same lesson triggers twice** across different features → propose promotion to `project_rules.md` via `/sdd-rule-update`.

## Integration

-   **Invoked by**: `sdd-design-engine` (pre-save), `sdd-task-planner` (post-generation), `sdd-implementer` (pre-complete).
-   **Consumes**: `project_rules.md`, `context.json`, Artifacts.
-   **Triggers**: `/sdd-learn` (on fix cycles), `/sdd-rule-update` (on repeated lessons).
