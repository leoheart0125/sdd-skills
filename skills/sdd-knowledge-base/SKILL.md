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
    -   *Usage*: `/sdd-learn "<what went wrong and what to do instead>"`
-   `/sdd-pattern-save`: Save a reusable pattern from the current design.
    -   *Usage*: `/sdd-pattern-save "<descriptive pattern name>"`
-   `/sdd-rule-update`: Propose an update to `project_rules.md`.
-   `/sdd-knowledge-reindex`: Rebuild `index.json` by scanning all pattern/lesson files (use only if index is corrupt or out of sync).

## Data Structures

### 0. Knowledge Index (`.sdd/knowledge/index.json`) — CRITICAL

The index is a lightweight manifest of all patterns and lessons. **All other skills MUST read only this file first**, then selectively load only the matching entries. This prevents full-scanning the knowledge directory and keeps context clean.

```json
{
    "patterns": {
        "<pattern_id>": {
            "tags": ["<domain>", "<technology>", "<concept>"],
            "summary": "One-line description for quick relevance check",
            "file": "patterns/<pattern_id>.json"
        }
    },
    "lessons": {
        "<lesson_id>": {
            "tags": ["<domain>", "<concept>"],
            "trigger": "<phase>-<domain>",
            "summary": "One-line description for quick relevance check",
            "file": "lessons/<lesson_id>.json"
        }
    }
}
```

**Index Sync Rules**:
-   Every `/sdd-pattern-save` and `/sdd-learn` call MUST update `index.json` atomically (add the new entry).
-   Every deletion of a pattern/lesson MUST remove its entry from `index.json`.
-   `/sdd-init` MUST create an empty index: `{ "patterns": {}, "lessons": {} }`.
-   If `index.json` is missing or corrupt, rebuild it by scanning all files in `patterns/` and `lessons/` (fallback only).

**Lookup Protocol** (used by all other skills):
1.  Read `.sdd/knowledge/index.json` (small, typically < 50 lines).
2.  Filter entries by matching `tags` against the current feature's domain keywords.
3.  For lessons, also match `trigger` against the current phase (e.g., `"designing-*"`, `"planning-*"`, `"implementing-*"`, `"guard-check-*"`).
4.  Load ONLY the matched files (typically 0–5 files instead of all).
5.  If no matches, proceed without loading any knowledge files.

### 1. Patterns (`.sdd/knowledge/patterns/`)
Reusable JSON templates for Architecture or Code. See `templates/pattern.json` for the canonical template.
**JSON Writing Rule**: When generating any JSON artifact, all string values MUST have special characters properly escaped (`\"`, `\\`, `\n`, `\t`, control chars). Verify JSON validity before writing to disk.

-   `id`: Unique ID — descriptive, kebab-case
-   `name`: Human-readable name describing the pattern
-   `tags`: Cross-feature retrieval tags — domain keywords, technologies, concepts
-   `problem`: When to use this pattern — the problem it solves
-   `solution`: The verified design/code approach
-   `example`: Optional code snippet, reference, or implementation note

**Tag-based retrieval**: When `sdd-task-planner` or `sdd-design-engine` searches for patterns, they match by tags rather than feature IDs. This enables patterns from one feature to be discoverable when building similar features in the same domain.

### 2. Lessons (`.sdd/knowledge/lessons/`)
See `templates/lesson.json` for the canonical template.

-   `id`: Unique ID — descriptive, kebab-case
-   `tags`: Cross-feature retrieval tags — domain keywords, technologies, concepts
-   `trigger`: When to recall this lesson — `<phase>-<domain>` format (e.g., `"designing-<domain>"`, `"implementing-<domain>"`, `"guard-check-code"`)
-   `context`: What happened — the gap between expectation and reality
-   `advice`: The specific guidance — actionable and concrete

