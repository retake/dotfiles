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

## 2-stage 運用の例外（Human が指示した場合）

Human が「実装はアーカイブで」「accept で archive 可」と明示した場合、以下の例外運用が許される：

- **実装系 handoff**: Claude Code が「実装完了 + テスト緑 + 関連 docs 更新」を確認していれば、Human の archive 指示を Codex/Human accept とみなして `done` → `archive_waiting` に bump → archive
- **design-consult 系 handoff**: Codex の同意（`## Codex Response` セクション付き）または Claude+Codex 一致の「no change」推奨があれば、Human の accept 指示で `done` → `archive_waiting` に bump → archive

**Why:** 2026-04-29 HO-128 family の clean-up で、9 件の handoff を archive する際に Human が「実装はアーカイブで。ほかは判断します」と区別して指示した。この運用では実装系と design-consult 系を分けて扱い、それぞれの担当工程完了基準（テスト緑 / Codex 同意）を Human accept の前提条件にできる。

**How to apply:**
- Claude Code 単独で `done` → `archive_waiting` に bump しない
- Human の archive 指示があったときのみ、上記 2 種類の前提条件（テスト緑 / Codex 同意）を満たした handoff だけを bump 対象にする
- 前提条件を満たさない handoff（テスト未実行・Codex 未確認）は `done` のまま残す
