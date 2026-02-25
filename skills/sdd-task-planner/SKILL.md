---
name: sdd-task-planner
description: "Intelligent planning engine that uses historical patterns and project rules to generate implementation tasks."
dependencies:
  - sdd-design-engine
  - sdd-knowledge-base
---

# SDD Task Planner

This skill transforms specifications into actionable plans, but unlike a simple generator, it **learns** and **enforces rules**. It checks the Knowledge Base for similar past features, reads `project_rules.md` for architectural constraints, and applies clarification when needed.

## Core Responsibilities

1.  **Rule-Aware Planning**: Read `project_rules.md` **first** — especially Architecture and Coding Standards — before generating any task.
2.  **Pattern Matching**: Query `sdd-knowledge-base` for tasks similar to the current feature (by tags).
3.  **Smart Generation**: If a pattern exists, hydrate it. If not, generate new tasks from spec artifacts.
4.  **Path Validation**: Every task must include a `target_path` that conforms to the architecture conventions defined in `project_rules.md`.
5.  **Optimization**: Order tasks to minimize context switching.

## Commands

-   `/sdd-plan`: Generate or update the implementation plan (`tasks.json`).
-   `/sdd-plan-optimize`: Re-sort tasks based on dependencies and developer availability.

## Planning Logic

When `/sdd-plan` is called:

### Step 1: Read Project Rules (MANDATORY FIRST STEP)
1.  Load `project_rules.md` from `.sdd/context/`.
2.  Extract architecture conventions from the Architecture section of `project_rules.md` (e.g., directory structure patterns, layer ordering).
3.  Extract coding standards and naming conventions.
4.  These rules constrain all subsequent task generation.

### Step 2: Knowledge Lookup (MANDATORY — Index-Based)
1.  Read `.sdd/knowledge/index.json` (the lightweight index).
2.  Filter `patterns` entries whose `tags` match the current feature's domain (e.g., `crud`, `auth`).
3.  Filter `lessons` entries whose `tags` match OR whose `trigger` matches `"planning-*"` or the current feature's domain.
4.  Load ONLY the matched files (via the `file` path in each index entry). Do NOT scan the full `patterns/` or `lessons/` directories.
5.  Summarize relevant findings — reuse proven strategies and avoid past mistakes.

### Step 3: Analyze Feature Context
1.  Read `context.json` — get `current_feature`, `architecture_style`, `project_structure_convention`.
2.  Read ALL spec artifacts from `.sdd/spec/<feature-id>/`:
    -   `requirements.json` — functional/non-functional requirements and constraints.
    -   `architecture.json` — components, data flow, architectural decisions.
    -   `object_design.json` — classes, interfaces, relationships.
    -   `data_api.json` — DB entity schemas and API endpoint definitions.
    -   `openapi.yaml` — API contract (request/response schemas).

### Step 4: Pre-Plan Clarification
Before generating tasks, check for concerns:
- "This feature requires a new DB migration. Which task should handle it?"
- "Found a similar pattern `crud-api` (tags: crud, rest). Apply it or customize?"
- "Spec item REQ-003 still has open clarifications. Resolve via `/sdd-design` first?"

Present BLOCKING concerns to user and **STOP**. Wait for user resolution. Skip if no concerns.

### Step 5: Generate Tasks
-   **If Pattern Match Found**:
    -   Load Pattern Task List.
    -   Replace placeholders (e.g., `{{Entity}}` → `User`).
    -   Cross-reference with spec artifacts to ensure all requirements, classes, endpoints, and entities are covered.
    -   Adjust `target_path` to match `project_rules.md` conventions.
    -   Output `tasks.json`.
-   **If No Match**:
    -   Parse ALL spec artifacts (`requirements.json`, `architecture.json`, `object_design.json`, `data_api.json`, `openapi.yaml`).
    -   Identify Endpoints, Models, Services.
    -   Map each class/interface from `object_design.json` to a task, ensuring class names, method signatures, and layer placement are preserved in the task description.
    -   Map each entity from `data_api.json` to a data-layer task (migration, repository, etc.).
    -   Verify every functional requirement in `requirements.json` is addressed by at least one task.
    -   Generate `target_path` for each task based on project rules.
    -   Generate fresh `tasks.json`.

### Step 6: Guardrail Validation
After generating tasks, invoke `sdd-guardrails` with context `"plan"`:
-   **Path Convention Check**: Verify each task's `target_path` matches the architecture style.
    -   Validate each task's `target_path` matches the conventions declared in `project_rules.md`.
-   **Rule Compliance**: Ensure task descriptions don't contradict `project_rules.md`.
-   If violations found → fix tasks → re-validate.

### JSON Writing Rule
When writing `tasks.json`, you **MUST use the file writing tools**. All string values MUST have special characters properly escaped (`\"`, `\\`, `\n`, `\t`, control chars). Validate JSON is well-formed before writing to disk. If validation fails, fix escaping issues before saving.

### Step 7: Finalize
1.  Write `tasks.json` to `.sdd/plan/<feature-id>/tasks.json`.
2.  Update `context.json.current_stage` to `"plan-complete"`.

## Output

Generates `.sdd/plan/<feature-id>/tasks.json` containing:
-   **Task Groups**: Logical grouping of tasks.
-   **Dependencies**: Explicit blocking relationships.
-   **Target Paths**: Expected file paths for each task's output.
-   **Estimated Effort**: Based on historical data from similar patterns.

## Post-step: Feedback Capture (MANDATORY)

After presenting the plan to the user, if the user adjusts the generated plan (changes task granularity, reorders tasks, rejects a pattern match):
1.  Apply the requested changes to `tasks.json`.
2.  **Immediately** write a lesson to `.sdd/knowledge/lessons/` capturing:
    -   What was originally planned vs what the user changed.
    -   Why the adjustment was needed.
    -   Tags for future retrieval (feature name, `planning-tasks`, domain keywords).

This is NOT optional. Every user adjustment to the plan MUST be recorded as a lesson.

## Integration

-   **Input**: `context.json`, `project_rules.md`, `.sdd/spec/<feature-id>/*` (`requirements.json`, `architecture.json`, `object_design.json`, `data_api.json`, `openapi.yaml`), `sdd-knowledge-base`.
-   **Output**: `.sdd/plan/<feature-id>/tasks.json` (consumed by `sdd-implementer`).
-   **Invokes**: `sdd-guardrails` (plan-level checks).
