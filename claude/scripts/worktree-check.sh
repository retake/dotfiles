#!/usr/bin/env bash
# SessionStart hook: git worktree の状態を表示し、本体ツリーで並行 worktree がある場合は警告する。

cwd="$(pwd)"
if ! git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

list="$(git -C "$cwd" worktree list 2>/dev/null)"
[ -z "$list" ] && exit 0

count="$(printf '%s\n' "$list" | wc -l | tr -d ' ')"
main_wt="$(printf '%s\n' "$list" | head -n1 | awk '{print $1}')"
toplevel="$(git -C "$cwd" rev-parse --show-toplevel)"

msg="git worktree:"$'\n'"$list"
if [ "$count" -ge 2 ] && [ "$toplevel" = "$main_wt" ]; then
  msg="$msg"$'\n\n'"[警告] 並行 worktree が存在します。他セッションと干渉する恐れがあるため、新規作業は cc-new <branch> で分離を検討してください。"
fi

python3 -c '
import json, sys
msg = sys.stdin.read()
print(json.dumps({
    "systemMessage": msg,
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": msg,
    },
}))
' <<<"$msg"
