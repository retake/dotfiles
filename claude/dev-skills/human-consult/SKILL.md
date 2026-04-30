---
name: human-consult
description: Human 判断が必要な handoff / IDEA をヒアリングし回答を書き戻すスキル。task-state bucket を primary input に使う fast path と、handoff/backlog 直接スキャンの full scan を切り替えられる。
model: sonnet
user-invocable: true
---

# Human Consult — Human 判断ヒアリングスキル

**いつでも実行できる。** 自律セッションが動いていても、止まっていても、まだ始まっていなくても構わない。

デフォルトは **fast path**: `.claude-state/task-state.md` の `Human-judgment Bucket` を primary source として読み、compact な質問表を出力する。bucket が無い / 空 / 全件回答済みの場合は handoff / backlog を直接スキャンする **full scan** へ自動 fallback する。

## 使い方

- `/human-consult` — fast path 優先で開始（bucket → fallback full scan）
- `/human-consult <handoff-path>` — 特定ファイルだけを対象にする（full scan のサブセット）
- `/human-consult --full` または `/human-consult --full-scan` — 常に full scan モードで開始

## 詳細出力コマンド（回答中に使用可）

- `詳しく N` / `details N` — 項目 N だけフルコンテキストで表示
- `full` / `--full` — 全件フルコンテキスト出力に切り替え

---

## 実行手順

### ステップ 0: モード判定

| 引数 | モード |
|---|---|
| なし | fast path 優先（ステップ 1-A へ） |
| `--full` / `--full-scan` | full scan モード（ステップ 1-C へ） |
| `<handoff-path>` | 特定ファイル限定（ステップ 1-C のサブセット） |

---

### ステップ 1-A: task-state bucket チェック（fast path 判定）

```bash
grep -A 80 "### Human-judgment Bucket" .claude-state/task-state.md 2>/dev/null
```

以下のいずれかなら **ステップ 1-C（full scan fallback）へ**:

- `.claude-state/task-state.md` が存在しない
- `### Human-judgment Bucket` セクションが無い
- セクションが空（行がない / 「なし」）
- テーブルの全行で `suggested Human action` 欄が `[回答済み` で始まる（全件回答済み）

未回答行が 1 件以上あれば **ステップ 2-A（fast path）へ**。

---

### ステップ 1-C: full scan 候補収集（full scan モード・fallback）

以下を **同時に** 実行する:

```bash
# A: handoff 候補を一括取得
# Note: `## Next Owner` + 改行 + `Human` の heading 形式も検出する
grep -rl "Next Owner" docs/agent-handoff-*.md 2>/dev/null | \
  xargs grep -l "Next Owner: Human\|^Human$" 2>/dev/null
grep -l "handoff_status: blocked" docs/agent-handoff-*.md 2>/dev/null

# B: ideas-backlog から requires-human を一括抽出
grep -n "採否フィルター: \`requires-human\`\|### IDEA-" docs/ideas-backlog.md 2>/dev/null

# C: task-state.md の Human-judgment Bucket（補足参照のみ）
grep -A 80 "### Human-judgment Bucket" .claude-state/task-state.md 2>/dev/null
```

候補が 0 件の場合:

```
[HUMAN CONSULT] Human 判断待ちの項目は現在ありません。
```

を出力して終了する。

**ステップ 2-C へ。**

---

### ステップ 2-A: fast path — bucket 項目の情報取得

bucket テーブルの各行から item ID（HO-NNN / IDEA-NNN）と質問概要を抽出する。

各 item について、対応する handoff / IDEA を特定して **最小限の情報** だけ取得する（Read ではなく grep で必要フィールドだけ）:

```bash
# handoff の場合
grep -A 3 "^## task_id\|^## handoff_status\|^## priority\|^## Next Owner\|^## Next Action\|^## Decisions" <handoff-path> 2>/dev/null

# IDEA の場合（行番号から前後 20 行）
grep -n "### IDEA-<NNN>" docs/ideas-backlog.md | head -1
# → 行番号を取得して前後 20 行を抽出
sed -n '<start>,<end>p' docs/ideas-backlog.md
```

**skip 条件（bucket 由来でも聞かない項目）**:

- `handoff_status: done` / `archive_waiting` / `archived` / `blocked`
- `## Decisions` に Human 回答が既に記録されている（`decision (` を含む行または `承認日:` 等）
- IDEA ブロック内に以下のいずれかがある:
  - `decision (` を含む Human 決定行
  - `consult-attempted: ... → Concrete`
  - `implemented-by:` または `resolved-by:`
  - `採否フィルター: auto-rejectable`