### 3. State (`.sdd/context/context.json`)
The source of truth for the *current* project state.
```json
{
    "project_name": "...",
    "current_stage": "design",
    "current_feature": "<feature-id>",
    "completed_features": ["<past-feature-1>"],
    "active_patterns": ["<matched-pattern-id>"],
    "applied_lessons": ["<applied-lesson-id>"]
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

#### Plan Phase — When plans are adjusted
-   Task granularity adjusted by user (too coarse or too fine)
-   Task order rearranged
-   Conflict found between `project_rules` and generated plan

#### Implementation Phase — Two sub-triggers

**a) During implementation (obstacles encountered):**
-   Spec missing a field, triggering `/sdd-spec-update`
-   Framework or tool behavior differs from expectation
-   Third-party service has undocumented limitations

**b) After implementation (`/sdd-impl-finish`):**
-   Read `.sdd/logs/session.md` for the full cross-session implementation history (this is the primary source for lesson extraction — without it, lessons from previous sessions are lost)
-   Issues found and fixed during guardrail checks
-   Root causes of spec drift
-   Any "I wish I had known..." insights

#### Guardrail Phase (Cross-cutting)

Every guardrail fail → fix → pass cycle is a lesson.

### Recording Principles

| Principle | Description |
|---|---|
| **Correction = Record** | Whenever agent output is rejected by user or guardrail and corrected, that's a lesson |
| **Surprise = Record** | Unexpected behavior from frameworks, tools, platforms, or third-party services |
| **Repetition = Upgrade** | If the same lesson triggers twice, promote it to a `project_rule` via `/sdd-rule-update` |
| **Don't record smooth sailing** | When everything works as expected, no lesson is needed — avoid noise |

### Knowledge Triage (MANDATORY before saving)

Every time new patterns or lessons are drafted (during `/sdd-impl-finish`, `/sdd-learn`, or `/sdd-pattern-save`), apply the following triage before writing to disk:

#### Step 1: Dedup — Merge similar entries
1.  Read `.sdd/knowledge/index.json`.
2.  For each draft, check if an existing entry has **≥50% tag overlap** AND covers the same semantic advice/solution.
3.  If a near-duplicate exists:
    -   **Merge**: Update the existing entry to incorporate the new insight (broader tags, refined advice). Do NOT create a second entry.
    -   Update `index.json` accordingly (tags may expand, summary may update).
4.  If no duplicate, proceed to Step 2.

#### Step 2: Specificity Check — Filter out overly general entries
Classify each draft into one of three levels:

| Level | Definition | Action |
|-------|-----------|--------|
| **Project-wide** | Applies to ALL features regardless of domain (e.g., naming conventions, coding standards) | **Promote** to `project_rules.md` via `/sdd-rule-update`. Do NOT save as a lesson/pattern. |
| **Domain-specific** | Applies to a category of features sharing a domain or technology | **Save** as pattern/lesson with appropriate domain tags. |
| **Feature-specific** | Applies only to this exact feature and its specific implementation details | **Skip** — this is spec detail, not reusable knowledge. Archive naturally with the feature in `.sdd/features/`. |

#### Step 3: Present triage results to user
Show a summary table before saving:

```
| # | Type    | Title                        | Action           | Reason                          |
|---|---------|------------------------------|------------------|---------------------------------|
| 1 | Pattern | Reusable scaffold for X       | MERGE into P-003 | 80% overlap with existing       |
| 2 | Lesson  | Project-wide naming rule      | PROMOTE to rules | Project-wide, not feature-bound |
| 3 | Lesson  | Framework limitation in Y     | SAVE (new)       | Domain-specific, reusable       |
| 4 | Pattern | Feature-specific config       | SKIP             | Feature-specific detail         |
```

User confirms, edits, or overrides each action before execution.

#### Step 4: Execute and Update Index (CRITICAL)

After user confirms, execute each action AND **update `.sdd/knowledge/index.json`** atomically:

| Action | File Operation | Index Operation |
|--------|---------------|-----------------|
| **SAVE** | Write new file to `patterns/` or `lessons/` | **Add** new entry to `index.json` with `tags`, `summary`, `file` (and `trigger` for lessons) |
| **MERGE** | Update existing file in-place | **Update** existing entry in `index.json` (tags may expand, summary may change) |
| **PROMOTE** | Append to `project_rules.md` | No index change (not a pattern/lesson) |
| **SKIP** | No file written | No index change |

> [!CAUTION]
> If you write a pattern/lesson file but do NOT update `index.json`, the knowledge is **invisible** to all other skills. The index is the only lookup mechanism.

### Session Log as Cross-Session Memory

During implementation, all events (task completions, user corrections, spec drift, guardrail failures) are appended to `.sdd/logs/session.md`. This file persists across agent sessions and is the primary input for knowledge extraction at `/sdd-impl-finish`. After extraction, the log is cleared.

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
