---
description: Commit pending changes with a message, push to origin, share the cache-busted URL
argument-hint: "<commit message>"
allowed-tools: Bash
---

Commit and push pending changes, then share the cache-busted GitHub Pages URL.
Project root: `/c/Users/SAMSUNG/Projects/maxiedit-prototype`.

**Commit message provided by the user:** `$ARGUMENTS`

Steps:

1. **Check working tree** — `git status --short`. If clean, report "no changes
   to commit" and stop.

2. **Stage relevant files** — Use `git add` on specific files only. Include any
   of these that have changes: `index.html`, `CLAUDE.md`, `HISTORY.md`,
   `TODO.md`, `docs/`, `patches/`, `images/`, `lib/`, `package.json`,
   `capacitor.config.json`, `android/app/build.gradle`,
   `android/keystore.properties.example`, `android/variables.gradle`,
   `.claude/`, `scripts/`, `ios/App/App/Info.plist`, `ios/App/Podfile`.
   **Never stage `www/`** (gitignored anyway). **Never stage `*.keystore` or
   `keystore.properties`** (the protect-keystore hook blocks this, plus
   gitignore covers it — belt and suspenders).

3. **Update HISTORY.md** — If the change is substantive (not a typo fix), make
   sure there's a new top entry in `HISTORY.md` summarizing what changed and
   why. Use the existing format (date, "(this commit)", then a Korean summary).
   If a new entry is needed, write it and re-stage `HISTORY.md`.

4. **Commit** — Use a HEREDOC with the standard Claude co-author footer:
   ```
   git commit -m "$(cat <<'EOF'
   $ARGUMENTS

   Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
   EOF
   )"
   ```

5. **Push** — `git push origin main`

6. **Cache-buster** — `bash scripts/check-cachebuster.sh`

7. **Report** — Print the commit hash, file count, and the shareable URL:
   `https://leegemma.github.io/maxiedit-prototype/?v=N` (substitute N from
   step 6 output).

If push fails (e.g., needs pull first), surface the error and stop —
don't auto-resolve.
