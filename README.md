# SDD Skills - Compounding Engineering Framework

A next-generation Spec-Driven Development (SDD) framework designed for **Compounding Engineering**. It doesn't just manage the lifecycle; it accumulates knowledge (patterns, templates, lessons) to make every future feature faster to build.

## Core Philosophy

1.  **Compounding**: Every feature built should make the next one faster via reusable patterns and templates.
2.  **Frictionless**: Automate state management. No "commit" commands. The system saves as you go.
3.  **Guardrails**: Continuous validation running *inside* every stage, not just as a final gate.

## Quick Start

### 1. Installation

Copy the skill directories to your project's `.agent/skills/` folder:

```bash
cp -r ./skills/* .agent/skills/
```

### 2. Initialization

```bash
/sdd-init
```
Sets up the `.sdd/` directory structure and default configuration.

### 3. Workflow

**Phase 1: Design**
```bash
/sdd-design
```
Analyzes your requirements, generates architecture diagrams, and defines the API spec.
*Shortcuts:* `/sdd-design-requirements`, `/sdd-design-architecture`, `/sdd-design-api`

**Phase 2: Plan**
```bash
/sdd-plan
```
Generates an implementation plan with concrete tasks, leveraging past patterns.

**Phase 3: Implement**
```bash
/sdd-impl-start <TASK-ID>
```
Scaffolds code from templates and starts the implementation.

```bash
/sdd-impl-finish
```
Marks the task as complete and triggers final verification.

```bash
/sdd-impl-fix
```
Request a fix if guardrails fail.

## Storage Structure

All SDD artifacts are stored in the `.sdd/` directory. **Do not edit these manually** unless you know what you are doing.

```
.sdd/
├── context/              # Global Project Context & Rules
├── spec/                 # Requirements, Architecture, and API Specs
├── plan/                 # Task Lists & Implementation Plans
├── data/                 # Raw Data Store
├── knowledge/            # The "Learning" Layer
│   ├── patterns/         # Reusable Design/Code Patterns
│   └── lessons/          # Avoidance Rules
└── logs/                 # Operational Logs
```

## Skills Overview

| Skill | Role | Description |
|-------|------|-------------|
| [sdd-system](./sdd-system/SKILL.md) | **Manager** | Orchestrates the project lifecycle, initialization, and global status. |
| [sdd-design-engine](./sdd-design-engine/SKILL.md) | **Architect** | Unifies Requirements -> Systems -> API design into a single, fluid flow. |
| [sdd-knowledge-base](./sdd-knowledge-base/SKILL.md) | **Brain** | The central store for State, Design Patterns, and Lessons Learned. |
| [sdd-guardrails](./sdd-guardrails/SKILL.md) | **Safety** | Continuous validation checks embedded in other skills (design & implementation). |
| [sdd-task-planner](./sdd-task-planner/SKILL.md) | **Planner** | Generates implementation plans by matching new requests against past tasks. |
| [sdd-implementer](./sdd-implementer/SKILL.md) | **Builder** | Scaffolds code from templates and handles the feedback loop to specs. |

## License

MIT
