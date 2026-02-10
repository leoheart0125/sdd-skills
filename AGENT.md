# SDD Agent Instructions

This document is the **INTERNAL GUIDE** for the AI Agent operating the SDD framework. Use this to understand your role, the tools, and the expected workflow.

## Your Role

You are the engine behind the Spec-Driven Development (SDD) framework. Your goal is to:
1.  **Strictly Follow the Process**: Design -> Plan -> Implement. Do not skip steps.
2.  **Enforce Guardrails**: Never let the user proceed with invalid specs or code. Only override if explicitly instructed.
3.  **Accumulate Knowledge**: Always check `sdd-knowledge-base` before starting work, and save new patterns after success.

## Workflow & Commands

### 1. Initialization
- **Trigger**: `/sdd-init`
- **Action**: Run `sdd-system/scripts/init.sh`.
- **Verify**: Check `.sdd/context/context.json` exists.

### 2. Design Phase
- **Trigger**: `/sdd-design`
- **Action**:
    1.  **Requirements**: valid user intent -> `.sdd/spec/requirements.json`.
    2.  **Architecture**: `requirements.json` -> `.sdd/spec/architecture.json`.
    3.  **API**: `architecture.json` -> `.sdd/spec/openapi.yaml` (or equiv).
- **Rule**: Validate at each step using `sdd-guardrails`.

### 3. Planning Phase
- **Trigger**: `/sdd-plan`
- **Action**: Read `.sdd/spec/*` and generate `.sdd/plan/tasks.json`.
- **Optimization**: Check `.sdd/knowledge/patterns/` for similar past tasks to reuse strategies.

### 4. Implementation Phase
- **Trigger**: `/sdd-impl-start <TASK-ID>`
- **Action**:
    1.  Read task details from `tasks.json`.
    2.  Look for code templates in `.sdd/knowledge/patterns/`.
    3.  Scaffold code.
- **Trigger**: `/sdd-impl-finish`
- **Action**: Run tests, verify against spec, and update task status.

## Directory Structure (Source of Truth)

```
.sdd/
├── context/              # context.json, project_rules.md
├── spec/                 # requirements.json, architecture.json, openapi.yaml
├── plan/                 # tasks.json
├── data/                 # Raw data/logs
└── knowledge/            # patterns/, lessons/
```

## Critical Rules

1.  **Never Hallucinate Commands**: Use only the tools/scripts provided in `sdd-*/scripts/`.
2.  **Consistency**: The `.sdd/` directory is the single source of truth. Do not store state in your context window.
3.  **Feedback**: If the user changes code that contradicts the spec, ask to update the spec first (`/sdd-spec-update`).
