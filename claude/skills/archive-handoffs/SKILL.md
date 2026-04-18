---
name: archive-handoffs
description: 対応完了したハンドオフを docs/archive/ へ移動するスキル。/audit-handoffs で ✅ 判定が揃ったものを git mv でまとめてアーカイブし、関連ドキュメント（traceability.md・completion-summary.md）からの参照を洗い出す。
user-invocable: true
argument-hint: 対象ファイル名（複数可・空白区切り）。省略時は候補を提示
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(ls*)
  - Bash(mkdir -p docs/archive)
  - Bash(git mv*)
  - Bash(git ls-files*)
  - Bash(git status*)
  - Bash(git log*)
  - Bash(pwd)
---

# Archive Handoffs — 対応完了ハンドオフの移動スキル

`/audit-handoffs` で全指摘が ✅ 判定に揃ったハンドオフを `docs/archive/` へ `git mv` で移動する。
移動先に配置することで、以降の `/audit-handoffs`（引数なし実行）が対象外になり、
未対応・要判断のハンドオフだけが監査対象として残る。

## 使い方

- `/archive-handoffs` — 引数なし。現在の `docs/agent-handoff-*.md` 一覧を表示して対象指定を促す
- `/archive-handoffs <filename>` — 単一ファイルをアーカイブ（ファイル名は `docs/` からの相対パスまたは basename）
- `/archive-handoffs <f1> <f2>` — 複数一括アーカイブ

## 実行手順

### ステップ1: 対象ハンドオフの確定

1. 引数なしの場合:
   - `git ls-files docs/agent-handoff-*.md` と `ls docs/agent-handoff-*.md` を実行
   - 候補一覧を表示し「対応完了したファイルを指定してください（/audit-handoffs で事前確認推奨）」と促して終了
2. 引数ありの場合:
   - 各引数を `docs/agent-handoff-*.md` のいずれかに正規化する（basename 一致でも許容）
   - 存在しない指定があれば、その旨を表示して処理中断（部分実行しない）

### ステップ2: 対応状況の確認（Safety Gate）

指定された各ハンドオフについて、以下を必ず確認する：

1. **ファイルの最終更新と直近 commit**: `git log -1 --format='%cd %s' -- <file>` を実行し、
   「いつ・何のコミットで触られたか」を表示する
2. **traceability.md・docs/ideas-backlog.md・docs/design-summary.md からの参照**:
   `grep -l <basename> docs/` で参照ファイルを列挙する
3. **ユーザーへの確認メッセージ**を以下のフォーマットで提示：

   ```
   以下を docs/archive/ に移動します：
   
   - docs/agent-handoff-xxx.md
     最終更新: YYYY-MM-DD（コミット: <short sha> <subject>）
     参照元: docs/traceability.md, docs/ideas-backlog.md
   
   続行しますか？（はい / いいえ / 特定の番号だけ / スキップする番号）
   ```

   ユーザーが「はい」以外を返した場合は、対象を調整するか処理を中断する。

### ステップ3: アーカイブ実行

1. `docs/archive/` が存在しなければ `mkdir -p docs/archive` で作成
2. 各ファイルについて `git mv docs/agent-handoff-xxx.md docs/archive/` を実行
3. **untracked** なファイルは `git mv` が失敗する。その場合は一度 `git add` してから `git mv` する
   （または `mv` + `git add` でも良い。履歴追跡のため `git mv` を優先）

### ステップ4: 関連ドキュメントの参照チェック

ステップ2-2 で列挙した参照元ファイルを開き、移動後に壊れるリンクがあれば提示する。
**修正は自動適用しない**（要判断）。以下のパターンを検出：

- `docs/agent-handoff-xxx.md` というパスを含む相対リンク（Markdown）
- 該当ハンドオフの basename を含むテキスト（参照として言及している箇所）

修正案の例を提示し、ユーザーが承認すれば Edit で適用する：

```
## 参照リンクの更新提案

- docs/traceability.md の L234: 
  `[agent-handoff-xxx.md](agent-handoff-xxx.md)` 
  → `[agent-handoff-xxx.md](archive/agent-handoff-xxx.md)` に更新しますか？
```

### ステップ5: サマリ出力

```
[ARCHIVE] ハンドオフアーカイブ完了

## 移動したファイル
- docs/agent-handoff-xxx.md → docs/archive/agent-handoff-xxx.md

## 関連ドキュメント更新
（適用した更新の一覧、または「なし」）

## 次のアクション
- git status で差分を確認してください
- コミット推奨: `refactor(docs): ハンドオフ xxx をアーカイブ`
```

**注意**: コミットは自動実行しない（audit-handoffs・retro と同じポリシー）。
`git status` の表示と推奨コミットメッセージのみ提示する。

## 制約

- `docs/archive/` 以外には書き込まない
- コード・テストは修正しない（ドキュメント移動のみ）
- `git commit` / `git push` は行わない
- ユーザー承認なしに「全件一括アーカイブ」はしない（必ず Safety Gate を通す）
- untracked ファイルでも `git mv` で扱う（履歴保全のため `mv` + 新規 add は避ける）

## アンチパターン（やらないこと）

- `/audit-handoffs` を実行せずに「対応済みっぽい」ハンドオフを勝手にアーカイブする
- `docs/archive/` の既存ファイルを上書きする（同名が既にあれば警告して中断）
- 複数指定時に 1 件でも失敗したら残りを続行する（全件 or 全件中断）

## 運用上のヒント

- `/audit-handoffs` → `/archive-handoffs` の順で実行するのが通常フロー
- アーカイブ後は元ハンドオフが `/audit-handoffs` の対象外になるため、
  要判断（⚪）や部分対応（⚠️）のハンドオフは**アーカイブしない**
- アーカイブ済みハンドオフを再度確認したい場合は `/audit-handoffs 'docs/**/agent-handoff-*.md'`
