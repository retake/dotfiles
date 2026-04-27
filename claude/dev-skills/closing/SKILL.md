---
name: closing
description: セッション終了時の後処理スキル。状態スキャン → /sync → /audit-handoffs → 申し送り事項があれば handoff 起票 → /archive-handoffs → /retro → 未コミット・未push・Codex未レビューの警告、の順に実行し、次セッションが同等の文脈で再開できる状態にする。
model: sonnet
user-invocable: true
argument-hint: 省略可（`--skip-retro` で retro スキップ、`--skip-sync` で sync スキップ）
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Skill
  - Agent
  - Bash(ls*)
  - Bash(find*)
  - Bash(pwd)
  - Bash(date*)
  - Bash(git status*)
  - Bash(git log*)
  - Bash(git diff*)
  - Bash(git ls-files*)
  - Bash(git rev-parse*)
  - Bash(git branch*)
---

# Closing — セッション終了時の後処理スキル

文脈がクリアされた次セッションが、このセッションと同等の感覚で作業を再開できる状態にする。
既存の `/sync` `/audit-handoffs` `/archive-handoffs` `/retro` を順に呼ぶ薄いオーケストレーターで、
独自ロジックは「現状スキャン」「申し送り handoff の起票」「最終警告の提示」のみ。

## 設計方針

- **破壊的操作はしない**: コミット・push・アーカイブの自動実行は行わず、警告と推奨に留める
- **並行セッション前提**: resume ポインタは単一ファイルに集約せず、申し送り事項があるときだけ既存 handoff 形式で起票する
- **申し送りなしはスキップ可**: 残課題・保留判断・次セッションメモが 1 件もなければ handoff 作成をスキップする
- **検出フェーズはBG並列**: sync と audit-handoffs は Agent BG で並列起動し、完了通知後に結果を提示する
- **対話フェーズは逐次**: archive-handoffs・retro は Skill 経由で逐次実行（ユーザー確認が必要なため）

## 引数

- なし（デフォルト: 全ステップ実行）
- `--skip-retro` — ステップ6の `/retro` をスキップ（typo 修正など軽微なセッション向け）
- `--skip-sync` — ステップ2の `/sync` をスキップ（ドキュメント変更のみのセッション向け）

## 実行手順

### ステップ0: モード判定（自動）

以下の条件を **全て** 満たす場合は**簡略モード**、1つでも外れる場合は**通常モード**で進む。

判定コマンド（追跡ブランチなしは `HEAD~3..HEAD` にフォールバック）:
```bash
git log --name-only --format="" @{u}..HEAD 2>/dev/null || git log --name-only --format="" HEAD~3..HEAD
```

**簡略モード条件（全件 AND）:**
- `docs/requirements.md` が含まれない（新REQなし）
- `docs/agent-handoff-*.md` の追加・変更が含まれない（新handoff起票なし）
- `docs/` 配下のファイルが含まれない（ドキュメント変更なし）

**簡略モード** の場合は以下を出力してステップ1へ:
```
[CLOSING] モード: 簡略（UIのみセッション）
根拠: 新REQなし / 新handoffなし / docs変更なし
→ ステップ2（sync/audit）・ステップ5（archive）をスキップ
実行順: ステップ1 → ステップ6 → ステップ7
```

**通常モード** の場合は以下を出力してステップ1へ:
```
[CLOSING] モード: 通常
根拠: <条件を外れた理由（例: docs/requirements.md に変更あり）>
→ 全ステップを実行
```

### ステップ1: 現状スキャン

以下を並列実行し、結果をユーザーに要約提示する（各 1〜2 行）:

1. `git rev-parse --abbrev-ref HEAD` — 現在ブランチ
2. `git status --short` — 未コミット差分の件数
3. `git log --oneline @{u}..HEAD 2>/dev/null` — 未push commit（追跡ブランチがなければスキップ）
4. `git log --oneline -5` — 直近コミット履歴
5. `docs/task-state.md` が存在すれば先頭 20 行を Read
6. `.claude/retrospective-draft.md` の有無を ls で確認

提示フォーマット:
```
[CLOSING] セッション状態
- ブランチ: <branch>
- 未コミット: <N> 件
- 未push: <N> 件（<追跡先>）
- 直近コミット: <最新1行>
- task-state.md: あり（進行中タスク: <ID>）/ なし
- retro draft: あり / なし
```

### ステップ2: sync & audit-handoffs をBG並列起動（**簡略モード時はスキップ → ステップ6へ**）

`--skip-sync` が指定されていなければ、**単一メッセージで以下を並列バックグラウンド起動する**：

1. Agent(`subagent_type: "sync"`, `run_in_background: true`) — 乖離検出
2. Agent(`subagent_type: "audit-handoffs"`, `run_in_background: true`) — ハンドオフ照合

`--skip-sync` が指定されている場合は audit-handoffs のみBG起動する。

**両方（または audit-handoffs のみ）の完了通知を受け取ってからステップ3へ進む。**

### ステップ3: 結果の提示とユーザー確認

完了通知を受け取ったら、以下を順に処理する：

**sync 結果（`--skip-sync` でない場合）：**
- `.claude/sync-result.md` を Read して内容をユーザーに提示する
- 推奨アクションに「なし」以外の項目がある場合: 更新/スキップの判断をユーザーに委ねる
- 「変更なし」または「なし」の場合: スキップ

**audit-handoffs 結果：**
- `.claude/audit-result.md` を Read して内容をユーザーに提示する
- 残課題がある場合: 推奨アクションを提示してユーザーに委ねる
- 「ハンドオフなし」または残課題0件の場合: スキップ

