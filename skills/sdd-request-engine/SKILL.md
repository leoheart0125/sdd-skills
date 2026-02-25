---
name: sdd-request-engine
description: "Product Manager: Discusses requirements with the user and produces structured feature specs (user stories, acceptance criteria, scope)."
dependencies:
  - sdd-knowledge-base
  - sdd-system
---

# SDD Request Engine

This skill acts as a **Product Manager** — it facilitates an interactive conversation with the user to deeply understand the **business need** behind a feature request, then produces a structured specification document before the design phase begins. Technical decisions (architecture, performance, security, implementation constraints) are intentionally deferred to `sdd-design-engine`.

## Core Responsibilities

1.  **Requirement Elicitation**: Engage the user in a structured conversation to understand the feature's purpose, scope, and constraints.
2.  **Clarification & Scoping**: Ask targeted questions to resolve ambiguity, define boundaries (in-scope vs out-of-scope), and surface hidden assumptions.
3.  **Spec Generation**: Produce a structured `request.md` with user stories, acceptance criteria, edge cases, and constraints.
4.  **Context Awareness**: Use knowledge base to avoid repeating past mistakes and leverage existing patterns.
5.  **Feature ID Assignment**: Auto-assign the next sequential feature ID using `context.json.feature_counter`.

## Commands

-   `/sdd-request <feature description>`: Start a new feature request conversation. The description is the initial intent (e.g., `/sdd-request user authentication with social login`).

## Request Flow

### Step 1: Context Gathering (MANDATORY — Index-Based)

Before starting the conversation, gather context efficiently:
1.  Read `context.json` — get `completed_features` list (IDs only), `feature_counter`, `architecture_style`, `tech_stack`.
2.  Read `.sdd/knowledge/index.json` — filter entries whose `tags` overlap with the feature description keywords.
3.  Load ONLY the matched knowledge files (via the `file` path in each index entry). Do NOT scan full directories.
4.  Do NOT load all past `request.md` files — only load a specific one if a matched knowledge entry references it.

### Step 2: Feature ID Assignment

1.  Read `context.json.feature_counter` (e.g., `"003"`).
2.  Generate feature ID: `<counter>-<feature-name>` (e.g., `003-user-auth`).
3.  Set `context.json.current_feature` to the generated ID.
4.  Increment `feature_counter` (e.g., `"003"` → `"004"`).
5.  Create directories: `.sdd/spec/<feature-id>/` and `.sdd/plan/<feature-id>/`.
6.  Set `context.json.current_stage` to `"request"`.

### Step 3: Interactive Discussion

Engage the user in a structured PM conversation focused **exclusively on business requirements**. Do NOT ask about technology, architecture, performance, security, or implementation details — those are the design phase's responsibility.

1.  **Summarize Understanding**: Restate the user's intent in your own words to confirm alignment.
2.  **Ask Clarifying Questions**: Use targeted questions grouped by category:
    -   **Who**: Who are the users? What roles/personas are involved? Who benefits from this?
    -   **What**: What exactly should the feature do from the user's perspective? What's the expected behaviour?
    -   **Why**: What problem does this solve? What's the business value or goal?
    -   **Boundaries**: What is explicitly out of scope? What does the MVP look like vs future phases?
    -   **Success Criteria**: How do we know this feature is successful? Are there measurable outcomes?
    -   **Priority & Urgency**: Is there a deadline or business driver? What's the impact if this is delayed?
3.  **Iterate**: If answers reveal new ambiguities, ask follow-up questions. Continue until the user confirms the scope is clear.

> **IMPORTANT**: Do NOT proceed to spec generation until the user explicitly confirms the scope is clear. Present a scope summary and ask for confirmation.

### Step 4: Generate `request.md`

Once scope is confirmed, generate `.sdd/spec/<feature-id>/request.md` with the following structure:

```markdown
# Feature: <feature-name>
> Feature ID: <NNN-feature-name>

## Overview
Brief description of the feature and its purpose.

## User Stories
- As a [role], I want [action], so that [benefit].
- ...

## Acceptance Criteria
- [ ] Given [context], when [action], then [expected result].
- [ ] ...

## Edge Cases
- What happens when [unusual scenario]?
- ...

## Out of Scope
- Items explicitly excluded from this feature.

## Assumptions
- Assumptions made during discussion.

## Open Questions
- Business or scope questions remaining to resolve (technical questions will be addressed in the design phase).
```

### Step 5: User Confirmation

1.  Present the generated `request.md` to the user.
2.  If the user requests changes, apply them and record a lesson via `/sdd-learn`.
3.  Once confirmed, set `context.json.current_stage` to `"request-complete"` and report ready for `/sdd-design`.

## Post-step: Feedback Capture (MANDATORY)

After presenting the spec, if the user corrects or adjusts it:
1.  Apply the changes to `request.md`.
2.  **Immediately** write a lesson to `.sdd/knowledge/lessons/` capturing:
    -   What was originally generated vs what the user corrected.
    -   Why the correction was needed.
    -   Tags for future retrieval (feature name, `request-elicitation`, domain keywords).

## Integration

-   **Invoked by**: User (via `/sdd-request`) or Orchestrator (`sdd-request-engine`).
-   **Consumes**: `context.json`, `knowledge/index.json`.
-   **Produces**: `.sdd/spec/<feature-id>/request.md`.
-   **Triggers**: `sdd-design-engine` (as the next step after request is confirmed).
