---
name: sdd-system
description: "Project Manager: Initialization, Status Tracking, and High-Level Coordination."
dependencies:
  - sdd-knowledge-base
---

# SDD System

This skill is the entry point for the Compounding Engineering framework. It handles initialization and global status, leaving value creation to the specialized engines.

## Core Responsibilities

1.  **Project Initialization**: Setup `project_rules.md` and Knowledge Base.
2.  **Global Status**: Display the "Big Picture" (Current Stage + Active Feature + Velocity).
3.  **Coordination**: Ensure other skills (Design, Guardrails, Planner) are installed and healthy.

## Commands

-   `/sdd-init`: Initialize a new Compounding Engineering project.
-   `/sdd-status`: Display current project health, active stage, and recent lessons learned.
-   `/sdd-nuke`: (Dangerous) Reset internal state but keep learned patterns.

## Initialization Logic

When `/sdd-init` is called:
1.  Check for `.sdd/` directory.
2.  If missing, create headers for `knowledge/patterns/` and `knowledge/lessons/`.
3.  Generate initial `project_rules.md` template.
4.  Report: "Project initialized. Ready for `/sdd-design`."

## Integration

-   **Consumes**: `sdd-knowledge-base` (for status).
-   **Directs**: Users to `/sdd-design` or `/sdd-plan` based on state.
