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
2.  **Feature Lifecycle**: Manage features from creation through request → design → plan → impl → complete → learn.
3.  **Global Status**: Display the "Big Picture" (Current Stage + Active Feature + Velocity + Knowledge Stats).
4.  **Coordination**: Verify `.sdd/` directory structure integrity (all required subdirectories and `context.json` exist and are well-formed).

## Commands

-   `/sdd-init [project principles]`: Initialize a new Compounding Engineering project. Optional args define the project's guiding principles (e.g., `/sdd-init product should be testable, high-quality and implement by MVP never overdesign`).
-   `/sdd-status`: Display current project health, active stage, active feature, and recent lessons learned.
-   `/sdd-nuke`: (Dangerous) Reset internal state but keep learned patterns and lessons.

## Initialization Logic

When `/sdd-init` is called:

### Step 1: Create Directory Structure
Check for `.sdd/` directory and create the full structure:
- `context/` — `context.json`, `project_rules.md`
- `spec/` — Feature-scoped spec subdirectories
- `plan/` — Feature-scoped plan subdirectories
- `features/` — Feature snapshot archive (spec + plan per feature)
- `knowledge/index.json` — Lightweight knowledge index (initialize as `{ "patterns": {}, "lessons": {} }`)
- `knowledge/patterns/` — Reusable design/code patterns
- `knowledge/lessons/` — Lessons learned from past work
- `data/`, `logs/`, `temp/`

### Step 2: Project Discovery
Before generating config files, gather project context. This information is critical — downstream skills (design, planning, guardrails, implementation) all depend on `context.json` and `project_rules.md` to make informed decisions.

**a) Auto-detect from codebase** — scan the working directory for project markers:
-   Package/dependency files (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, `pom.xml`, `build.gradle`, `*.csproj`, etc.) → infer language, framework, build tools
-   Existing directory structure → infer architecture style and conventions
-   Config files (`.eslintrc`, `tsconfig.json`, `Makefile`, `Dockerfile`, etc.) → infer tooling
-   Test directories/files → infer testing framework and strategy

**b) Present findings and ask the user to confirm or adjust:**
1.  **Tech stack**: Language(s), framework(s), build tool(s), package manager — "I detected X. Is this correct?"
2.  **Architecture style**: Inferred from directory structure, or ask if unclear — "How is your project organized?" (e.g., feature-first, layer-first, module-based, monorepo, flat, etc.)
3.  **Directory conventions**: Where source code, tests, configs live — "Your source appears to be in `src/`, tests in `tests/`. Correct?"
4.  **Testing strategy** (if applicable): Detected test framework and approach — "I see Jest/pytest/etc. What types of tests does this project use?" If no test framework is detected, ask whether the user plans to have tests — don't assume.
5.  **Verify commands** (if applicable): Only ask about commands that are relevant to the project. A Python script might have no build step; a prototype might have no tests. Only document commands that actually exist.

If auto-detection finds nothing (empty or new project), ask the user directly. Keep the conversation concise — ask all questions in one message, not one at a time.

**CRITICAL INSTRUCTION: DO NOT PROCEED TO STEP 3 YET.** Stop your response here and wait for the user to answer your questions. Only proceed to Step 3 in your next response after the user has confirmed or adjusted the project discovery findings.

**c) If user provided args** (e.g., `/sdd-init MVP-first, testable, no overdesign`): Remember to incorporate them as the "General Principles" section in `project_rules.md` when you generate it later.

### Step 3: Generate Configuration (Only AFTER User Confirmation)
1.  Generate `context.json` from template, populated with the discovered values:
    -   `tech_stack`: filled with detected/confirmed language, framework, tooling
    -   `architecture_style`: filled with confirmed architecture style
    -   `project_structure_convention`: filled with confirmed directory conventions
    -   **JSON Writing Rule**: All string values MUST have special characters properly escaped (`\"`, `\\`, `\n`, `\t`, control chars). Validate JSON is well-formed before writing to disk.
2.  Generate `project_rules.md` tailored to the project:
    -   **Coding Standards**: Based on detected language/framework conventions
    -   **Architecture**: Based on confirmed architecture style and directory conventions
    -   **Testing**: Based on detected test framework and confirmed strategy
    -   **Verify Commands** (if any): Document whatever build/test/lint commands exist so `sdd-implementer` can run per-task verification. Omit this section entirely if the project has no such commands.
    -   Start from the template in `templates/project_rules.md`, then fill in project-specific details

### Step 4: Report
Report: "Project initialized. Here's what I configured:" — show a summary of `tech_stack`, `architecture_style`, and key `project_rules.md` sections. Then: "Ready for `/sdd-request`."

## Feature Lifecycle

Each feature follows this lifecycle, tracked via `context.json.current_stage`:

```
init → request → request-complete → design → design-complete → plan → plan-complete → impl → impl-complete
```

### Starting a Feature
> **Executed by `sdd-request-engine`** — see `sdd-request-engine/SKILL.md` Step 2 for the canonical implementation.

1.  User provides feature name/intent via `/sdd-request`.
2.  `sdd-request-engine` reads `context.json.feature_counter`, generates the feature ID, creates directories, and sets `current_stage` to `"request"`.

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
