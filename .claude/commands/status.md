---
description: Snapshot — git status, recent commits, and Play Store release progress
allowed-tools: Bash, Read
---

Give me a concise project snapshot. Project root:
`/c/Users/SAMSUNG/Projects/maxiedit-prototype`.

Run in parallel where possible:

1. **`git status --short`** — working tree state (gitignored stuff like
   `android/.idea/` always shows up; that's normal).

2. **`git log --oneline -5`** — last 5 commits.

3. **Cache-buster** — `bash scripts/check-cachebuster.sh` so the user knows
   which `?v=N` to share next time.

4. **Release progress** — read the auto-memory file
   `C:/Users/SAMSUNG/.claude/projects/C--Users-SAMSUNG/memory/maxiedit_release_progress.md`
   and summarize:
   - What's completed (1-line per item)
   - What's the immediate next step
   - Estimated time to first Play Store production rollout

Format the output as a single concise table or three short sections —
working tree, recent activity, next action. Total response under 200 lines.
