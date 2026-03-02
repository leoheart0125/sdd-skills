---
name: sdd-implementer
description: "Execution engine that turns plans into code using scaffold templates and feedback loops."
dependencies:
  - sdd-task-planner
  - sdd-guardrails
  - sdd-knowledge-base
---

# SDD Implementer

This skill handles the "last mile" of development. It focuses on speed and consistency by using verified templates (Scaffolds) and enforcing knowledge capture on completion.

## Core Responsibilities

1.  **Scaffold Execution**: Use `sdd-knowledge-base` templates (matched by tags) to generate boilerplate code instantly.
2.  **Feedback Loop**: If implementation reveals a spec issue, trigger `/sdd-spec-update`.
3.  **Mandatory Knowledge Capture**: After feature completion, enforce pattern/lesson extraction.

## Commands

-   `/sdd-impl-start [task-id]`: Load context and scaffold code. If `task-id` is omitted, executes **all** pending tasks in dependency order. If `task-id` is provided, executes only the specified task.
-   `/sdd-impl-finish`: Mark task complete, trigger auto-verification, and enforce knowledge extraction.
-   `/sdd-impl-fix`: Request a fix for a failed guardrail check.

## Scaffolding Logic

When `/sdd-impl-start` is called:

### Execution Mode Resolution
-   **If `task-id` is provided**: Execute scaffolding for that single task (steps below).
-   **If `task-id` is omitted (batch mode)**:
    1.  Read `.sdd/plan/<feature-id>/tasks.json`.
    2.  Filter tasks where `status` is NOT `"done"` and NOT `"verified"`.
    3.  Sort remaining tasks by dependency order (tasks with no unresolved dependencies first).
    4.  Execute the scaffolding flow below **for each task sequentially**.
    5.  After completing each task, log progress (e.g., "Task 3/5 complete") and proceed to the next automatically.

### Per-Task Scaffolding Flow
1.  **Read Project Rules (MANDATORY FIRST STEP)**:
    1.  Load `project_rules.md` from `.sdd/context/`.
    2.  Extract **Coding Standards** (naming conventions, function size, documentation rules).
    3.  Extract **Architecture** conventions (directory structure, layer ordering, dependency direction).
    4.  Extract **Testing** requirements (unit test expectations, integration test scope).
    5.  These rules constrain ALL subsequent code generation. Every line of generated code MUST comply.
2.  Check Task Type (e.g., "Create Endpoint").
3.  **Check Context**: Read `.sdd/context/context.json` to determine Language, Framework, and `current_feature`.
4.  **Read Task**: Load from `.sdd/plan/<feature-id>/tasks.json` using the task ID.
5.  **Read Design Spec (MANDATORY)**: Load **all available** spec artifacts from `.sdd/spec/<feature-id>/` and identify elements relevant to this task. The following may exist depending on the feature's design:
    -   `architecture.json` — component boundaries, layer structure, data flow direction (always present).
    -   `object_design.json` — design unit definitions, properties, method signatures, relationships (if applicable).
    -   `data_api.json` — data entity schemas, field types, relationships (if feature involves persistent data).
    -   `openapi.yaml` — API contracts, request/response schemas, status codes (if feature involves HTTP APIs).
    -   `interface_contract.json` — non-HTTP interface definitions (if applicable).
    The generated code MUST conform to whichever specs are present:
    -   Use the exact names defined in `object_design.json`.
    -   Implement all properties and method signatures as specified.
    -   Respect the layer assignments.
    -   Maintain the relationships (dependency, composition, implementation, etc.) as defined.
    -   Follow component boundaries and data flow direction from `architecture.json`.
    -   Match the contracts defined in any interface spec artifacts that are present.
    -   If a spec artifact does not exist for this feature, that aspect is unconstrained.
    -   If a task maps to no design unit in `object_design.json`, proceed without constraint but log a warning in the session log.
6.  **Validate Target Path**: Ensure the task's `target_path` follows `project_rules.md` conventions.
7.  **Query Knowledge Base (Index-Based)**: Read `.sdd/knowledge/index.json`, filter `patterns` by tags matching the current task's domain and stack. Load ONLY the matched pattern files. Do NOT scan the full `patterns/` directory.
8.  **Output the knowledge match results** before generating code:

```
📚 **Knowledge Loaded** (stage: impl)

| Type | ID | Matched Tags | Summary |
|------|----|-------------|---------|
| <type> | <id> | `<tag1>`, `<tag2>` | <summary> |

> No knowledge matched. (if empty)
```

9.  **Generate/Scaffold**:
    -   If a pattern exists, use it as a base, but override with the design spec (names, contracts, schemas) from Step 5.
    -   If not, generate idiomatic code based on the available design specs from Step 5, `project_rules.md`, and the technology stack.
10.  Place generated code at the `target_path` specified in the task using the **write_file tool**.

## Session Log (MANDATORY)

After completing each task, or when the user provides feedback/corrections during implementation, **append** an entry to `.sdd/logs/session.md` (see `templates/session.md` for format) with:
-   Timestamp and task ID
-   What was done or changed
-   Any user feedback or corrections applied
-   Any spec drift or guardrail failures encountered