### ステップ4: 申し送り handoff の起票

**4-a. 候補の列挙（Claude 先出し）**

ユーザーに白紙で質問する前に、Claude 自身がセッション文脈から**申し送り候補**を列挙する。候補は以下の観点で洗い出す:

- 本セッションで発生した未完了タスク（実装・テスト・docs）
- sync / audit-handoffs の出力で「次セッションへ繰り越し」と判定された項目
- 試行錯誤の過程で保留となった設計・仕様・実装方針の論点
- コード/ドキュメント/既存 handoff から読み取れない判断文脈（「なぜその選択をしたか」「なぜそれを放置しているか」）
- 運用 UX の気付き（対話の段取り・出力の重複等）

候補は 3 分類（残タスク / 判断保留 / 次セッションへのメモ）に振り分け、各項目について **「なぜ申し送る必要があるか」** を 1 行添える。候補ゼロ件なら「申し送り事項なし。ステップ5へ」と表示して次へ。

**4-b. 採否確認（ユーザー判断）**

列挙した候補をユーザーに提示し、以下のいずれかで回答してもらう:

- 「全部採用」
- 「#<記号>, #<記号> だけ採用」
- 「全部不要」

タイトル（handoff ファイル名の topic 部分）も同時に提案し、ユーザーは採用候補と合わせて確定する。

**4-c. handoff の書き出し**

**採用された候補が 1 つ以上ある場合**: `docs/agent-handoff-claudecode-<topic>-YYYYMMDD.md` を以下の形式で作成:

```markdown
# ハンドオフ: <採用タイトルを人間可読に>

**作成日**: YYYY-MM-DD
**担当**: Claude（セッションクロージング）→ 次セッション
**目的**: 本セッションで発生した残課題・判断保留・文脈を次セッションに引き継ぐ

## handoff_status
active

## Next Owner
Claude Code

---

## 背景

<セッションで何をしていたかを 2〜4 行で要約。ステップ1のスキャン結果と直近コミットから構成>

## 残タスク

（採用された残タスク候補を箇条書きに。なければセクションごと省略）

- [ ] <タスク1>
- [ ] <タスク2>

## 判断保留

（採用された判断保留候補を論点ごとに。なければセクションごと省略）

### <論点タイトル>
<背景・選択肢・現時点の仮説>

## 次セッションへのメモ

（採用された次セッションメモ候補をそのまま。なければセクションごと省略）

---

## Status

| # | 項目 | 判定 | 対応 |
|---|---|---|---|
| T-1 | <残タスク1> | 未対応 | 次セッション対応予定 |
| T-2 | <判断保留1> | 要判断 | 次セッションで論点確認 |
```

ファイル名ルール:
- 日付は `date +%Y%m%d` で取得（YYYYMMDD 形式、ハイフンなし）
- `<topic>` は 4-b で確定したタイトルを kebab-case に正規化（英数とハイフンのみ）
- 既存ファイルと衝突した場合は `<topic>-2` のように連番を付ける

### ステップ5: /archive-handoffs 実行（**簡略モード時はスキップ → ステップ6へ**）

`Skill: archive-handoffs` を呼ぶ。
ステップ3の audit 結果で「対応完了」判定されたハンドオフがあれば archive へ移動する。
ステップ4で新規作成したファイルは archive 対象ではない（未対応のため）。

### ステップ6: /retro 実行

`--skip-retro` が指定されていなければ `Skill: retro` を呼ぶ。
retro 側で draft の新鮮度判定と対話的起票が行われるため、closing 側では引数を渡さず素直に委譲する。

### ステップ7: 最終警告の提示

ここまでで自動修正しなかった項目を、警告としてまとめて表示する（実行はしない）。

**警告候補:**

1. **未コミット差分**: ステップ1で 1 件以上あった場合
   - 表示: `⚠️ 未コミット差分が <N> 件あります。コミットしますか？（git status で確認してください）`

2. **未push commit**: ステップ1で 1 件以上あった場合
   - 表示: `⚠️ 未push の commit が <N> 件あります。push する場合はユーザー承認後に実行してください`

3. **Codex レビュー未実施**: 以下のいずれかに該当するコミットが未push/直近に含まれる場合（`git log` の diff 内容・コミットメッセージから簡易判定）
   - `auth` / `session` / `token` / `crypto` を含む変更
   - `Timer` / `Stream` / `dispose` を含む変更
   - `+300` 行以上の大きなリファクタ commit
   - 表示: `⚠️ Codex レビュー推奨の変更が含まれます: <該当理由>。~/.claude/docs/codex-request-template.md を参照してください`

4. **新規 handoff 作成**: ステップ4で作成した場合
   - 表示: `✅ 申し送り handoff を作成しました: docs/agent-handoff-claudecode-<topic>-YYYYMMDD.md`

警告がゼロ件の場合:
```
✅ クロージング完了。クリーンな状態でセッションを終了できます。
```

## 制約

- コミット・push・ブランチ操作は行わない（警告のみ）
- `docs/archive/` への移動は `/archive-handoffs` に委譲（closing 直接は触らない）
- ステップ4で作成する handoff は必ず `docs/` 直下（archive ではない）に置く
- 既存 handoff を上書きしない（ファイル名衝突時は連番で回避）
- retro draft が残っている場合でも強制起票しない（retro 側の判定に任せる）

## 想定利用シーン

- 1 日の作業終了時、次の作業日に備えた整理
- 並行セッションで別作業に切り替える前の一区切り
- 長時間作業後に文脈を整理したいとき
- PR 作成前の最終確認（※ PR 作成自体は closing の責務外）
