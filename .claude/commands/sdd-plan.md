<!-- Description: Generate or update the implementation plan. -->

You MUST perform exactly ONE action: call the Task tool. Do NOT read files, do NOT do anything else first.

Call the Task tool NOW with these parameters:
- subagent_type: "general-purpose"
- description: "SDD plan phase"
- prompt: Include ALL of the following in the prompt text:
  1. "Read these files first: agents/plan-agent.md, skills/sdd-task-planner/SKILL.md, .sdd/context/context.json"
  2. "Follow the plan-agent.md persona and sdd-task-planner SKILL.md instructions exactly."
  3. "Read the spec directory for the current feature from context.json."
  4. "User args: $ARGUMENTS"
  5. "Working directory: {cwd}"
  6. "Use AskUserQuestion for any clarifications needed."

Do NOT run in background — the subagent needs to interact with the user.
After the subagent finishes:
- If it reports BLOCKING_CONCERNS or NEEDS_CLARIFICATION, relay to user, collect answers, then resume the subagent using the `resume` parameter.
- Otherwise, relay results and suggest `/sdd-impl-start`.
