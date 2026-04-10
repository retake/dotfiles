#!/usr/bin/env bash
set -euxo pipefail

# Claude Code 開発環境のセットアップ
# 基本dotfiles（setup.sh）とは独立して実行できる

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

create_symlink() {
  local source_path=$1
  local target_path=$2
  ln -snfv "${source_path}" "${target_path}"
}

create_directory_if_not_exists() {
  local dir_path=$1
  if [ ! -d "${dir_path}" ]; then
    mkdir -p "${dir_path}"
  fi
}

create_directory_if_not_exists "${HOME}/.claude"

create_directory_if_not_exists "${HOME}/.claude/scripts"

create_symlink "${DOTFILES_DIR}/claude/scripts/notify.sh" "${HOME}/.claude/scripts/notify.sh"
create_symlink "${DOTFILES_DIR}/claude/CLAUDE.md"       "${HOME}/.claude/CLAUDE.md"

# dev/ 配下の共通CLAUDE.md（全プロジェクト共通の開発スタイル・Codex連携設定）
create_directory_if_not_exists "${HOME}/dev"
create_symlink "${DOTFILES_DIR}/claude/dev-CLAUDE.md"  "${HOME}/dev/CLAUDE.md"
# skills/agents/docs はディレクトリシンボリンクにしない。
# ディレクトリ丸ごとリンクすると ~/.claude/ 側への書き込みが
# dotfiles の実体を破壊するリスクがある（循環シンボリンク事故の再発防止）。
# サブディレクトリを作り、中のファイルを個別にリンクする。
link_directory_contents() {
  local src_dir=$1
  local dst_dir=$2
  # 既存のディレクトリシンボリンクがあれば除去（移行用）
  [ -L "${dst_dir}" ] && rm -f "${dst_dir}"
  create_directory_if_not_exists "${dst_dir}"
  for child in "${src_dir}"/*/; do
    [ -d "$child" ] || continue
    local name
    name=$(basename "$child")
    create_directory_if_not_exists "${dst_dir}/${name}"
    for file in "$child"*; do
      [ -f "$file" ] || continue
      create_symlink "$file" "${dst_dir}/${name}/$(basename "$file")"
    done
  done
  # ディレクトリ直下のファイル（サブディレクトリを持たないケース）
  for file in "${src_dir}"/*; do
    [ -f "$file" ] || continue
    create_symlink "$file" "${dst_dir}/$(basename "$file")"
  done
}

link_directory_contents "${DOTFILES_DIR}/claude/skills" "${HOME}/.claude/skills"
link_directory_contents "${DOTFILES_DIR}/claude/agents" "${HOME}/.claude/agents"
link_directory_contents "${DOTFILES_DIR}/claude/docs"   "${HOME}/.claude/docs"
create_symlink "${DOTFILES_DIR}/claude/keybindings.json" "${HOME}/.claude/keybindings.json"
create_symlink "${DOTFILES_DIR}/retrospectives"         "${HOME}/retrospectives"

# settings.jsonはテンプレートからホームディレクトリを展開して実ファイルとして生成する
# （シンボリックリンクにするとパスがハードコードされたまま別マシンで機能しないため）
[ -L "${HOME}/.claude/settings.json" ] && rm -f "${HOME}/.claude/settings.json"
sed "s|__HOME__|${HOME}|g; s|__TODOIST_API_TOKEN__|${TODOIST_API_TOKEN:-}|g" \
  "${DOTFILES_DIR}/claude/settings.template.json" > "${HOME}/.claude/settings.json"
echo "Generated: ${HOME}/.claude/settings.json (HOME=${HOME})"
