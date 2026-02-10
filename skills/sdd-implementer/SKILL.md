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

-   `/sdd-impl-start <task-id>`: Load context and scaffold code.
-   `/sdd-impl-finish`: Mark task complete, trigger auto-verification, and enforce knowledge extraction.
-   `/sdd-impl-fix`: Request a fix for a failed guardrail check.

## Scaffolding Logic

When `/sdd-impl-start` is called:
1.  Check Task Type (e.g., "Create Endpoint").
2.  **Check Context**: Read `.sdd/context/context.json` to determine Language, Framework, and `current_feature`.
3.  **Read Task**: Load from `.sdd/plan/<feature-id>/tasks.json` using the task ID.
4.  **Validate Target Path**: Ensure the task's `target_path` follows `project_rules.md` conventions.
5.  **Query Knowledge Base**: Look for existing patterns in `knowledge/patterns/` matching the stack and **tags**.
6.  **Generate/Scaffold**:
    -   If a pattern exists, use it.
    -   If not, generate idiomatic code based on `project_rules.md` and the technology stack.
7.  Place generated code at the `target_path` specified in the task.

## Feedback Loop (Drift Management)

If the developer (or agent) realizes the `openapi.yaml` is missing a field during implementation:
1.  **Do NOT** just hack the code.
2.  Call `/sdd-spec-update` (via `sdd-design-engine`).
3.  Wait for Spec update.
4.  Record a lesson: the gap between spec and reality.
5.  Resume implementation.

## Completion & Mandatory Knowledge Extraction

When `/sdd-impl-finish` is called:

### Step 1: Verification
1.  Run guardrail checks (`/sdd-guard-check code`) on all implemented files.
2.  Verify all tasks for the feature have status `done` or `verified`.

### Step 2: Knowledge Extraction (MANDATORY)
Instead of asking "would you like to save patterns?", the agent **auto-generates drafts** for user confirmation:

1.  **Pattern Draft**: Analyze the implemented code for reusable patterns.
    -   Identify repeating code structures (e.g., "CRUD endpoint with validation and error handling").
    -   Generate a draft pattern with suggested **tags** (e.g., `["crud", "rest", "validation"]`).
    -   Present to user: "I identified this reusable pattern. Confirm to save, edit, or skip."

2.  **Lesson Draft**: Review the feature's history for gaps:
    -   Were there spec updates (`/sdd-spec-update` calls)?
    -   Were there guardrail failures?
    -   Were there user corrections during clarification?
    -   For each gap, generate a draft lesson.
    -   Present to user: "I found these lessons from this feature. Confirm, edit, or skip."

3.  **Save Confirmed Items**:
    -   Patterns → `.sdd/knowledge/patterns/<pattern-id>.json`
    -   Lessons → `.sdd/knowledge/lessons/<lesson-id>.json`
    -   Update `context.json.active_patterns` and `context.json.applied_lessons`.

### Step 3: Feature Archival
1.  Copy spec + plan snapshot to `.sdd/features/<feature-id>/`.
2.  Move feature from `current_feature` to `completed_features`.
3.  Reset `current_stage` to `"init"` and `current_feature` to `null`.

## During-Implementation Lessons

Lessons are not only recorded at `/sdd-impl-finish`. During implementation, if:
-   A spec update is triggered → record as lesson
-   A guardrail fails and is fixed → record as lesson
-   An unexpected framework behavior is encountered → record as lesson

These are recorded immediately via `/sdd-learn`, not deferred to finish.

## Integration

-   **Consumes**: `.sdd/plan/<feature-id>/tasks.json`, `project_rules.md`, `knowledge/patterns` (by tags).
-   **Invokes**: `sdd-guardrails` (for verification), `sdd-design-engine` (for spec updates), `sdd-knowledge-base` (for pattern/lesson saving).
