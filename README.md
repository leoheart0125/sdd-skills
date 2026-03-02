# SDD Skills - Compounding Engineering Framework

A next-generation Spec-Driven Development (SDD) framework designed for **Compounding Engineering**. It uses an **Agentic Orchestrator** pattern to manage the lifecycle, accumulating knowledge (patterns, templates, lessons) to make every future feature faster to build.

## Core Philosophy

1.  **Compounding**: Every feature built should make the next one faster via reusable patterns (tagged for cross-feature retrieval) and lessons learned.
2.  **Frictionless**: Automate state management. No "commit" commands. The system saves as you go.
3.  **Guardrails**: Continuous validation running *inside* every stage, not just as a final gate. Programmatic enforcement of `project_rules.md`.
4.  **Clarity First**: Ambiguity Resolution Protocol ensures the agent asks questions before proceeding on assumptions.

## Quick Start

### 1. Installation

First, add this repository as a submodule to your project:

```bash
git submodule add https://github.com/pnetwork/sdd-skills.git
```

Then, depending on your preferred AI agent, run the corresponding installation script from your project root:

**For Claude Code (recommended):**

```bash
./sdd-skills/install.sh --agent claude
```

**For Gemini:**

```bash
./sdd-skills/install.sh --agent gemini
```

### 2. Initialization

```bash
/sdd-init product should be testable, high-quality and implement by MVP never overdesign
```
Sets up the `.sdd/` directory structure (including `knowledge/patterns/`, `knowledge/lessons/`, `features/`) and default configuration. Optional args define the project's guiding principles in `project_rules.md`.

### 3. Workflow

The **Orchestrator** (`AGENT.md`) routes commands to specialized sub-agents.

**Phase 0: Request (Request Agent)**
```bash
/sdd-request user authentication with social login
```
Acts as a **Product Manager** — discusses requirements interactively, asks clarifying questions, and produces a structured `request.md` with user stories, acceptance criteria, and scope. Auto-assigns a sequential feature ID (e.g., `001-user-auth`).

**Phase 1: Design (Design Agent)**
```bash
/sdd-design
```
Reads `request.md` and transforms it into technical specifications with **Ambiguity Resolution** (BLOCKING/WARNING/INFO concerns), generates architecture diagrams, object design, and defines interface contracts.

**Phase 2: Plan (Plan Agent)**
```bash
/sdd-plan
```
Reads `project_rules.md` first, then generates an implementation plan with concrete tasks (including `target_path` per task). Validates file placement against architecture conventions.

**Phase 3: Implement (Implement Agent)**
```bash
/sdd-impl-start
```
Executes all pending tasks in dependency order. Scaffolds code from templates (matched by tags) at each task's `target_path`. Optionally pass a task ID (`/sdd-impl-start <TASK-ID>`) to implement a single task.

```bash
/sdd-impl-finish
```
Marks the task as complete, triggers final verification, and **mandatorily extracts patterns and lessons** for the knowledge base.

**Knowledge Commands**
```bash
/sdd-rule-update "proposed rule"       # Propose a project rule update
```

## Command Formats

This project ships commands in two formats:

| Format | Location | For |
|--------|----------|-----|
| **Claude Code** (`.md`) | `.claude/commands/` | Claude Code CLI — slash commands like `/sdd-init` |
| **TOML** (`.toml`) | `commands/` | Other AI agents (Gemini CLI, etc.) |

## System Components

### Orchestrator
- **`AGENT.md`**: The central brain that routes commands, manages state, and delegates to specialized agents.

### Agents
| Agent | Role | Description |
|-------|------|-------------|
| [`agents/request-agent.md`](./agents/request-agent.md) | **Product Manager** | Facilitates requirement discussions and produces structured `request.md` specs using `sdd-request-engine`. |
| [`agents/design-agent.md`](./agents/design-agent.md) | **Architect** | Handles requirements analysis, architecture design, and interface & contract specification using `sdd-design-engine`. |
| [`agents/plan-agent.md`](./agents/plan-agent.md) | **Planner** | Converts specs into actionable tasks using `sdd-task-planner`. |
| [`agents/implement-agent.md`](./agents/implement-agent.md) | **Builder** | Executes tasks, writes code, and runs tests using `sdd-implementer` and `sdd-guardrails`. |

### Skills
| Skill | Role | Description |
|-------|------|-------------|
| [`sdd-system`](./skills/sdd-system/SKILL.md) | **Manager** | Orchestrates the project lifecycle, initialization (with optional project principles), feature management with auto-increment IDs, and global status. |
| [`sdd-request-engine`](./skills/sdd-request-engine/SKILL.md) | **PM Core** | Interactive requirement elicitation — produces structured `request.md` with user stories, acceptance criteria, and scope. |
| [`sdd-design-engine`](./skills/sdd-design-engine/SKILL.md) | **Design Core** | Transforms `request.md` into Requirements → Architecture → Object Design → Interface & Contract Design with Ambiguity Resolution Protocol. |
| [`sdd-knowledge-base`](./skills/sdd-knowledge-base/SKILL.md) | **Memory** | Central store for State, Design Patterns (tag-based), Lessons Learned (event-driven). |
| [`sdd-guardrails`](./skills/sdd-guardrails/SKILL.md) | **Safety** | Continuous validation with programmatic rule enforcement at design, plan, and implementation stages. |
| [`sdd-task-planner`](./skills/sdd-task-planner/SKILL.md) | **Planning Core** | Generates implementation plans with rule-aware `target_path` validation and pattern matching by tags. |
| [`sdd-implementer`](./skills/sdd-implementer/SKILL.md) | **Execution Core** | Scaffolds code from templates, enforces mandatory knowledge extraction on feature completion. |

## Storage Structure

All SDD artifacts are stored in the `.sdd/` directory. **Do not edit these manually** unless you know what you are doing.

```
.sdd/
├── context/              # Global Project Context & Rules
│   ├── context.json      # State: tech_stack, current_feature, stage, feature_counter, patterns, lessons
│   └── project_rules.md  # Architecture rules, coding standards, conventions (+ user-defined principles)
├── spec/                 # Feature-Scoped Specifications
│   └── <feature-id>/    # request.md, requirements.json, architecture.json, + interface specs as needed
├── plan/                 # Feature-Scoped Implementation Plans
│   └── <feature-id>/    # tasks.json (with target_path per task)
├── features/             # Archived Snapshots (spec+plan per completed feature)
├── knowledge/            # The "Learning" Layer
│   ├── patterns/         # Reusable Design/Code Patterns (tagged)
│   └── lessons/          # Avoidance Rules (event-driven)
├── data/                 # Raw Data Store
└── logs/                 # Operational Logs
```

## License

MIT
