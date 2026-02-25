<!-- Description: Load context and scaffold code for a task. -->

You MUST perform exactly ONE action: call the Task tool. Do NOT read files, do NOT do anything else first.

Call the Task tool NOW with these parameters:
- subagent_type: "general-purpose"
- description: "SDD impl start"
- prompt: Include ALL of the following in the prompt text:
  1. "Read these files first: agents/implement-agent.md, skills/sdd-implementer/SKILL.md, .sdd/context/context.json"
  2. "Follow the implement-agent.md persona and sdd-implementer SKILL.md instructions exactly."
  3. "Task ID: $ARGUMENTS"
  4. "Working directory: {cwd}"
  5. "This is the START phase — load context and scaffold code for the task."
  6. "If you detect SPEC_DRIFT, report it clearly so the user can run /sdd-spec-update."

Do NOT run in background — the subagent needs to interact with the user.
After the subagent finishes:
- If it reports SPEC_DRIFT, inform the user and suggest `/sdd-spec-update`.
- If it reports BLOCKING_CONCERNS, relay to user, collect answers, then resume the subagent using the `resume` parameter.
- Otherwise, relay results and suggest `/sdd-impl-finish` or the next task.
