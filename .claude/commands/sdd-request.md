<!-- Description: Start a feature request conversation. Acts as a PM to discuss requirements and produce a structured spec. -->

CRITICAL: You MUST delegate this task to a subagent using the Task tool. Do NOT handle this yourself.

Instructions:
1. Read the agent prompt file at `agents/request-agent.md`
2. Read the skill spec at `skills/sdd-request/SKILL.md`
3. Use the **Task tool** (subagent_type: "general-purpose") to spawn a subagent with a prompt that includes:
   - The full content of `agents/request-agent.md` as the agent's persona
   - The full content of `skills/sdd-request/SKILL.md` as the skill instructions
   - The user's feature description (below)
   - The current working directory path
4. The subagent will interact with the user directly via AskUserQuestion. Do NOT run it in the background.
5. When the subagent completes, relay its results to the user and suggest the next step (`/sdd-design`).

User's feature description: $ARGUMENTS
