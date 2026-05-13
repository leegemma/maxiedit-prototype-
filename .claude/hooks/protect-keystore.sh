#!/usr/bin/env bash
# Block Edit/Write/MultiEdit against keystore-related files.
# PreToolUse hook: emit a deny decision so Claude Code refuses the call
# before the tool runs.
set -u

FILE_PATH=$(node -e "
let s='';
process.stdin.on('data',c=>s+=c).on('end',()=>{
  try { process.stdout.write(JSON.parse(s).tool_input?.file_path || ''); } catch {}
})") || exit 0

FILE_LC=$(echo "$FILE_PATH" | tr '\\' '/' | tr '[:upper:]' '[:lower:]')

case "$FILE_LC" in
  *.keystore|*.jks|*keystore.properties)
    cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"🔒 Keystore/credentials files are protected. These control app signing and must never be edited via automated tools — manual edit only. If you truly need to change them, do it directly in your editor."}}
EOF
    ;;
esac
exit 0
