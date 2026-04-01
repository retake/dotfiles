# orchestrate 実行手順

自律開発フロー（FR-1〜FR-10）の実行手順。
数ヶ月後の自分向け。詳細仕様は `SKILL.md` と `~/claude-set/docs/design.md` を参照。

---

## 前提条件

- Claude Code がインストール済み
- `~/dotfiles/claude/settings.json` が設定済み（deny/allowリスト）
- プロジェクトに `docs/` ディレクトリが存在する

---

## 新規タスクの実行

### 1. タスク入力を書く

以下のテンプレートをチャットに貼り付けて記述する（ファイルでも直接入力でも可）：

```markdown
## 目的
何を解決するか。1〜3文で。

## 完了条件
- 〜できること
- 〜が返ること  ← 検証可能な形式で書く

## スコープ
### 対象
-
### 対象外
-

## 制約
- （なければ省略）

## タスク規模
- small / medium / large（省略可、デフォルト medium）
```

**入力が通らないケース（FR-1で停止する）：**
- 「目的」または「完了条件」が未記載
- 完了条件が「うまく動くこと」など検証不可能な形式

### 2. /orchestrate を起動する

```
/orchestrate
```

### 3. 確認停止への対応

フローは以下の7箇所で必ず止まる。止まるたびに入力して再開する。

| 停止 | 表示 | 対応 |
|---|---|---|
| FR-1 入力確認 | `[STOP] フェーズ: FR-1 入力確認` | 不足項目を補足して再入力 |
| FR-1 allowリスト | `[STOP] フェーズ: FR-1 allowリスト更新` | settings.json に追記 → 「承認」 |
| FR-2 技術選定 | `[STOP] フェーズ: FR-2 技術選定` | スタックを承認または変更を入力 |
| FR-3 設計承認 | `[STOP] フェーズ: FR-3 設計承認待ち` | docs/design-summary.md を確認 → 「承認」 |
| FR-5 テスト失敗 | `[ESCALATION] フェーズ: FR-5` | エラーを手動修正 → 「再開」 |
| FR-6 lint失敗 | `[ESCALATION] フェーズ: FR-6` | エラーを手動修正 → 「再開」 |
| FR-7 セキュリティ | `[STOP] フェーズ: FR-7 セキュリティ問題検出` | 手動修正 → 「再開」または「中止」 |

FR-2停止時にやること（よく忘れる）：
1. 提示されたスタックを承認または変更を入力
2. **ツールの存在確認・インストール**（pytest・flake8等が入っているか確認）
3. settings.json への allowリスト追加が済んだら「承認」

### 4. 完了後の処理

```bash
git diff                    # 変更内容の確認
git add src/ tests/ docs/   # 必要なファイルをステージング
git commit -m "..."         # コミット（push は手動）
```

成果物の確認先：
- `docs/traceability.md` — 要件→実装→テストの対応表
- `docs/completion-summary.md` — 変更内容・要確認事項

---

## 再開・リセット

### 前回の続きから再開する

`/orchestrate` を起動するだけ。`.claude/task-state.md` の status に応じて自動的に分岐する。

| status | 動作 |
|---|---|
| `waiting_approval` | 承認待ちの内容を表示して停止 |
| `escalated` | エスカレーション内容を表示して停止。手動修正後「再開」と入力 |
| `running` | 二重起動の警告を表示（下記参照） |
| `done` | 「完了済みです」と表示して終了 |

### タスクをリセットして最初からやり直す

`status: running` の警告が出た場合、または新規タスクとしてやり直したい場合：

1. `/orchestrate` を起動して `[STOP] 既に実行中のタスクがあります` を確認
2. 「リセット」と入力
3. task-state.md が削除されて新規タスクとして再起動される

> **注意:** `rm` はdenyリストに入っているため、リセット入力後にエージェントが `python3 -c "import os; os.remove(...)"` で削除する。

---

## よくある詰まりポイント

### pytest / flake8 が入っていない

pip/venv が使えない環境（apt管理Python）では以下でインストール：

```bash
sudo apt-get install -y python3-pytest python3-flake8
```

FR-2停止時に確認・インストールしておくと FR-5/FR-6 で詰まらない。

### settings.json への allowリスト追加

場所: `~/dotfiles/claude/settings.json`

追加パターン：

```json
"Bash(pytest*)",
"Bash(python3 -m pytest*)",
"Bash(flake8*)",
"Bash(npm test*)",
"Bash(go test*)"
```

### エスカレーション後の再開

1. `.claude/task-state.md` のエスカレーション記録を確認
2. 対象ファイルを手動修正
3. `/orchestrate` を起動して「再開」と入力
4. FR-5/FR-6 のエスカレーションの場合、試行回数は自動リセットされる

---

## ファイル構成（参照先）

```
~/.claude/skills/orchestrate/
├── SKILL.md        ← オーケストレーター本体（FR-1〜FR-10の定義）
└── README.md       ← 本ファイル

~/claude-set/docs/
├── design.md       ← 設計方針・フロー図・仕様
└── requirements.md ← 機能要件・非機能要件

<project-root>/
├── .claude/
│   ├── task-state.md   ← タスク状態・エスカレーション記録
│   └── agent-log.md    ← ツール呼び出しログ
└── docs/
    ├── design-summary.md    ← FR-3出力（設計サマリ）
    ├── traceability.md      ← FR-8出力（トレーサビリティ）
    └── completion-summary.md ← FR-8出力（完了サマリ）
```
