# dotfiles 要件定義

## 目的

個人開発環境の再現性を確保する。新マシン（WSL2/Windows、またはMac）に移行した際に、同じ作業環境を最小コストで復元できる状態にする。

## 解決する問題

- 過去の業務環境（特定チーム・Ruby/Rails）の残骸を除去し、現在の個人用途に整理する
- セットアップ手順を文書化し、移行時の手順を明確にする

## 解決しない問題

- 言語スタックの刷新（dotfilesの責務外）

---

## 前提・制約

- 主な作業環境：WSL2/Windows（Ubuntu、aarch64）
- Mac移行の可能性あり → OS依存の処理は `os/` 配下に分離して管理する
- 個人用途のみ（チーム共有・組織依存の設定は含めない）
- シークレット（`.credentials`）はリポジトリに含めない

---

## ディレクトリ構成

```
dotfiles/
├── .bash_profile        # starship init / .credentials読み込み
├── .bashrc              # エイリアス・PATH・EDITOR設定
├── .gitconfig
├── .vimrc               # Vim設定（vim-plug）
├── .vim/                # Vimプラグイン設定
├── bin/                 # シェルスクリプト（claude-sandbox含む）
├── claude/              # Claude Code設定（settings.json, CLAUDE.md）
├── docs/                # 要件定義等ドキュメント
├── lib/                 # 共通シェル関数
├── nvim/                # Neovim設定（lazy.nvim）
├── os/windows/          # Windows固有設定（AHK等）
├── setup.sh             # セットアップスクリプト
└── starship.toml        # プロンプト設定
```

---

## セットアップ手順

→ [SETUP.md](../SETUP.md) を参照。

---

## 各コンポーネントの方針

### シェル（bash）
- プロンプト：starship
- シークレット：`~/.credentials` から `set -a` で一括export

### エディタ
- **Vim**：vim-plug管理。既存環境の継続利用
- **Neovim**：lazy.nvim管理。新環境での主エディタ
  - `nvim/lua/config/options.lua`：基本設定
  - `nvim/lua/config/keymaps.lua`：キーバインド
  - `nvim/lua/plugins/editor.lua`：ファイラー・編集補助
  - `nvim/lua/plugins/ui.lua`：カラースキーム
  - `nvim/lua/plugins/lsp.lua`：LSP基盤（mason + nvim-lspconfig + nvim-cmp）

### LSP（Neovim）
- mason.nvimでLSPサーバーを管理
- 使う言語サーバーは `lsp.lua` の `ensure_installed` に追加する
- 現時点では未設定（言語が確定してから追加）

---

## wishlist（将来タスク）

- **LSP言語サーバーの追加**：使う言語が確定したら `lsp.lua` の `ensure_installed` に追加
- **カラースキームの設定**：`ui.lua` でTomorrow-Nightがコメントアウト中
- **Mac対応**：`os/mac/` 配下にHomebrew等のセットアップスクリプトを整備
- **Vim AI補完の再検討**：coc.nvim/copilot.vim等を削除済み。現行の選択肢を改めて評価する
