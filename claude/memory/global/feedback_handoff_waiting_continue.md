---
name: handoff waiting 中も次タスクを継続する
description: handoff_status が waiting になっても作業を止めない。次の推奨タスクを特定して実装を続ける
type: feedback
originSessionId: 0a80e74d-ba69-404a-bfcd-7336e9d6d557
---
handoff が `handoff_status: waiting` になったとき、Human/Codex レビュー待ちという理由で作業を止めない。次の有望なタスクを自律的に判断して継続する。

**Why:** レビュー待ちを「停止命令」と解釈していたが、ユーザーは「並行して次へ進む」を期待している。

**How to apply:** handoff を `waiting` に更新した直後、停止せずに次の task-state.md / traceability.md / backlog を参照して次タスクを選定し、推奨が明確なら確認なしで実装を開始する。選択肢が拮抗する場合のみ選択肢テーブル + 推奨を提示して即決を求める。
