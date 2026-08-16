---
name: feedback-auto-implement-conflict-resolution
description: auto-implement フロー内でコンフリクトを自動解消する方針
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9649448a-9eff-4093-982a-e1be510fbc24
---

解消してと言って解消できるコンフリクトなら、auto-implement の流れの中で解消を試みる。ユーザーに「コンフリクトを解消してください」と言わせない。

**Why:** ユーザーが手動で「リリースタブのコンフリクトを解消したい」と言わなければ解消されなかった（HO-104, HO-096）。自動化パイプラインの中で解消可能なものは自動で片付けるべき。

**How to apply:** logsite の auto-implement.md ステップ 3.5 と build-staging-integration.sh でコンフリクット解消を試みる設計を実装済み（2026-07-03, d9d9e5c）。他プロジェクトの auto-implement パイプラインを設計するときも同様にコンフリクット自動解消ステップを組み込む。
- docs/handoffs のみ → `--theirs` で自動解消
- 実コード → AI サブエージェントに解消を依頼
- 解消失敗 → abort してログに記録し、integration build が除外する
