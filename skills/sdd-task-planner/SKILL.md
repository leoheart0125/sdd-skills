---
name: sdd-task-planner
description: "Intelligent planning engine that uses historical patterns to generate implementation tasks."
dependencies:
  - sdd-design-engine
  - sdd-knowledge-base
---

# SDD Task Planner

This skill transforms specifications into actionable plans, but unlike a simple generator, it **learns**. It checks the Knowledge Base for similar past features to reuse successful plans.

## Core Responsibilities

1.  **Pattern Matching**: Query `sdd-knowledge-base` for tasks similar to the current feature.
2.  **Smart Generation**: If a pattern exists, hydrate it. If not, generate new tasks from `openapi.yaml`.
3.  **Optimization**: Order tasks to minimize context switching (e.g., group all DB tasks, then all API tasks).

## Commands

-   `/sdd-plan`: Generate or update the implementation plan (`tasks.json`).
-   `/sdd-plan-optimize`: Re-sort tasks based on dependencies and developer availability.

## Pattern Logic

When `/sdd-plan` is called:
1.  Analyze `context.json` (Feature Name/Description).
2.  Search `knowledge/patterns/` for matches (e.g., "Feature: CRUD API").
3.  **If Match Found**:
    -   Load Pattern Task List.
    -   Replace placeholders (e.g., `{{Entity}}` -> `User`).
    -   Output `tasks.json`.
4.  **If No Match**:
    -   Parse `openapi.yaml`.
    -   Identify Endpoints, Models, Services.
    -   Generate fresh `tasks.json`.

## Output

Generates `.sdd/tasks/tasks.json` containing:
-   **Task Groups**: Logical grouping of tasks.
-   **Dependencies**: Explicit blocking relationships.
-   **Estimated Effort**: Based on historical data from similar patterns.

## Integration

-   **Input**: `context.json`, `openapi.yaml`, `sdd-knowledge-base`.
-   **Output**: `tasks.json` (consumed by `sdd-implementer`).
