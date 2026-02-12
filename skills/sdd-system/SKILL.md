---
name: sdd-system
description: "Project Manager: Initialization, Status Tracking, and High-Level Coordination."
dependencies:
  - sdd-knowledge-base
---

# SDD System

This skill is the entry point for the Compounding Engineering framework. It handles initialization, feature lifecycle management, and global status.

## Core Responsibilities

1.  **Project Initialization**: Setup `.sdd/` directory, `project_rules.md`, and Knowledge Base directories.
2.  **Feature Lifecycle**: Manage features from creation through design → plan → impl → complete → learn.
3.  **Global Status**: Display the "Big Picture" (Current Stage + Active Feature + Velocity + Knowledge Stats).
4.  **Coordination**: Ensure other skills (Design, Guardrails, Planner) are installed and healthy.

## Commands

-   `/sdd-init`: Initialize a new Compounding Engineering project.
-   `/sdd-status`: Display current project health, active stage, active feature, and recent lessons learned.
-   `/sdd-nuke`: (Dangerous) Reset internal state but keep learned patterns and lessons.

## Initialization Logic

When `/sdd-init` is called:
1.  Check for `.sdd/` directory.
2.  Create full directory structure:
    - `context/` — `context.json`, `project_rules.md`
    - `spec/` — Feature-scoped spec subdirectories
    - `plan/` — Feature-scoped plan subdirectories
    - `features/` — Feature snapshot archive (spec + plan per feature)
    - `knowledge/index.json` — Lightweight knowledge index (initialize as `{ "patterns": {}, "lessons": {} }`)
    - `knowledge/patterns/` — Reusable design/code patterns
    - `knowledge/lessons/` — Lessons learned from past work
    - `data/`, `logs/`, `temp/`
3.  Generate initial `context.json` from template (includes `current_stage`, `current_feature`, etc.). **JSON Writing Rule**: All string values MUST have special characters properly escaped (`\"`, `\\`, `\n`, `\t`, control chars). Validate JSON is well-formed before writing to disk.
4.  Generate initial `project_rules.md` template.
5.  Report: "Project initialized. Ready for `/sdd-design`."

## Feature Lifecycle

Each feature follows this lifecycle, tracked via `context.json.current_stage`:

```
init → design → design-complete → plan → plan-complete → impl → impl-complete
```

### Starting a Feature
1.  User provides feature name/intent.
2.  Set `context.json.current_feature` to the feature ID (e.g., `user-auth`).
3.  Create directory: `.sdd/spec/<feature-id>/` and `.sdd/plan/<feature-id>/`.
4.  Set `context.json.current_stage` to `"design"`.

### Completing a Feature
1.  All tasks in `tasks.json` reach `"done"` or `"verified"` status.
2.  `/sdd-impl-finish` triggers mandatory knowledge extraction (reads `.sdd/logs/session.md` for cross-session history).
3.  **MOVE** (not copy) `.sdd/spec/<feature-id>/` and `.sdd/plan/<feature-id>/` into `.sdd/features/<feature-id>/`.
4.  Move feature ID from `current_feature` to `completed_features`.
5.  Reset `current_stage` to `"init"` and `current_feature` to `null`.
6.  Clear `.sdd/logs/session.md`.

## Status Display

When `/sdd-status` is called, display:
- **Active Feature**: `context.json.current_feature` (or "None")
- **Current Stage**: `context.json.current_stage`
- **Completed Features**: Count of `context.json.completed_features`
- **Knowledge Stats**: Number of patterns in `knowledge/patterns/`, lessons in `knowledge/lessons/`
- **Active Patterns**: `context.json.active_patterns`
- **Applied Lessons**: `context.json.applied_lessons`

## Integration

-   **Consumes**: `sdd-knowledge-base` (for status and knowledge stats).
-   **Directs**: Users to `/sdd-design` or `/sdd-plan` based on `current_stage`.
