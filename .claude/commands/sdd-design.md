<!-- Description: Main entry point for SDD design. -->

You MUST perform exactly ONE action: call the Task tool. Do NOT read files, do NOT do anything else first.

Call the Task tool NOW with these parameters:
- subagent_type: "general-purpose"
- description: "SDD design phase"
- prompt: Include ALL of the following in the prompt text:
  1. "Read these files first: agents/design-agent.md, skills/sdd-design-engine/SKILL.md, .sdd/context/context.json"
  2. "Follow the design-agent.md persona and sdd-design-engine SKILL.md instructions exactly."
  3. "If no active feature in context.json, use AskUserQuestion to ask the user for a feature name."
  4. "User args: $ARGUMENTS"
  5. "Working directory: {cwd}"
  6. "Use AskUserQuestion for any clarifications needed."
  7. "If you encounter BLOCKING_CONCERNS, report them clearly so they can be relayed to the user."

Do NOT run in background — the subagent needs to interact with the user.
After the subagent finishes:
- If it reports BLOCKING_CONCERNS or NEEDS_CLARIFICATION, relay to user, collect answers, then resume the subagent using the `resume` parameter.
- Otherwise, relay results and suggest `/sdd-plan`.
