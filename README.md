# dotfiles

WSL2/Windowsを主な作業環境とした個人開発環境のdotfiles。新マシンへの移行コストを最小化することを目的とする。

## 構成

| パス | 内容 |
|---|---|
| `.bash_profile`, `.bashrc` | シェル設定（エイリアス、PATH、プロンプト） |
| `.vimrc`, `.vim/` | Vim設定・プラグイン（dein.vim） |
| `.gitconfig` | Git設定 |
| `bin/` | ユーティリティスクリプト |
| `lib/` | スクリプト共通ライブラリ |
| `os/windows/` | Windows固有設定（WSL2設定、AutoHotkey） |
| `claude/` | Claude Code設定 |

## セットアップ

### 1. リポジトリをクローン

```bash
git clone https://github.com/retake/dotfiles.git ~/dotfiles
```

### 2. `.credentials` を手動で作成

`.credentials` はシークレットを含むためリポジトリに含まれていない。手動で作成する。

```bash
touch ~/.credentials
# 必要な環境変数を記載する
# 例: export SOME_API_KEY="your_key"
```

### 3. セットアップスクリプトを実行

```bash
cd ~/dotfiles
bash setup.sh
```

dotfilesのシンボリックリンクが `~/` に作成される。

## Windows固有の設定

- `os/windows/.wslconfig`: WSL2のメモリ制限設定。`C:\Users\<username>\` に配置する
- `os/windows/ahk/`: AutoHotkeyスクリプト。Vimキーバインドをシステム全体に適用する
- `os/windows/task_scheduler/`: ログオン時にAutoHotkeyを自動起動するタスクスケジューラ設定
