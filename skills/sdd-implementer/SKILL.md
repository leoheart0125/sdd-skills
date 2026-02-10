---
name: sdd-implementer
description: "Execution engine that turns plans into code using scaffold templates and feedback loops."
dependencies:
  - sdd-task-planner
  - sdd-guardrails
  - sdd-knowledge-base
---

# SDD Implementer

This skill handles the "last mile" of development. It focuses on speed and consistency by using verified templates (Scaffolds).

## Core Responsibilities

1.  **Scaffold Execution**: Use `sdd-knowledge-base` templates to generate boilerplate code instantly.
2.  **Feedback Loop**: If implementation reveals a spec issue, trigger `/sdd-spec-update`.
3.  **Knowledge Capture**: After completion, suggest adding new patterns or rules.

## Commands

-   `/sdd-impl-start <task-id>`: Load context and scaffold code.
-   `/sdd-impl-finish`: Mark task complete and trigger auto-verification.
-   `/sdd-impl-fix`: Request a fix for a failed guardrail check.

## Scaffolding Logic

When `/sdd-impl-start` is called:
1.  Check Task Type (e.g., "Create Endpoint").
2.  **Check Context**: Read `.sdd/context/context.json` to determine Language & Framework.
3.  **Query Knowledge Base**: Look for existing patterns in `knowledge/patterns/` matching the stack.
4.  **Generate/Scaffold**:
    -   If a pattern exists, use it.
    -   If not, generate idiomatic code based on `project_rules.md` and the technology stack.

## Feedback Loop (Drift Management)

If the developer (or agent) realizes the `openapi.yaml` is missing a field during implementation:
1.  **Do NOT** just hack the code.
2.  Call `/sdd-spec-update` (via `sdd-design-engine`).
3.  Wait for Spec update.
4.  Resume implementation.

## Integration

-   **Consumes**: `tasks.json`, `project_rules.md`, `knowledge/patterns`.
-   **Invokes**: `sdd-guardrails` (for verification), `sdd-design-engine` (for updates).
