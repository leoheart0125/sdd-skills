<!-- Description: Re-sort tasks based on dependencies. -->

CRITICAL: You MUST delegate this task to a subagent using the Task tool. Do NOT handle this yourself.

Instructions:
1. Read `.sdd/context/context.json` for current state
2. Read the agent prompt file at `agents/plan-agent.md`
3. Read the skill spec at `skills/sdd-task-planner/SKILL.md`
4. Use the **Task tool** (subagent_type: "general-purpose") to spawn a subagent with a prompt that includes:
   - The full content of `agents/plan-agent.md` as the agent's persona
   - The full content of `skills/sdd-task-planner/SKILL.md` as the skill instructions
   - Current context from `context.json`
   - **Optimize the existing task order, do NOT regenerate tasks**
   - The user's arguments (below)
   - The working directory path
5. When the subagent completes, relay the optimized plan to the user.

User args: $ARGUMENTS
