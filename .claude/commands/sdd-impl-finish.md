<!-- Description: Mark task complete and enforce knowledge extraction. -->

CRITICAL: You MUST delegate this task to a subagent using the Task tool. Do NOT handle this yourself.

Instructions:
1. Read `.sdd/context/context.json` for current state
2. Read the agent prompt file at `agents/implement-agent.md`
3. Read the skill spec at `skills/sdd-implementer/SKILL.md`
4. Use the **Task tool** (subagent_type: "general-purpose") to spawn a subagent with a prompt that includes:
   - The full content of `agents/implement-agent.md` as the agent's persona
   - The full content of `skills/sdd-implementer/SKILL.md` as the skill instructions
   - Current context from `context.json`
   - The user's arguments (below)
   - The working directory path
5. IMPORTANT: When the subagent returns with STATUS: KNOWLEDGE_TRIAGE, present the triage table to the user and wait for confirmation before **resuming** the subagent with the confirmed actions.
6. When the subagent completes, relay results to the user.

User args: $ARGUMENTS
