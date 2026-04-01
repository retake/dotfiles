# セットアップ手順

新マシンに環境を再現する手順。

## 前提

- OS: Ubuntu (WSL2 または Linux)
- `git`, `curl`, `gh` がインストール済みであること

---

## 手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/retake/dotfiles.git ~/dotfiles
```

### 2. セットアップスクリプトを実行

```bash
cd ~/dotfiles && bash setup.sh
```

以下のシンボリックリンクが作成される：

- `~/.bashrc`, `~/.bash_profile`, `~/.gitconfig`, `~/.vimrc` 等
- `~/.vim/`
- `~/.config/starship.toml`
- `~/.config/nvim/`
- `~/bin/` 配下のスクリプト群

### 3. `.credentials` を手動配置

シークレットはリポジトリ管理外のため手動で作成する。

```bash
vim ~/.credentials
```

`.bash_profile` が起動時に読み込む。フォーマット：

```bash
export SOME_API_KEY=xxx
export ANOTHER_SECRET=yyy
```

### 4. Neovimを最新版にインストール

aptのNeovimは古いため、公式リリースから直接インストールする。

```bash
# アーキテクチャを確認
uname -m
```

| アーキテクチャ | ダウンロードするファイル |
|---|---|
| `aarch64` | `nvim-linux-arm64.tar.gz` |
| `x86_64` | `nvim-linux-x86_64.tar.gz` |

```bash
# aarch64の場合
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
tar xzf nvim-linux-arm64.tar.gz
cp -r nvim-linux-arm64/* ~/.local/
rm -rf nvim-linux-arm64 nvim-linux-arm64.tar.gz

# x86_64の場合
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
cp -r nvim-linux-x86_64/* ~/.local/
rm -rf nvim-linux-x86_64 nvim-linux-x86_64.tar.gz
```

### 5. Neovimのプラグインをインストール

```bash
nvim
```

起動時にlazy.nvimが自動インストールされる。完了後 `:Lazy sync` を実行。

### 6. シェルを再起動

```bash
source ~/.bash_profile
```

---

## 確認

```bash
nvim --version   # v0.11以上であること
vim --version    # nvimが起動すること（aliasが効いていること）
starship --version
```

---

## Claude Code 開発環境

Claude Code を使った自律開発フロー（/orchestrate）を使う場合のみ実施する。

### 1. Claude Code をインストール

```bash
npm install -g @anthropic-ai/claude-code
```

Node.js が未インストールの場合は先にインストールする。

### 2. Claude Code 設定を展開

```bash
cd ~/dotfiles && bash setup-claude.sh
```

以下が作成される：

- `~/.claude/CLAUDE.md` → symlink
- `~/.claude/settings.json` → テンプレートから実ファイルとして生成（`$HOME` を展開）
- `~/.claude/skills/` → symlink（/orchestrate スキルを含む）
- `~/.claude/docs/` → symlink（requirements.md・design.md）
- `~/retrospectives/` → symlink（`_index.md` は dotfiles 管理、個別ファイルはローカルのみ）

### 3. 認証

```bash
claude
```

初回起動時に認証フローが走る。
