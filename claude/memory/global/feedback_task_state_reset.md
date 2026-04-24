---
name: task-state.md は削除ではなく上書きで初期化
description: 前回タスク完了済みの task-state.md を新タスク開始前に空更新で初期化する。rmは不要
type: feedback
originSessionId: 52473ef7-d330-4dfa-8415-fe28bafb6727
---
orchestrate の新規タスク起動前に `.claude/task-state.md` が done 状態で残っている場合、`rm` で削除するのではなく `Write` で空ファイルに上書きして初期化する。

**Why:** `rm` はユーザーの allowlist に含まれていないことが多く、権限拒否で止まる。Write なら常に使える。orchestrate のステップ0 は task-state.md の内容（status フィールド）で分岐するので、空ファイルは「存在するが status なし → 新規タスク」として処理される。

**How to apply:** orchestrate 起動前の準備で task-state.md をリセットするとき、削除を試みず Write で空更新する。
