<!-- Description: Compare codebase against specifications. -->

Read the orchestration rules in AGENT.md. This is a lightweight command — handle directly (no subagent needed).

Follow the sdd-guardrails skill (skills/sdd-guardrails/SKILL.md) drift detection logic:
1. Parse openapi.yaml from .sdd/spec/<feature-id>/
2. Parse implemented code
3. Compare parameters, responses, schemas
4. Report drift and recommend /sdd-spec-update or implementation fix

Args: $ARGUMENTS