skip した項目は集計してステップ 5 の出力末尾に列記する。全件 skip なら **ステップ 1-C（full scan fallback）** を試みる。

**ステップ 3-A（compact 出力）へ。**

---

### ステップ 2-C: full scan — 各 item の必要セクション抽出

候補ファイルごとに **全ファイル同時に** 以下を実行する:

```bash
grep -A 20 "^## Goal\|^## Type\|^## Next Action\|^## Axes\|^## Open Questions\|^## Constraints\|^## Acceptance Criteria\|^## Decisions\|^## Reason for Human\|^## handoff_status\|^## priority\|^## Next Owner" <ファイルパス> 2>/dev/null
```

ideas-backlog の各 IDEA は B で取得済みの行番号から前後 40 行を抽出する:

```bash
sed -n '<start>,<end>p' docs/ideas-backlog.md
```

抽出結果から以下の情報をまとめる（項目ごと）:
- **task_id / IDEA 番号**
- **handoff_status** と **Next Owner**（`## Next Owner` heading の次の非空行も確認）
- **Goal**: 1–2 行（対象画面・機能の特定に使う）
- **Type**: implementation / design-consult / docs-sync など
- **Next Action**: Human に求める具体的アクション全文
- **Axes / Open Questions**: 選択肢候補（あれば全文）
- **Reason for Human escalation / requires-human 理由**
- **Constraints**: 選択を制約する条件
- **Acceptance Criteria**: 何が達成されれば完了か
- **Decisions**: 既に記録されている判断（skip 条件チェックに使う）

**skip 条件（full scan でも聞かない項目）**:

- 依存先 handoff が `active` で進行中（依存先の結論が出ていないため答えようがない）
- `handoff_status: done` / `archive_waiting` / `archived`
- `採否フィルター` に `auto-rejectable` または `実装済み` マーク
- `## Decisions` に Human の回答が既に記録されている
- IDEA ブロック内に以下のいずれかがある:
  - `decision (` を含む Human 決定行
  - `consult-attempted: ... → Concrete`
  - `implemented-by:` または `resolved-by:`

**ステップ 3-C（フルコンテキスト出力）へ。**

---

### ステップ 3-A: compact 出力（fast path）

#### 質問タイプの判定

| 状況 | 質問タイプ |
|---|---|
| `## Next Action` に「go 指示待ち」「開始判断待ち」等の記述 | **go / no-go** |
| `## Next Action` に「実機確認待ち」「検証待ち」 | **完了確認** |
| `## Axes` または `## Open Questions` に未決の選択肢がある | **選択** |
| `## Recommendation` が存在し Human の承認が必要 | **承認** |
| IDEA で方針未決 / 「Human が方向を決める」 | **採否判断** |

```
[HUMAN CONSULT] N件、今すぐ答えられます

番号付きで回答してください（例: 「1. go 2. 採用 3. スキップ」）。
「スキップ」と書いた項目は次回に持ち越します。
「詳しく N」で任意の項目の詳細を表示、「full」で全件フルコンテキストに切り替えます。

| # | item | 質問タイプ | 質問 | 選択肢 | 根拠 |
|---|---|---|---|---|---|
| 1 | HO-XXX: <タイトル> | go/no-go | 着手しますか？ | go / no-go | `## Next Action` に「go 指示待ち」 |
| 2 | IDEA-NNN: <タイトル> | 採否判断 | 採用しますか？ | 採用 / 不採用 / 保留 | requires-human: <一行理由> |
```

ユーザーの回答を待つ。

- `詳しく N` / `details N` を受け取った場合 → 該当 item を **ステップ 3-C のフルコンテキスト形式** で追加出力してから引き続き待つ。
- `full` / `--full` を受け取った場合 → 全件をフルコンテキスト形式（ステップ 3-C 形式）で再出力してから待つ。

---

### ステップ 3-C: フルコンテキスト出力（full scan / 詳細要求）

各 item を以下の形式で出力する:

```
[HUMAN CONSULT] N件、今すぐ答えられます

番号付きでまとめて回答してください（例: 「1. a 2. 確認済み 3. スキップ」）。
「スキップ」と書いた項目は次回に持ち越します。

---

[1/N] HO-XXX: <タイトル>
種別: <Type> | 状態: <handoff_status> | 優先度: <priority の冒頭>

対象: <Goal から抽出した「どの画面・機能・要素」か。1行で具体的に>

