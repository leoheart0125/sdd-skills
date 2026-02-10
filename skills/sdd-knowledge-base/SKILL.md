---
name: sdd-knowledge-base
description: "The 'Brain' of the project: manages state (Context), accumulates knowledge (Patterns + Lessons), and evolves rules."
dependencies: []
---

# SDD Knowledge Base

This skill is the central nervous system of the SDD framework. It goes beyond simple state persistence ("Context Management") to enable true **Compounding Engineering** through knowledge accumulation.

## Core Responsibilities

1.  **State Management**: Persist the current snapshot of the project design (`context.json`).
2.  **Pattern Library**: Store and retrieve reusable design/implementation patterns.
3.  **Lessons Learned**: Record "what went wrong" and "what to avoid" to prevent repeated mistakes.
4.  **Rule Evolution**: Automatically update `project_rules.md` based on observed conventions.

## Commands

-   `/sdd-save` (Internal/Auto): Persist current `context.json` and generate `summary.md`.
-   `/sdd-load`: Restore context from disk.
-   `/sdd-learn`: Extract a "Lesson Learned" from the current conversation/incident.
    -   *Usage*: `/sdd-learn "Avoid using FLOAT for currency, use DECIMAL instead"`
-   `/sdd-pattern-save`: Save a reusable pattern from the current design.
    -   *Usage*: `/sdd-pattern-save "Standard JWT Auth Flow"`
-   `/sdd-rule-update`: Propose an update to `project_rules.md`.

## Data Structures

### 1. Patterns (`.sdd/knowledge/patterns/`)
Reusable JSON/Markdown templates for Architecture or Code.
-   `pattern_id`: Unique ID (e.g., `auth-jwt-flow`)
-   `context`: When to use this pattern
-   `solution`: The verified design/code snippet

### 2. Lessons (`.sdd/knowledge/lessons/`)
-   `lesson_id`: Unique ID
-   `trigger`: When to recall this lesson (e.g., "Designing Database")
-   `advice`: The specific guidance (e.g., "Always add indexes to foreign keys")

### 3. State (`.sdd/context.json`)
The source of truth for the *current* project state.
```json
{
  "project_state": { ... },
  "active_patterns": ["auth-jwt-flow"],
  "applied_lessons": ["db-index-fk"]
}
```

## Auto-Evolution Logic

When `/sdd-rule-update` is triggered (often by `sdd-implementer` noticing a recurring manual fix):
1.  Analyze the proposed rule.
2.  Check for conflicts with existing rules.
3.  Append to `project_rules.md` under "Evolved Conventions".

## Integration

-   **Called by**: `sdd-design-engine` (to save state), `sdd-implementer` (to learn lessons).
-   **Consulted by**: `sdd-task-planner` (to find patterns), `sdd-guardrails` (to enforce lessons).
