# /compact — Summarize session & reduce context

When context reaches 70–80%, summarize the current session to preserve working memory.

## Instructions

Create a concise summary of:

### 1. What was completed this session
List every file created or modified with a one-line description.

### 2. Current phase status
- Phase N: [name] — [% complete]
- Completed tasks from tasks.md: (list)
- Remaining tasks: (list)

### 3. Decisions made
Any architecture decisions, naming choices, or design decisions made during this session that aren't already in the docs.

### 4. Blockers / open questions
Anything that needs resolution before continuing.

### 5. Next action
The single most important thing to do next, with exact task reference from tasks.md.

---

Output this summary, then say:
"Context compacted. Continuing from: [next action]"

After compacting, re-read CLAUDE.md to restore core context.
