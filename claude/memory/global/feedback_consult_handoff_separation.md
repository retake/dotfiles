---
name: design-consult と implementation handoff の分離
description: design-consult 型の handoff に実装指示を混ぜない。consult は Next Owner: Human で閉じ、実装は別 handoff に分離する
type: feedback
originSessionId: 1113e913-cf15-4324-adc5-be33ebba3402
---
`design-consult` 型 handoff は「相談の記録」だけを持つ。

**Why:** Codex から繰り返し同じ指摘を受けている（HO-028, HO-029 等）。consult 完了後に「Next Action: Claude Code が〇〇を編集する」を書き込むと、「相談の記録」と「実装指示」が混在してハンドオフの型が崩れる。

**How to apply:**
- consult が終わったら `Next Owner: Human`・`handoff_status: done` で閉じる
- 実装が必要なら、別途 `Type: implementation` の handoff を新規作成して Claude Code に渡す
- consult 内の `Next Action` に Claude Code への編集・実装指示を書かない
