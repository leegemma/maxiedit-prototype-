#!/usr/bin/env bash
# After any Bash command that contained `git commit`, run check-cachebuster.sh
# and surface the recommended ?v=N for sharing.
# PostToolUse runs after success only — PostToolUseFailure is a different event.
set -u

PROJECT_ROOT="C:/Users/SAMSUNG/Projects/maxiedit-prototype"

# Pull tool_input.command from stdin.
CMD=$(node -e "
let s='';
process.stdin.on('data',c=>s+=c).on('end',()=>{
  try { process.stdout.write(JSON.parse(s).tool_input?.command || ''); } catch {}
})") || exit 0

# Only act when `git commit` is part of the command. This catches both
# standalone commits and compound chains like `git add … && git commit …`.
case "$CMD" in
  *"git commit"*)
    cd "$PROJECT_ROOT" || exit 0
    OUTPUT=$(bash scripts/check-cachebuster.sh 2>&1) || exit 0
    V=$(echo "$OUTPUT" | grep -oE '\?v=[0-9]+' | head -1)
    if [ -n "$V" ]; then
      printf '{"systemMessage":"🔗 Share: https://leegemma.github.io/maxiedit-prototype/%s"}' "$V"
    fi
    ;;
esac
exit 0
