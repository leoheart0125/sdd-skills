<!-- Description: Reset internal state but keep learned knowledge. -->

Read the orchestration rules in AGENT.md. This is a lightweight command — handle directly (no subagent needed).

Follow the sdd-system skill (skills/sdd-system/SKILL.md) nuke logic:
- Reset context.json (keep knowledge references)
- Clear spec/ and plan/ directories
- Preserve knowledge/ directory (patterns and lessons)
- Confirm with user before proceeding (DESTRUCTIVE)

Reason: $ARGUMENTS