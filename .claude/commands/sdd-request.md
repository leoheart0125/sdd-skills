<!-- Description: Start a feature request conversation. Acts as a PM to discuss requirements and produce a structured spec. -->

You MUST perform exactly ONE action: call the Task tool. Do NOT read files, do NOT do anything else first.

Call the Task tool NOW with these parameters:
- subagent_type: "general-purpose"
- description: "SDD feature request"
- prompt: Include ALL of the following in the prompt text:
  1. "Read these files first: agents/request-agent.md, skills/sdd-request-engine/SKILL.md, .sdd/context/context.json, knowledge/index.json"
  2. "Follow the request-agent.md persona and sdd-request-engine SKILL.md instructions exactly."
  3. "User's feature description: $ARGUMENTS"
  4. "Working directory: {cwd}"
  5. "Use AskUserQuestion to discuss requirements with the user. Do NOT skip the discussion phase."
  6. "When done, write request.md to .sdd/spec/<feature-id>/ and report COMPLETED status."

Do NOT run in background — the subagent needs to interact with the user.
After the subagent finishes, relay its results and suggest `/sdd-design`.
