# orchestrate.md 分割提案

**対象**: `claude/skills/orchestrate/SKILL.md`（866 行）
**ステータス**: 提案のみ。実装は未着手（破壊的変更のリスクが高いため、実際に動かして検証する必要あり）
**起票元**: 2026-04-24 包括レビューで「巨大化スキルの分割余地」として挙がった項目

## 現状の章構成

| 行 | 章 | 行数 |
|---|---|---|
| 26–50 | サブエージェント呼び出し方式・教訓読み込み | 25 |
| 52–92 | ステップ0 / 0.5 / 0.7（状態確認・同期） | 40 |
| 93–261 | **FR-1 入力受付・解釈** | 168 |
| 262–286 | FR-2 技術選定 | 24 |
| 287–395 | FR-3 設計 | 108 |
| 396–420 | task-state.md 管理 | 24 |
| 421–533 | FR-4 実装 | 112 |
| 534–590 | FR-5/6 テスト・lint（並列） | 56 |
| 591–740 | FR-7/8 レビュー・成果物 | 149 |
| 741–818 | **FR-9 確認停止共通** | 77 |
| 819–860 | FR-10 完了記録・通知 | 41 |

## 分割候補（効果 × リスク）

| 候補 | 切り出し先 | 効果 | リスク |
|---|---|---|---|
| A. task-state.md 管理 | `docs/task-state-spec.md` | orchestrate から参照。他スキル（closing 等）からも共通参照可能 | 低（独立した仕様書化） |
| B. FR-9 確認停止共通手順 | `claude/skills/orchestrate/confirmation-gate.md` | 確認停止ロジックの再利用性向上 | 中（SKILL.md 形式では呼べないので、単なる include 的な参照になる） |
| C. FR-1 入力受付 | 別 skill `orchestrate-input` | 最大ブロックを独立化 | 高（状態受け渡し・エントリポイントが複雑になる） |
| D. FR-3/4/5-6/7-8 の各フェーズ | フェーズ別 skill | 各フェーズを単独 skill 化して orchestrate は dispatcher に専念 | 高（orchestrate の動作を大きく変える、task-state 経由の state machine が必要） |

## 推奨プラン

**Phase 1 (安全)**: A のみ実施。`docs/task-state-spec.md` に切り出し、orchestrate の該当節は「詳細は docs/task-state-spec.md 参照」の 1 行に圧縮。closing skill も同じ spec を参照できるようになる。

**Phase 2 (中規模)**: B を include 形式で実施。orchestrate の冒頭で「確認停止の手順は `confirmation-gate.md` を読んで従う」と指示し、本文からは具体的手順を削除。

**Phase 3 (要検証)**: C, D は実際の orchestrate 実行を 2–3 回通し、どのフェーズが独立しても支障がないか確認してから着手。

## 着手前の確認事項

- orchestrate を Agent ツール経由で呼び出しているのは現在 Claude Code 自身のみか
- task-state.md の書式が他の skill（closing / retro / sync）で decode できているか
- 分割後のファイルも `~/.claude/skills/orchestrate/` 配下に置くべきか、`claude/docs/` に出すか

Phase 1 だけなら 30 分程度で可能。Phase 2 以降は 1 セッション丸ごと必要。
