# roles/ — 役割別プロファイル

Claude Code のセッションを役割（work / life / consulting）ごとに切り替えるためのプロファイル集。各ディレクトリに `CLAUDE.md`（モード説明）と `settings.json`（MCP / permissions / autoMemoryDirectory）が入る。

## 現状ステータス

**未配線**。setup-claude.sh は `~/.claude/` に roles/ を配置しない。以下のいずれかの運用で使う想定（どれを採用するかは未決定）:

1. **明示的な config 指定**: `claude --config ~/dotfiles/claude/roles/work/settings.json` で起動
2. **作業ディレクトリ別の自動適用**: `~/work/` `~/life/` `~/consulting/` 配下でのみ該当 CLAUDE.md が読まれる symlink を setup-claude.sh に追加
3. **手動 source**: セッション開始時に「ロール切り替え」宣言して CLAUDE.md を読み込ませる

## 各ロールの目的

| ロール | 想定場面 | 特徴 |
|---|---|---|
| work | 社内業務・開発実務 | `autoMemoryDirectory: ~/dotfiles/claude/memory/work`、npm/go/docker 系 Bash 許可 |
| life | Todoist / Googleカレンダー / Gmail / 家計管理 | Todoistラベル体系・ネクストアクション運用ルール |
| consulting | 中小企業診断士業務・クライアント対応 | Box 連携ルール（`/mnt/c/Users/keita/Box/` 直書き vs Box MCP の使い分け） |

## 次に決めること

- **採用する配線方式**: 上記3案から選ぶ。2 がもっとも自動適用度が高く、dev-CLAUDE.md（`~/dev/` 配下に自動適用）と同じ方式で一貫性が取れる
- **memory 配線**: `~/dotfiles/claude/memory/work` 等を settings.json で指定しているが、現状 work/consulting の MEMORY.md はほぼ空（[user_memory_scope_triage.md](../memory/global/user_memory_scope_triage.md) 参照）。ロールを活かすなら各スコープを使い始める運用を決める
- **未採用なら削除**: 3 ヶ月以上使わなければ dead code として削る候補
