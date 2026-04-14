# ハンドオフ: ~/.claude/settings.json と template の乖離解消

作成日: 2026-04-14
起点セッション: worktree 分離ワークフロー整備（コミット `a94bdb0`, `06a988e`）

## 背景

今回 `setup-claude.sh` に `worktree-check.sh` の symlink を追加し、`claude/settings.template.json` に SessionStart hook を追加した。その過程で **現行 `~/.claude/settings.json` が template から大きく育っている** ことが判明した。

### 具体的な乖離

`~/.claude/settings.json` の `permissions.allow` にはローカルで追加された多数のエントリがある（template 未反映）：

```
Bash(pactl list:*)
Bash(pactl info:*)
Read(//home/keita/.pub-cache/**)
Bash(~/dev/tools/flutter/bin/flutter pub:*)
Bash(~/dev/tools/flutter/bin/flutter analyze:*)
Bash(~/dev/tools/flutter/bin/flutter test:*)
Bash(~/dev/tools/flutter/bin/flutter clean:*)
Bash(awk -F'|' '{print $2}')
Skill(retro)
Skill(retro:*)
Read(//usr/lib/**)
Read(//tmp/**)
Bash(flutter devices:*)
Bash(/home/keita/snap/flutter/common/flutter/bin/flutter devices:*)
Read(//snap/bin/**)
Bash(snap list:*)
Read(//home/keita/snap/flutter/common/flutter/**)
Read(//home/keita/snap/**)
Read(//home/keita/snap/flutter/**)
Read(//home/keita/**)
Bash(/home/keita/dev/tools/flutter/bin/flutter --version)
Bash(/home/keita/dev/tools/flutter/bin/flutter pub:*)
Bash(/home/keita/dev/tools/flutter/bin/flutter analyze:*)
Bash(/home/keita/dev/tools/flutter/bin/flutter test:*)
Skill(update-config)
Skill(update-config:*)
```

`additionalDirectories` も同様（alarm / dev / dotfiles / .claude など）。

## リスク

- `setup-claude.sh` は `sed` で template から settings.json を生成する際、既存ファイルを上書きする（66–69行目）
- **再実行すると上記 permissions が全消滅する**
- 新マシンセットアップ時は `cc-new` 等の新機能は反映されるが、現在 Claude が許可なく叩いている flutter/snap/Skill 系が全部確認プロンプト化する

## やるべきこと

### 方針の選択肢

| 方針 | 内容 | 推奨度 |
|---|---|---|
| A. 全吸い上げ | 現行 permissions を template に全部入れる | △（template が肥大化、一時的な allow まで残る） |
| B. 定常/試行錯誤の分離 | 定常分のみ template に、試行錯誤は `settings.local.json` で育てる | ○（推奨） |
| C. 分割ファイル化 | hooks/permissions/mcpServers を別ファイルに分けて merge | ×（Claude Code はファイル分離をサポートしない） |

### 推奨 B の具体手順

1. 現行 `~/.claude/settings.json` の allow/deny/additionalDirectories をレビューし、**定常分と試行錯誤分を仕分ける**
   - 定常分（template 行き）: flutter の基本コマンド、Skill(retro) / Skill(update-config)、`Read(__HOME__/snap/**)` 等の安定パス
   - 試行錯誤分（local 行き or 削除）: `awk -F'|' ...` のような一度だけの許可、重複エントリ（`~/dev/tools/flutter/...` と `/home/keita/dev/tools/flutter/...` が両方ある等）
2. `claude/settings.template.json` に定常分を `__HOME__` プレースホルダ化して追記
3. `setup-claude.sh` を**非破壊化**する（既存 settings.json があれば mcp token のみ差し替えてマージ、完全上書きを避ける）
   - 実装案: `jq` が使えれば merge、使えなければ python3 で dict マージ
   - または「初回のみ生成、既存がある場合は `.claude/settings.local.json` に追加分を書く」運用に変更
4. 別マシンでドライラン確認

### 作業スコープ外（別課題）

- Codex 依頼ルールを CLAUDE.md に追加（「依頼前に worktree 欄を埋める」徹底用）
- alarm リポの untracked ファイル整理（`docs/agent-handoff-claudecode-impl-test-gap-review-20260414.md` 等）

## 参照

- 対象: `claude/settings.template.json`, `setup-claude.sh`
- 関連コミット: `a94bdb0` (cc-new 追加), `06a988e` (template/setup 反映)
- Claude Code settings 仕様: https://docs.claude.com/en/docs/claude-code/settings

## 完了条件

- [ ] 定常/試行錯誤の仕分けが完了している
- [ ] template に定常分が反映されている
- [ ] `setup-claude.sh` 再実行で既存の permissions が消えない（非破壊化）
- [ ] 別マシン想定でドライラン（`HOME=/tmp/test-home bash setup-claude.sh` など）が通る
