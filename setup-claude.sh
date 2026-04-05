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
create_symlink "${DOTFILES_DIR}/claude/skills"          "${HOME}/.claude/skills"
create_symlink "${DOTFILES_DIR}/claude/agents"          "${HOME}/.claude/agents"
create_symlink "${DOTFILES_DIR}/claude/docs"            "${HOME}/.claude/docs"
create_symlink "${DOTFILES_DIR}/claude/keybindings.json" "${HOME}/.claude/keybindings.json"
create_symlink "${DOTFILES_DIR}/retrospectives"         "${HOME}/retrospectives"

# settings.jsonはテンプレートからホームディレクトリを展開して実ファイルとして生成する
# （シンボリックリンクにするとパスがハードコードされたまま別マシンで機能しないため）
[ -L "${HOME}/.claude/settings.json" ] && rm -f "${HOME}/.claude/settings.json"
sed "s|__HOME__|${HOME}|g; s|__TODOIST_API_TOKEN__|${TODOIST_API_TOKEN:-}|g" \
  "${DOTFILES_DIR}/claude/settings.template.json" > "${HOME}/.claude/settings.json"
echo "Generated: ${HOME}/.claude/settings.json (HOME=${HOME})"