なぜ Human 必須か:
<AI が決定できない理由を 1–3 文で。実機確認が必要 / product identity 変更 /
 scope 拡大 / 多軸 UX で妥当解が複数ある / SKILL.md 変更 など、根拠を明示>

背景:
<Goal / Context / Reason for Human escalation から抽出した経緯。
 「何が起きて、何が済んでいて、何が未決か」を 3–5 文で>

判断基準:
<何を優先すれば a / b / ... になるか。トレードオフの軸を 1–2 行で明示>

質問: <導出した質問>

選択肢:
  a) <選択肢A の説明> — <影響・リスク・コスト 1行>
  b) <選択肢B の説明> — <影響・リスク・コスト 1行>
  （選択肢が yes/no の場合は yes/no で可）

---

[2/N] IDEA-NNN: <タイトル>

対象: <どの画面・機能・フロー・ツールか>

なぜ Human 必須か:
<requires-human 理由の全文 + AI が判断できない具体的な理由>

背景:
<IDEA の目的・現状・依存関係を 3–5 文で。関連 handoff / REQ があれば明記>

判断基準:
<何を優先すれば採用 / 不採用 / 保留になるか>

質問: <導出した質問>

選択肢:
  a) 採用 — <採用した場合の次のアクションと影響>
  b) 不採用 — <不採用の場合の影響>
  c) 保留継続 — <保留を続ける条件・期限>

---

→ 各番号に答えてください。
```

ユーザーの回答を待つ。

---

### ステップ 4: 回答の処理と書き戻し

**fast path（bucket 由来）の場合**: 回答前に対象 handoff / IDEA のパスを特定してから書き戻しルールを適用する。

#### HO-NNN（handoff）への書き戻し

| 回答 | 書き戻しアクション |
|---|---|
| go | `handoff_status: active`・`Next Owner: Claude Code` に更新。`## Decisions` に判断日と理由を追記 |
| no-go | `handoff_status: blocked` に更新。`## Decisions` に理由を追記 |
| 完了確認済み | `handoff_status: done` に更新。`## Decisions` に確認日を追記 |
| 完了確認: まだ | 変更なし |
| 選択肢 a/b/c | `## Decisions` に選択結果を追記。`Next Owner: Claude Code` に変更 |
| 承認 Yes | `Next Owner: Claude Code` に変更。`## Decisions` に承認日を追記 |
| 承認 No / 修正依頼 | `## Decisions` に修正方針を追記。`Next Owner: Claude Code` + 修正指示を `## Next Action` に追記 |
| スキップ | 変更なし |

#### IDEA-NNN（ideas-backlog）への書き戻し

| 回答 | 書き戻しアクション |
|---|---|
| 採用 | `採否フィルター: auto-adoptable` に更新。理由を 1 行追記 |
| 不採用 | `採否フィルター: auto-rejectable` に更新。理由を 1 行追記 |
| 保留継続 / スキップ | 変更なし |

#### task-state.md の更新（存在する場合のみ）

Human-judgment Bucket テーブルの該当行の `suggested Human action` 欄を  
`[回答済み YYYY-MM-DD] → <次のアクション>` に更新する。

---

### ステップ 5: 結果サマリー出力

```
[HUMAN CONSULT] 完了

書き戻し済み:
- HO-XXX: go → handoff_status: active, Next Owner: Claude Code
- HO-YYY: 完了確認済み → handoff_status: done
- IDEA-NNN: 採用 → auto-adoptable

自律セッションの次 Re-scan（または次 /session-start）で actionable queue に入ります。

スキップ（次回持ち越し）:
- HO-ZZZ: <理由>

Skip 済み（条件該当）:
- HO-AAA: Decisions に既回答 / consult-attempted → Concrete
- IDEA-NNN: decision 行あり → 候補から除外
```

---

## 制約

- **自律セッションの稼働状態を問わない** — task-state.md がなくても handoff + backlog を直接スキャンして動く
- **ヒアリングは 1 回の出力で全件まとめる**（1問ずつ往復しない）
- **handoff の `## Goal` / `## Context` / `## Acceptance Criteria` は変更しない** — `## Decisions`・status フィールド・`## Next Action` だけを更新する
- **IDEA への書き込みは採否フィルター + 理由 1 行だけ** — `consult-attempted` マーカーは書き込まない
- **docs/requirements.md は変更しない**
- **実装・テスト・コミットは行わない** — ヒアリングと書き戻しのみ
