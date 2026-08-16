---
name: feedback_implementation_agent_policy
description: 実装タスクはworktree分離+BGエージェント。モデルはリスクtierで opus/sonnet を選ぶ
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 13e3531d-da14-491c-972a-cf4fbf4cf8d3
---

実装作業は必ず以下の3点セットで行う：

1. **worktree 分離** — `cc-new <branch>` でブランチを切る（[[feedback_always_worktree]]）
2. **バックグラウンド実行** — Agent tool で `run_in_background: true`（[[feedback_subagent_background]]）
3. **モデル選択** — リスク tier で決める（2026-08-16 改訂。以前は一律 opus）
   - **設計・テスト設計・レビューは tier によらず opus**（探索空間が広く、誤りが下流へ伝播し検出が遅れる）
   - **実装 tier=high → opus**: auth / session / token / crypto、非同期ライフサイクル（Timer / Stream / dispose / alarm）、
     ストリーミング経路、100行超または5ファイル超のリファクタ、過去に却下された実装
   - **実装 tier=standard → sonnet**: 上記に該当しないもの
   - lint / format などの定型作業は haiku

**Why:** high tier は「テストが緑でも静かに壊れる」領域で、赤緑のループでは誤りを検出できないため上位モデルが要る。
逆に standard tier はテストが仕様を固定できるので、opus で回すのはトークンの無駄。
tier の集合は各 repo の Codex review リスク基準と同じものを使う（判断軸を二重に持たない）。

**How to apply:** 「実装する」「変更を加える」と判断した時点で、確認なしにこの3点セットを適用する。
typo修正・docs/read-only調査は例外。tier 判定は変更対象ファイルを見て行い、迷ったら high 側に倒す。
logsite では auto-implement がこの振り分けを自動実行し、実績を `.claude-state/model-routing.jsonl` に記録する
（集計は `python3 scripts/model-routing-report.py`）。昇格閾値はその実績を見て調整する。
