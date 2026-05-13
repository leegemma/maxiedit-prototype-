# .claude/hooks/

Shell scripts invoked by hooks configured in `.claude/settings.json`. All read
Claude Code's JSON payload from stdin via `node -e` (since `jq` isn't installed
on the dev machine). Each script is a small bash wrapper kept here so the
settings JSON stays readable.

| Script | Triggered by | What it does |
|---|---|---|
| [sync-on-index-edit.sh](sync-on-index-edit.sh) | `PostToolUse` on `Edit\|Write\|MultiEdit` | If the modified file is the project's `index.html`, re-run `sync:www` (rm www/, copy index.html + images/ + lib/) so the Capacitor asset mirror stays current. |
| [cache-buster-after-commit.sh](cache-buster-after-commit.sh) | `PostToolUse` on `Bash` | If the Bash command contained `git commit`, run `scripts/check-cachebuster.sh` and surface the recommended `?v=N` share URL. |
| [protect-keystore.sh](protect-keystore.sh) | `PreToolUse` on `Edit\|Write\|MultiEdit` | If the target file matches `*.keystore`, `*.jks`, or `*keystore.properties`, return a deny decision so Claude Code refuses the call before it runs. |

The 4th hook (Stop event — Windows beep) is inlined in `settings.json` as a
single `powershell` command, not a script.

## Testing a script manually

Synthesize the stdin payload and pipe it:

```bash
# sync-on-index-edit
echo '{"tool_name":"Edit","tool_input":{"file_path":"C:/Users/SAMSUNG/Projects/maxiedit-prototype/index.html"}}' | bash .claude/hooks/sync-on-index-edit.sh

# cache-buster-after-commit
echo '{"tool_name":"Bash","tool_input":{"command":"git add . && git commit -m test"}}' | bash .claude/hooks/cache-buster-after-commit.sh

# protect-keystore (should print deny JSON)
echo '{"tool_name":"Edit","tool_input":{"file_path":"android/app/maxiedit-release.keystore"}}' | bash .claude/hooks/protect-keystore.sh
```

Each script outputs JSON for Claude Code to consume (or nothing if not
applicable). Exit code is always 0 — never block via exit code, only via the
`permissionDecision` field.
