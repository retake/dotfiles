---
name: logsite-release-autonomy
description: logsite の HO 実装フローは main マージ・git push・staging build まで承認なしで自走してよい
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 16e2bbc3-883e-46cc-886b-802b2a09c99a
---

2026-07-14、HO-293 リリース時にユーザーが「承認します。承認なしでよいです」と回答し、以後の同種フローの自走を許可した。

**Why:** HO 単位の実装 → 検証 → main マージ → push → `scripts/build-staging-integration.sh` は logsite の確立された定型フローであり、毎回の承認待ちは自律開発サイクルを止めるだけだった。

**How to apply:** logsite リポジトリで HO 実装が検証 green（テスト・lint・validator）になったら、確認を挟まず main マージ → `env -u GITHUB_TOKEN -u GH_TOKEN git push` → staging build → worktree/ブランチ後片付け → 結果報告まで一気に進める。ただし prod 昇格（本体 Worker の prod deploy）・破壊的操作・大量削除は従来どおり確認する。関連: [[feedback_implementation_agent_policy]]（実装は worktree+BG+opus）
