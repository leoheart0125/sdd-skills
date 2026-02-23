<!-- Description: Main entry point for SDD design. -->

CRITICAL: You MUST delegate this task to a subagent using the Task tool. Do NOT handle this yourself.

Instructions:
1. Read `.sdd/context/context.json` to get `current_feature` and `current_stage`
2. If no active feature, ask the user for a feature name first, create the feature directory
3. Read the agent prompt file at `agents/design-agent.md`
4. Read the skill spec at `skills/sdd-design-engine/SKILL.md`
5. Use the **Task tool** (subagent_type: "general-purpose") to spawn a subagent with a prompt that includes:
   - The full content of `agents/design-agent.md` as the agent's persona
   - The full content of `skills/sdd-design-engine/SKILL.md` as the skill instructions
   - Current context from `context.json`
   - The user's arguments (below)
   - The working directory path
6. If the subagent returns BLOCKING_CONCERNS or NEEDS_CLARIFICATION, relay to the user, collect answers, and **resume** the subagent (using `resume` parameter with the agent ID).
7. When the subagent completes, relay results and suggest `/sdd-plan`.

User args: $ARGUMENTS
