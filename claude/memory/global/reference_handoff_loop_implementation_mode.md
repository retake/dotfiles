---
name: handoff-loop-implementation-mode-auto-codes
description: claude-codex-handoff-loop.shのimplementationモードはCodexターン後に自動でClaude Codeターン（実コード実装）まで進む
metadata: 
  node_type: memory
  type: reference
  originSessionId: fe259231-39a3-4167-8f72-a371987b84a5
---

`claude-codex-handoff-loop.sh --max-rounds N` の `loop_mode: implementation`（HO の `## Type` が implementation/review/bug-triage/audit/security-audit の場合）は、Codex が設計方針を返した後、**同一 loop 内で自動的に Claude Code ターンへ進み、実際のコード実装（D1 migration・API・UI等）まで行う**。

**Why 重要か**: HO-235（2026-07-11）で「Codex 相談だけのつもりで handoff-loop を1ラウンド回す」つもりが、Codex 提案 → Claude Code が実装（migration 含む）まで自動で進んだ。HO 自身が `auto_implementable: false`（Human 判断が必要と明記）であっても、handoff-loop 経由だと `auto-implement` cron の deny-by-default ゲートを **バイパス** する。design-consult のつもりで `Type: implementation` の HO に対して handoff-loop を回すと、意図せず実装まで進む。

**How to apply**: 「design consult だけ実行してほしい」という意図で handoff-loop を回すときは、対象 HO の `## Type` を確認する。`design-consult` なら Codex ターンで止まる。`implementation` 等だと Claude Code ターンまで自動で走るので、実装内容を事前に想定しておくか、`--max-rounds` を1に絞った上で結果を都度確認する。実装が走った場合は diff をレビューしてから Codex review へ戻す。関連: [[reference_codex_turn_drain_cron]]
