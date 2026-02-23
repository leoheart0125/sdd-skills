<!-- Description: Force entry into Data/API Design. -->

CRITICAL: You MUST delegate this task to a subagent using the Task tool. Do NOT handle this yourself.

Instructions:
1. Read `.sdd/context/context.json` for current state
2. Read the agent prompt file at `agents/design-agent.md`
3. Read the skill spec at `skills/sdd-design-engine/SKILL.md`
4. Use the **Task tool** (subagent_type: "general-purpose") to spawn a subagent with a prompt that includes:
   - The full content of `agents/design-agent.md` as the agent's persona
   - The full content of `skills/sdd-design-engine/SKILL.md` as the skill instructions
   - Current context from `context.json`
   - **Force-start Data/API Design regardless of current sub-stage**
   - The user's arguments (below)
   - The working directory path
5. If the subagent returns BLOCKING_CONCERNS or NEEDS_CLARIFICATION, relay to the user, collect answers, and **resume** the subagent.
6. When the subagent completes, relay results and suggest the next step.

User args: $ARGUMENTS
