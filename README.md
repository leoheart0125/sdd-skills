# SDD Skills - Compounding Engineering Framework

A next-generation Spec-Driven Development (SDD) framework designed for **Compounding Engineering**. It uses an **Agentic Orchestrator** pattern to manage the lifecycle, accumulating knowledge (patterns, templates, lessons) to make every future feature faster to build.

## Core Philosophy

1.  **Compounding**: Every feature built should make the next one faster via reusable patterns (tagged for cross-feature retrieval) and lessons learned.
2.  **Frictionless**: Automate state management. No "commit" commands. The system saves as you go.
3.  **Guardrails**: Continuous validation running *inside* every stage, not just as a final gate. Programmatic enforcement of `project_rules.md`.
4.  **Clarity First**: Ambiguity Resolution Protocol ensures the agent asks questions before proceeding on assumptions.

## Quick Start

### 1. Installation

Copy the framework components to your project's `.agent/` directory:

```bash
mkdir -p .agent/skills .agent/agents .agent/commands
cp -r ./skills/* .agent/skills/
cp -r ./agents/* .agent/agents/
cp -r ./commands/* .agent/commands/
cp AGENT.md .agent/
```

### 2. Initialization

```bash
/sdd-init
```
Sets up the `.sdd/` directory structure (including `knowledge/patterns/`, `knowledge/lessons/`, `features/`) and default configuration.

### 3. Workflow

The **Orchestrator** (`AGENT.md`) routes commands to specialized sub-agents.

**Phase 1: Design (Design Agent)**
```bash
/sdd-design
```
Analyzes your requirements with **Ambiguity Resolution** (BLOCKING/WARNING/INFO concerns), generates architecture diagrams, and defines the API spec.
*Shortcuts:* `/sdd-design-requirements`, `/sdd-design-architecture`, `/sdd-design-api`

**Phase 2: Plan (Plan Agent)**
```bash
/sdd-plan
```
Reads `project_rules.md` first, then generates an implementation plan with concrete tasks (including `target_path` per task). Validates file placement against architecture conventions.

**Phase 3: Implement (Implement Agent)**
```bash
/sdd-impl-start <TASK-ID>
```
Scaffolds code from templates (matched by tags) at the task's `target_path`.

```bash
/sdd-impl-finish
```
Marks the task as complete, triggers final verification, and **mandatorily extracts patterns and lessons** for the knowledge base.

```bash
/sdd-impl-fix
```
Request a fix if guardrails fail.

**Knowledge Commands**
```bash
/sdd-learn "lesson description"        # Record a lesson learned
/sdd-pattern-save "pattern name"       # Save a reusable pattern
/sdd-rule-update "proposed rule"       # Propose a project rule update
```

## System Components

### Orchestrator
- **`AGENT.md`**: The central brain that routes commands, manages state, and delegates to specialized agents.

### Agents
| Agent | Role | Description |
|-------|------|-------------|
| [`agents/design-agent.md`](./agents/design-agent.md) | **Architect** | Handles requirements analysis, architecture design, and API specification using `sdd-design-engine`. |
| [`agents/plan-agent.md`](./agents/plan-agent.md) | **Planner** | Converts specs into actionable tasks using `sdd-task-planner`. |
| [`agents/implement-agent.md`](./agents/implement-agent.md) | **Builder** | Executes tasks, writes code, and runs tests using `sdd-implementer` and `sdd-guardrails`. |

### Skills
| Skill | Role | Description |
|-------|------|-------------|
| [`sdd-system`](./skills/sdd-system/SKILL.md) | **Manager** | Orchestrates the project lifecycle, initialization, feature management, and global status. |
| [`sdd-design-engine`](./skills/sdd-design-engine/SKILL.md) | **Design Core** | Unifies Requirements -> Architecture -> API design with Ambiguity Resolution Protocol. |
| [`sdd-knowledge-base`](./skills/sdd-knowledge-base/SKILL.md) | **Memory** | Central store for State, Design Patterns (tag-based), Lessons Learned (event-driven). |
| [`sdd-guardrails`](./skills/sdd-guardrails/SKILL.md) | **Safety** | Continuous validation with programmatic rule enforcement at design, plan, and implementation stages. |
| [`sdd-task-planner`](./skills/sdd-task-planner/SKILL.md) | **Planning Core** | Generates implementation plans with rule-aware `target_path` validation and pattern matching by tags. |
| [`sdd-implementer`](./skills/sdd-implementer/SKILL.md) | **Execution Core** | Scaffolds code from templates, enforces mandatory knowledge extraction on feature completion. |

## Storage Structure

All SDD artifacts are stored in the `.sdd/` directory. **Do not edit these manually** unless you know what you are doing.

```
.sdd/
├── context/              # Global Project Context & Rules
│   ├── context.json      # State: tech_stack, current_feature, stage, patterns, lessons
│   └── project_rules.md  # Architecture rules, coding standards, conventions
├── spec/                 # Feature-Scoped Specifications
│   └── <feature-id>/    # requirements.json, architecture.json, openapi.yaml, concerns.json
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
