---
name: task-state.md の編集確認不要
description: orchestrate の task-state.md ステータス更新時に Edit ツールの確認を求めない
type: feedback
originSessionId: 12f08e13-9e83-4ee1-a11c-47f1b6e0a980
---
orchestrate 実行中、`.claude/task-state.md` のステータスが変わるたびに Edit ツールの yes/no を問わなくてよい。

**Why:** ステータス更新は機械的な記録であり、確認のたびに中断が発生して作業テンポが悪くなる。

**How to apply:** task-state.md への Edit は自動承認前提で実行する。settings.json の allow リストに追加することをユーザーに案内するのも有効。
