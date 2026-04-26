---
name: groom
description: Groom — handoff 残課題とアイデアバックログを横断して、次に着手するものの優先順位を提示するスキル。手を動かす前の grooming に使う
model: sonnet
user-invocable: true
---

# Groom — handoff + backlog 横断棚卸スキル

未対応の handoff 指摘・未採否の IDEA・プロセス改善候補を一画面に集め、コスト × 価値 × 3 本柱整合で再採点して、次に着手するものを 1 件推奨する。

このスキルは **判断のためのレポートを出すだけ** で、ファイル編集・archive 移動・実装着手は行わない。実行後、ユーザーが個別に `/orchestrate` `/archive-handoffs` などを起動する。

## 使い方

- `/groom` — 既定スコープ（下記）で grooming
- `/groom <focus>` — 軸を絞る。例:
  - `/groom recovery` — 3 本柱「回復力」関連だけ抽出
  - `/groom small` — 推定コスト「小」だけ抽出（隙間時間用）
  - `/groom handoff` — handoff 由来のみ
  - `/groom backlog` — IDEA / process improvement のみ

## 既定スコープ

| 種別 | 対象 | 取り込み条件 |
|---|---|---|
| handoff | `docs/agent-handoff-*.md`（archive を除く） | 未対応 / 要判断の指摘 |
| backlog | `docs/ideas-backlog.md` | 採否未決の IDEA-NN（「却下」「解決済み」セクション以外） |
| process | `docs/process-improvement-candidates.md` | 全件（未採用前提のドラフトファイル） |

`requirements.md` の REQ は **対象外**（実装確約済のため grooming 対象ではない）。

## 実行手順

### ステップ 1: 入力収集

以下を並列実行する:

1. `/audit-handoffs` を内部実行する代わりに、Bash で `ls docs/agent-handoff-*.md 2>/dev/null` を実行して列挙
2. `Grep -n "^## IDEA-" docs/ideas-backlog.md` で IDEA 見出しを取得
3. `Read` で `docs/process-improvement-candidates.md` を取得
4. `Grep -n "却下\|解決済み" docs/ideas-backlog.md` で除外セクションの行範囲を把握

handoff 本文は `Grep` で見出しと severity 行のみ抽出する（全文 Read しない）。

### ステップ 2: 各項目の再採点

各項目について以下の 3 軸で採点する:

| 軸 | スケール | 判定根拠 |
|---|---|---|
| コスト | 小 / 中 / 大 | 想定変更ファイル数・新規テスト要否・設計影響 |
| 価値 | 高 / 中 / 低 | 影響ユーザー範囲、UX 改善幅、既存欠陥の修復度合い |
| 3 本柱整合 | Recovery / Instant Replay / Predictability / なし | `ideas-backlog.md` 冒頭「長期方針」と照合 |

3 本柱整合「なし」項目は原則 **後回し** に分類する（プロダクト方針からの逸脱徴候）。例外は handoff 起源のセキュリティ / バグ系（緊急度で繰り上げ可）。

### ステップ 3: 統合優先度表の出力

```
[GROOM] 横断棚卸結果

## 入力サマリ
- handoff: N 件（うち未対応 M 件）
- ideas-backlog: K 件（採否未決のみ）
- process-improvement: L 件

## 統合優先度表

### 🔴 着手推奨（Now）
| # | 出所 | 概要 | コスト | 価値 | 3本柱 | 推奨理由 |
|---|---|---|---|---|---|---|
| 1 | handoff: HO-XXX | ... | 小 | 高 | Recovery | 影響大 / コスト小 / Recovery 強化 |

### 🟡 検討候補（Next）
| # | 出所 | 概要 | コスト | 価値 | 3本柱 | メモ |
|---|---|---|---|---|---|---|
| ... |

### 🟢 後回し / ⚪ 要判断
| # | 出所 | 概要 | コスト | 3本柱 | 後回し理由 |
|---|---|---|---|---|---|

## 推奨 1 件
**着手候補: #1 (HO-XXX / IDEA-NN)**
- 推奨理由: ...
- 想定の進め方: <consult が必要 / 直接 implementation / orchestrate 起動>
- 参照すべき資料: <関連 handoff / requirements の REQ-NN>

## 着手しないこと（明示）
- 3 本柱整合なし & コスト中以上の項目は今回スコープに入れない
- 該当: IDEA-NN, IDEA-NN

次のステップ:
- 「#1 で進める」「#X に変更」「全部スキップして別件」のいずれかで指示してください
```

## 軸を絞ったときの動作（引数あり）

| 引数 | 振る舞い |
|---|---|
| `recovery` / `instant-replay` / `predictability` | 該当 3 本柱に整合する項目だけ抽出 |
| `small` / `medium` / `large` | 推定コストで絞る |
| `handoff` / `backlog` / `process` | 出所で絞る |

絞り込みでも採点軸は変えない（出力フォーマット同一）。

## 制約

- 既存ファイル（handoff / ideas-backlog / requirements 等）を **編集しない**
- archive 移動・git commit・git push は行わない
- 実装着手・`/orchestrate` 起動は行わない（推奨の提示まで）
- 採点は handoff 本文 / IDEA 本文の記述のみで行う。コードとの照合は `/audit-handoffs` 側に委譲
- 判定に自信が持てない場合は「⚪ 要判断」に寄せ、根拠不足を明記する

## 過去の反省に基づく補足

- handoff の指摘確認とバックログ採否判断は責務が異なるため `/audit-handoffs` と分離する。`/audit-handoffs` は「漏れなく確認」、`/groom` は「次に着手するもの選定」が目的
- 3 本柱整合チェックを必ず通す。プロダクト方針から外れた項目を優先候補に挙げると、長期的にスコープが膨らむため
- 軸ごと 1 つずつ確認する原則（feedback memory: axis-by-axis spec check）に従い、出力は「Now / Next / 後回し」の 3 階層のみ。さらなる細分化はしない
