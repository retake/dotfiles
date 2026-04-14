---
name: dotfilesリファクタリング（完了・push済み）
description: dotfilesリファクタリングとneovim移行の完了状態・残課題の記録
type: project
---

## 状態：すべての作業完了・push済み（2026-03-30）

---

## 完了した作業（全コミット push済み）

### リファクタリング（フェーズ1）
- 死んだ設定・ファイルの全削除（ubuntu18.04lts、Ruby関連等）
- dein.vim → vim-plug 移行
- starship プロンプト導入（手書きPS1を廃止）
- ディレクトリ構造整理（os/windows/, lib/ 等）
- setup.sh に starship・nvim・Claude設定のsymlink追加
- .credentials / .claude をsymlink対象から除外

### Neovim移行
- lazy.nvim + nvim-lspconfig + nvim-cmp の基盤構築
- fern.vim・編集補助プラグインをLuaに移植
- desertカラースキーム（組み込み）を設定
- Neovim本体：apt版（v0.9.5）は古いためarm64 tarballで最新版を~/.local/に配置
- EDITOR=nvim / alias vim=nvim を .bashrc に追加

### Claude Code設定
- claude/CLAUDE.template.md：新プロジェクト用CLAUDE.mdテンプレートを追加
- settings.local.json：starship一時permissionを削除（このファイルはgit管理外）

---

## 現在のディレクトリ構成

```
dotfiles/
├── .bash_profile      # starship init / .credentials読み込み
├── .bashrc            # エイリアス・PATH・EDITOR=nvim
├── .gitconfig
├── .vimrc             # Vim設定（vim-plug）
├── .vim/              # Vimプラグイン設定（vim-plug）
├── bin/               # シェルスクリプト（claude-sandbox含む）
├── claude/            # Claude設定（CLAUDE.md, settings.json, CLAUDE.template.md）
├── docs/              # requirements.md
├── lib/               # pipe_base.sh
├── nvim/              # Neovim設定（lazy.nvim）
├── os/windows/        # Windows固有設定（AHK等）
├── setup.sh           # セットアップスクリプト
└── starship.toml
```

---

## 残課題（wishlist）

- **LSP言語サーバーの追加**：`nvim/lua/plugins/lsp.lua` の `ensure_installed` に追加する（言語確定後）
- **Mac対応**：os/mac/ 配下にHomebrew等整備
- **Vim AI補完の再検討**：現行の選択肢を改めて評価

**Why:** 個人開発環境の再現性確保が目的。リファクタリング・neovim移行ともに完了。
**How to apply:** 次の作業はLSP言語サーバー追加か新プロジェクト開始時のCLAUDE.md作成。
