<!-- Description: Extract a Lesson Learned. -->

Read the orchestration rules in AGENT.md. This is a lightweight command — handle directly (no subagent needed).

Follow the sdd-knowledge-base skill (skills/sdd-knowledge-base/SKILL.md) lesson recording logic with Knowledge Triage:
1. Draft the lesson from user input
2. Dedup: Check .sdd/knowledge/index.json for ≥50% tag overlap with same semantic advice
3. Specificity: Classify as project-wide (PROMOTE), domain-specific (SAVE), or feature-specific (SKIP)
4. Present triage table to user for confirmation
5. Execute confirmed action (MERGE/PROMOTE/SAVE/SKIP)

Lesson: $ARGUMENTS