#!/usr/bin/env bash
# Auto-run sync:www when index.html is modified by Claude.
# Reads Claude Code's hook payload from stdin and checks tool_input.file_path.
# Uses `node` to parse JSON (jq isn't installed on this system).
set -u

PROJECT_ROOT="C:/Users/SAMSUNG/Projects/maxiedit-prototype"

# Extract tool_input.file_path from the JSON payload on stdin.
FILE_PATH=$(node -e "
let s='';
process.stdin.on('data',c=>s+=c).on('end',()=>{
  try { process.stdout.write(JSON.parse(s).tool_input?.file_path || ''); } catch {}
})") || exit 0

# Normalize path for case-insensitive comparison on Windows.
NORMALIZED=$(echo "$FILE_PATH" | tr '\\' '/' | tr '[:upper:]' '[:lower:]')

# Only act when the project's index.html itself was modified.
case "$NORMALIZED" in
  */maxiedit-prototype/index.html)
    cd "$PROJECT_ROOT" || exit 0
    rm -rf www && mkdir www
    cp index.html www/index.html
    cp -R images www/images 2>/dev/null || true
    cp -R lib www/lib 2>/dev/null || true
    # Surface a one-line confirmation back to Claude/the user via systemMessage.
    printf '{"systemMessage":"📦 www/ synced from index.html"}'
    ;;
esac
exit 0
