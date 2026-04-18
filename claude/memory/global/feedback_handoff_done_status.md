---
name: handoff_status ステータス体系と archive 条件
description: done は前担当者が作業終了の意。archive_waiting がアーカイブ可の唯一の条件。/archive-handoffs は archive_waiting のみを対象にする
type: feedback
originSessionId: cec621c9-b1aa-4eaa-a369-59724d1d958d
---
## ステータス体系

- `active` — 作業中
- `waiting` — 作業完了、レビュアー待ち
- `blocked` — ブロック中
- `done` — レビュアーが確認済みだが、まだアーカイブ可否を判断していない状態
- `archive_waiting` — レビュアー（Human または Codex）が「アーカイブ可」と明示した状態
- `archived` — `docs/archive/` へ物理移動済み

## archive できる条件

`handoff_status: archive_waiting` のみ。`done` はアーカイブ不可。

**Why:** `done` は「前の担当者（Codex や Claude Code）が自分のタスクを終えた」という意味で書かれることがあり、「Human が内容を確認してアーカイブ可」とは別の意味。done を見てそのまま archive すると誤アーカイブになる（たびたび問題発生）。

**How to apply:**
- Claude Code が実装・修正を終えたら → `handoff_status: waiting` + `Next Owner: Human or Codex`
- Human/Codex が「アーカイブ可」と判断したら → `handoff_status: archive_waiting` に更新
- `/archive-handoffs` は `archive_waiting` のハンドオフのみを対象にする
- `done` だけを根拠に「archive できます」と提案しない
