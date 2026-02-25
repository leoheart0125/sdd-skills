<!-- Description: Mark task complete and enforce knowledge extraction. -->

You MUST perform exactly ONE action: call the Task tool. Do NOT read files, do NOT do anything else first.

Call the Task tool NOW with these parameters:
- subagent_type: "general-purpose"
- description: "SDD impl finish"
- prompt: Include ALL of the following in the prompt text:
  1. "Read these files first: agents/implement-agent.md, skills/sdd-implementer/SKILL.md, .sdd/context/context.json"
  2. "Follow the implement-agent.md persona and sdd-implementer SKILL.md instructions exactly."
  3. "User args: $ARGUMENTS"
  4. "Working directory: {cwd}"
  5. "This is the FINISH phase — mark task complete and enforce knowledge extraction."
  6. "When you reach KNOWLEDGE_TRIAGE status, present the triage table to the user via AskUserQuestion and wait for confirmation before proceeding."

Do NOT run in background — the subagent needs to interact with the user.
After the subagent finishes, relay results to the user.
