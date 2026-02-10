---
name: sdd-knowledge-base
description: "The 'Brain' of the project: manages state (Context), accumulates knowledge (Patterns + Lessons), and evolves rules."
dependencies: []
---

# SDD Knowledge Base

This skill is the central nervous system of the SDD framework. It goes beyond simple state persistence ("Context Management") to enable true **Compounding Engineering** through knowledge accumulation.

## Core Responsibilities

1.  **State Management**: Persist the current snapshot of the project design (`context.json`).
2.  **Pattern Library**: Store and retrieve reusable design/implementation patterns by **tags**.
3.  **Lessons Learned**: Record "what went wrong" and "what to avoid" to prevent repeated mistakes.
4.  **Rule Evolution**: Automatically update `project_rules.md` based on observed conventions and repeated lessons.

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
-   `tags`: Cross-feature retrieval tags (e.g., `["auth", "jwt", "api"]`)
-   `context`: When to use this pattern
-   `solution`: The verified design/code snippet

**Tag-based retrieval**: When `sdd-task-planner` or `sdd-design-engine` searches for patterns, they match by tags rather than feature IDs. This enables patterns from a "user-auth" feature to be discoverable when building an "admin-auth" feature.

### 2. Lessons (`.sdd/knowledge/lessons/`)
-   `lesson_id`: Unique ID
-   `trigger`: When to recall this lesson (e.g., `"designing-auth"`, `"guard-check-code"`)
-   `advice`: The specific guidance (e.g., `"Always add indexes to foreign keys"`)

### 3. State (`.sdd/context/context.json`)
The source of truth for the *current* project state.
```json
{
    "project_name": "...",
    "tech_stack": { ... },
    "architecture_style": "...",
    "project_structure_convention": "...",
    "current_stage": "design",
    "current_feature": "user-auth",
    "completed_features": ["health-monitoring"],
    "active_patterns": ["auth-jwt-flow"],
    "applied_lessons": ["db-index-fk"]
}
```

## Lesson Recording: When and Where

### Core Principle

**Lessons come from gaps — the gap between expectation and reality.** No gap, no lesson needed.

### Triggers by Phase

#### Design Phase — When specs are corrected
-   User points out missing or misunderstood requirements
-   Guardrail detects ambiguity or contradiction
-   Architecture choice is rejected by user

```json
{
    "trigger": "designing-auth",
    "advice": "This project requires SSO support. Do not assume password-only login."
}
```

#### Plan Phase — When plans are adjusted
-   Task granularity adjusted by user (too coarse or too fine)
-   Task order rearranged
-   Conflict found between `project_rules` and generated plan

```json
{
    "trigger": "planning-tasks",
    "advice": "This project prefers one task per commit. Keep granularity at single-responsibility level."
}
```

#### Implementation Phase — Two sub-triggers

**a) During implementation (obstacles encountered):**
-   Spec missing a field, triggering `/sdd-spec-update`
-   Framework behavior differs from expectation
-   Third-party API has undocumented limitations

```json
{
    "trigger": "implementing-api-endpoint",
    "advice": "Prisma createMany does not support returning. Use transaction + create instead."
}
```

**b) After implementation (`/sdd-impl-finish`):**
-   Issues found and fixed during guardrail checks
-   Root causes of spec drift
-   Any "I wish I had known..." insights

#### Guardrail Phase (Cross-cutting)

Every guardrail fail → fix → pass cycle is a lesson.

```json
{
    "trigger": "guard-check-code",
    "advice": "Response DTO must exactly match OpenAPI schema. Do not add extra wrappers."
}
```

### Recording Principles

| Principle | Description |
|---|---|
| **Correction = Record** | Whenever agent output is rejected by user or guardrail and corrected, that's a lesson |
| **Surprise = Record** | Unexpected behavior from frameworks, DB, or third-party services |
| **Repetition = Upgrade** | If the same lesson triggers twice, promote it to a `project_rule` via `/sdd-rule-update` |
| **Don't record smooth sailing** | When everything works as expected, no lesson is needed — avoid noise |

### Event-Driven, Not Phase-Driven

Lesson writing is **not** bound to a single fixed command. Instead, every stage's **guardrail failure** and **user correction** should trigger `/sdd-learn`. The mechanism is event-driven: the lesson is recorded at the moment the gap is detected.

## Auto-Evolution Logic

When `/sdd-rule-update` is triggered (often by `sdd-implementer` noticing a recurring manual fix, or by the Repetition = Upgrade principle):
1.  Analyze the proposed rule.
2.  Check for conflicts with existing rules.
3.  Append to `project_rules.md` under "Evolved Conventions".

## Integration

-   **Called by**: `sdd-design-engine` (to save state, to learn from corrections), `sdd-implementer` (to learn lessons), `sdd-guardrails` (to learn from failures).
-   **Consulted by**: `sdd-task-planner` (to find patterns by tags), `sdd-guardrails` (to enforce lessons), `sdd-design-engine` (to suggest patterns).