This log **persists across sessions** and is the primary input for knowledge extraction at `/sdd-impl-finish`. Without it, lessons from previous sessions are lost.

## Feedback Loop (Drift Management)

If the developer (or agent) realizes any spec artifact (`openapi.yaml`, `object_design.json`, `data_api.json`) is missing a field or has an inconsistency during implementation:
1.  **Do NOT** just hack the code.
2.  Call `/sdd-spec-update` (via `sdd-design-engine`).
3.  Wait for Spec update.
4.  Record a lesson: the gap between spec and reality.
5.  Resume implementation.

## Task Completion Behavior

After each task is implemented:
1.  **Per-Task Build Verification (MANDATORY)**:
    1.  Run the project's build / type-check / compile command (determined from `context.json` and `project_rules.md`) to catch errors immediately. If no build commands are defined in `project_rules.md`, skip automated build verification and note this in the session log.
    2.  Run unit tests relevant to the current task (e.g., the spec file co-located with the generated code). If no test commands are defined, skip and note in the session log.
    3.  If either check fails, fix the errors **before** marking the task as done. Log all failures and fixes in the session log.
    4.  This ensures errors are caught early per-task rather than accumulating to the finish phase.
2.  Update the task's status to `done` in `tasks.json`.
3.  Append the session log entry as described above.
4.  Inform the user of progress (e.g., "Task 3/5 complete").
5.  **In batch mode**: Automatically proceed to the next pending task.
6.  **In single-task mode**: Stop after the specified task.
7.  **Do NOT auto-trigger the finish flow.** The verification, knowledge extraction, and archival steps below are ONLY executed when the user explicitly calls `/sdd-impl-finish`.

## Completion & Mandatory Knowledge Extraction

> **User-Triggered Only**: This entire flow is ONLY executed when the user explicitly calls `/sdd-impl-finish`. Never run it automatically after completing tasks.

When `/sdd-impl-finish` is called:

### Step 1: Verification
1.  Run guardrail checks (`/sdd-guard-check code`) on all implemented files.
2.  Run the **full build** and **all tests** (unit + integration) to ensure end-to-end correctness. Use the build/test commands from `project_rules.md`. Per-task verification catches local errors early; this step catches cross-task integration issues.
3.  Verify all tasks for the feature have status `done` or `verified`.
4.  If build or tests fail, fix the issues before proceeding. Log all failures and fixes in the session log.
5.  **Only after all checks pass**, set `context.json.current_stage` to `"impl-complete"`. This is the sole trigger for `impl-complete` — it is NOT set automatically when tasks finish.

### Step 2: Knowledge Extraction (MANDATORY)
Instead of asking "would you like to save patterns?", the agent **auto-generates drafts**, triages them, and presents for user confirmation:

1.  **Read Session Log**: Load `.sdd/logs/session.md` for the full implementation history across ALL sessions. This is the primary source of truth for what happened during implementation.

2.  **Pattern Draft**: Analyze the implemented code and session log for reusable patterns.
    -   Identify repeating code structures (e.g., "form with validation and error handling", "data fetching with caching", "CLI command with arg parsing").
    -   Generate a draft pattern with suggested **tags** (e.g., `["validation", "form", "error-handling"]`).

3.  **Lesson Draft**: Review session log AND current conversation for gaps:
    -   Were there spec updates (`/sdd-spec-update` calls)?
    -   Were there guardrail failures?
    -   Were there user corrections during clarification?
    -   For each gap, generate a draft lesson.

4.  **Knowledge Triage** (MANDATORY): Execute the full Knowledge Triage protocol as defined in `sdd-knowledge-base/SKILL.md` (Steps 1–4: Dedup → Specificity Check → Present triage table → Execute confirmed actions). Update `context.json.active_patterns` and `context.json.applied_lessons`.

### Step 3: Feature Archival
1.  **MOVE** (not copy) `.sdd/spec/<feature-id>/` and `.sdd/plan/<feature-id>/` into `.sdd/features/<feature-id>/spec/` and `.sdd/features/<feature-id>/plan/`.
2.  Move feature from `current_feature` to `completed_features`.
3.  Reset `current_stage` to `"init"` and `current_feature` to `null`.

### Step 4: Clear Session Log
Delete the contents of `.sdd/logs/session.md` (or remove the file) to start fresh for the next feature.

## During-Implementation Lessons

Lessons are not only recorded at `/sdd-impl-finish`. During implementation, if:
-   A spec update is triggered → record as lesson
-   A guardrail fails and is fixed → record as lesson
-   An unexpected framework behavior is encountered → record as lesson

These are recorded immediately via `/sdd-learn` (which applies Knowledge Triage — dedup and specificity check — before saving). Additionally, every such event MUST be appended to `.sdd/logs/session.md` so it is preserved across sessions.

## Integration

-   **Consumes**: `.sdd/plan/<feature-id>/tasks.json`, `.sdd/spec/<feature-id>/*` (`object_design.json`, `architecture.json`, `data_api.json`, `openapi.yaml`), `project_rules.md`, `knowledge/patterns` (by tags).
-   **Invokes**: `sdd-guardrails` (for verification), `sdd-design-engine` (for spec updates), `sdd-knowledge-base` (for pattern/lesson saving).
