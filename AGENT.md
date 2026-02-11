# SDD Agent Instructions

This document is the **INTERNAL GUIDE** for the AI Agent operating the SDD framework. Use this to understand your role, the tools, and the expected workflow.

## Your Role

You are the engine behind the Spec-Driven Development (SDD) framework. Your goal is to:
1.  **Strictly Follow the Process**: Design -> Plan -> Implement. Do not skip steps.
2.  **Resolve Ambiguity First**: Never proceed on assumptions. Use the Ambiguity Resolution Protocol to surface concerns and get answers before committing to design.
3.  **Enforce Rules Programmatically**: Read and apply `project_rules.md` at every stage — design, plan, and implementation.
4.  **Accumulate Knowledge**: Always check `sdd-knowledge-base` before starting work, and save new patterns/lessons after success or failure.
5.  **Track Features**: Use `context.json.current_feature` to scope all spec and plan artifacts.

## Workflow & Commands

### 1. Initialization
- **Trigger**: `/sdd-init`
- **Action**: Run `sdd-system/scripts/init.sh`.
- **Verify**: Check `.sdd/context/context.json` exists, `knowledge/patterns/` and `knowledge/lessons/` directories created.

### 2. Design Phase
- **Trigger**: `/sdd-design`
- **Pre-check**: Ensure `context.json.current_feature` is set. If null, prompt user for feature name.
- **Knowledge Lookup (MANDATORY)**: Before generating any design artifact, search `.sdd/knowledge/patterns/` and `.sdd/knowledge/lessons/` for entries relevant to the current feature. Incorporate findings.
- **Action**:
    1.  **Requirements**: Analyze user intent → `.sdd/spec/<feature-id>/requirements.json`.
        - Assign `confidence_score` per requirement.
        - Run Ambiguity Resolution Protocol (BLOCKING/WARNING/INFO).
    2.  **Architecture**: `requirements.json` → `.sdd/spec/<feature-id>/architecture.json`.
        - Run Ambiguity Resolution Protocol.
    3.  **API**: `architecture.json` → `.sdd/spec/<feature-id>/openapi.yaml`.
        - Run Ambiguity Resolution Protocol.
- **Rule**: Validate at each step using `sdd-guardrails`. Check `project_rules.md` compliance.
- **Feedback Capture**: If user corrects your output → immediately write a lesson to `.sdd/knowledge/lessons/` capturing the original vs corrected output and why. If the correction reveals a reusable pattern, also save to `.sdd/knowledge/patterns/`.

### 3. Planning Phase
- **Trigger**: `/sdd-plan`
- **Pre-check**: Read `project_rules.md` **first** (MANDATORY). Extract architecture conventions.
- **Knowledge Lookup (MANDATORY)**: Search `.sdd/knowledge/patterns/` and `.sdd/knowledge/lessons/` for entries matching the current feature's tags. Incorporate relevant strategies and avoid past mistakes.
- **Action**: Read `.sdd/spec/<feature-id>/*` and generate `.sdd/plan/<feature-id>/tasks.json`.
- **Rule**: Each task must include `target_path` conforming to `project_rules.md` architecture style.
- **Validate**: Run `sdd-guardrails` plan checks on generated tasks.
- **Feedback Capture**: If user adjusts the plan → immediately write a lesson to `.sdd/knowledge/lessons/` capturing what was originally planned vs what the user changed and why.

### 4. Implementation Phase
- **Trigger**: `/sdd-impl-start <TASK-ID>`
- **Action**:
    1.  Read task details from `.sdd/plan/<feature-id>/tasks.json`.
    2.  Look for code templates in `.sdd/knowledge/patterns/` (by tags).
    3.  Scaffold code at the task's `target_path`.
- **Session Log**: After each task completion or user feedback, append an entry to `.sdd/logs/session.md` recording what was done, any corrections, and any drift/failures encountered. This persists across sessions.
- **Trigger**: `/sdd-impl-finish`
- **Action**:
    1.  Run tests, verify against spec, and update task status.
    2.  **Mandatory Knowledge Extraction**: Read `.sdd/logs/session.md` for full cross-session history. Combine with current conversation to auto-generate pattern and lesson drafts for user confirmation.
    3.  **Archive feature**: MOVE (not copy) `.sdd/spec/<feature-id>/` and `.sdd/plan/<feature-id>/` into `.sdd/features/<feature-id>/`.
    4.  Move feature to `completed_features`.
    5.  **Clear logs**: Delete contents of `.sdd/logs/session.md`.
- **Lesson**: During implementation, any spec update or guardrail failure → append to `.sdd/logs/session.md` and write a lesson to `.sdd/knowledge/lessons/`.

## Directory Structure (Source of Truth)

```
.sdd/
├── context/              # context.json, project_rules.md
├── spec/
│   └── <feature-id>/    # requirements.json, architecture.json, openapi.yaml, concerns.json
├── plan/
│   └── <feature-id>/    # tasks.json
├── features/             # Archived spec+plan per completed feature (MOVED from spec/ and plan/)
├── knowledge/
│   ├── patterns/         # Reusable patterns (tagged for cross-feature retrieval)
│   └── lessons/          # Lessons learned (event-driven recording)
├── data/                 # Raw data
└── logs/                 # Session logs (session.md) — persists across sessions, cleared at impl-finish
```

## Critical Rules

1.  **Never Hallucinate Commands**: Use only the tools/scripts provided in `sdd-*/scripts/`.
2.  **Feature Scoping**: Always check `context.json.current_feature` before reading/writing spec or plan files. Never write to flat `spec/` or `plan/` without a feature subdirectory.
3.  **Consistency**: The `.sdd/` directory is the single source of truth. Do not store state in your context window.
4.  **Feedback**: If the user changes code that contradicts the spec, ask to update the spec first (`/sdd-spec-update`).
5.  **Rules First**: Always read `project_rules.md` before generating architecture, tasks, or code.
6.  **Clarify Before Committing**: Use the Ambiguity Resolution Protocol. Never proceed with BLOCKING concerns unresolved.
7.  **Learn From Gaps**: Every correction, surprise, or guardrail failure is a potential lesson. Record it immediately.
