# dotfiles リファクタリング 要件定義

## 目的

個人開発環境の再現性を確保する。新マシン（WSL2/Windows、またはMac）に移行した際に、同じ作業環境を最小コストで復元できる状態にする。

## 解決する問題

- 現行dotfilesには過去の業務環境（特定チーム・Ruby/Rails）の残骸が混在しており、現在の用途と乖離している
- Ubuntu 18.04 LTS向けスクリプトなど、動作しない設定が放置されている
- セットアップ手順が文書化されておらず、移行時の手順が不明確

## 解決しない問題

- エディタのneovim移行（別タスク）
- 言語スタックの刷新（dotfilesの責務外）

---

## スコープ

### やること

| 区分 | 対象 | 内容 |
|------|------|------|
| E（排除） | `dist/ubuntu18.04lts/` | EOL環境向けスクリプト。現行環境（WSL2/Ubuntu 22.04以降）では使用しない |
| E（排除） | `bin/open_assigned.sh`, `bin/open_reviewer.sh` | 特定orgへの依存あり。個人用途では不要 |
| E（排除） | `bin/debug.log`, `bin/sample/` | 不要ファイル・サンプル |
| E（排除） | `dist/linux/` | 未使用（mdcat）。削除後にディレクトリが空になるため丸ごと除外 |
| E（排除） | `sample/` | 未使用（.prettierrc, .rubocop.yml） |
| E（排除） | `template/` | 未使用（プロジェクト管理テンプレート） |
| E（排除） | `dein.toml` のコメントアウト群 | 死んだ設定（LSP/surround等） |
| E（排除） | `dein.toml` のRuby関連プラグイン | vim-rails, vim-ruby-heredoc-syntax, vim-rubocop, aleのRubocop設定等 |
| E（排除） | `dein.toml` のAI補完・用途不明プラグイン | 動作確認できないため一旦削除、後日再検討 |
| E（排除） | `.bash_profile` の `GITHUB_AUTH_KEY` プレースホルダ | 無意味な値。`.credentials` と二重管理 |
| E（排除） | `.vim/config/init/rspec.vim` | Rubyを使わないため全体が不要 |
| E（排除） | `dein_lazy.toml` のRuby/未使用プラグイン | `dein.toml` と同様に精査・削除 |
| E（排除） | `bin/parse_git_branch.sh` | `.bash_profile` へのインライン化により不要になる |
| E（排除） | `install_env.sh` の `.credentials` symlink | シークレットをsymlink対象から除外 |
| C（結合） | `install_env.sh` + `dist/*/install_bulk.sh` | `setup.sh` 1ファイルに統合 |
| R（再配置） | `dist/windows/` | `os/windows/` に移動 |
| R（再配置） | `ahk/` | `os/windows/ahk/` に移動（Windows固有設定の集約） |
| R（再配置） | `bin/source/` | `lib/` に移動 |
| S（簡素化） | `.bash_profile` のPS1 | `parse_git_branch.sh` 呼び出しをインライン化 |
| S（簡素化） | `README.md` | リポジトリの目的・構成・セットアップ手順を記載。`.credentials` の手動配置も明示 |

### やらないこと

- neovim移行（別タスク）
- Ruby/Rails向け設定の新規追加
- Mac対応の完全実装（移行可能性はあるが今回のスコープ外）
- チーム向け機能の追加
- 新規ツール・プラグインの導入（現代化はwishlistに記録、今回は整理のみ）

---

## 前提・制約

- 主な作業環境：WSL2/Windows（Ubuntu 22.04以降想定）
- Mac移行の可能性あり → OS依存の処理は `os/` 配下に分離して管理する
- 個人用途のみ（チーム共有・組織依存の設定は含めない）
- エディタはVim（dein.vim）のまま。neovim移行は別タスク
- シークレット（`.credentials`）はリポジトリに含めない

---

## 判断基準

- **E（排除）**: 現在使っていない、または特定チーム・組織・言語スタックに依存しており個人用途に転用できないもの
- **C（結合）**: 目的が同じで分散しているもの（統合によって管理コストが下がるもの）
- **R（再配置）**: 構造上の置き場が適切でないもの（OS固有設定は `os/` 配下に集約）
- **S（簡素化）**: 動いているが複雑すぎるもの（スクリプト呼び出しのインライン化、ドキュメント整備）

---

## wishlist（将来タスク）

- neovim移行：LSP補完（定義ジャンプ・参照・リネーム）が目的。nvim-lspconfig + nvim-cmpがデファクト
- Mac対応：`os/mac/` 配下にHomebrew等のセットアップスクリプトを整備
- Vim AI補完の再検討：以下を削除後、現行の選択肢を改めて評価する
  - coc.nvim（補完エンジン。重い・設定複雑）
  - copilot.vim（GitHub Copilot連携）
  - vim-chatgpt（ChatGPT連携）
  - ai-review.vim（AIコードレビュー）
- Vimプラグインの再検討：以下を削除後、必要になったら改めて導入を検討する
  - ctrlp.vim（fuzzyファイル検索）
  - any-jump.vim（定義ジャンプ）
  - vim-fugitive（Git操作）
  - blamer.nvim（行単位のGit blame表示）
  - vim-gitgutter（差分をgutter表示）
  - vim-airline（ステータスバー装飾）
  - vim-startify（起動時ダッシュボード）
  - vim-indent-guides（インデントの可視化）
  - ale（非同期lint）
  - vim-dispatch（非同期コマンド実行）
  - translate.vim（行単位の翻訳）
  - preview-markdown.vim（マークダウンプレビュー）
