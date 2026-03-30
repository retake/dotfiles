#!/bin/bash -ex

create_symlink() {
  local source_path=$1
  local target_path=$2
  ln -snfv "${source_path}" "${target_path}"
}

create_directory_if_not_exists() {
  local dir_path=$1
  if [ ! -d "${dir_path}" ]; then
    mkdir "${dir_path}"
  fi
}

cd $(dirname $0)

# 必要なファイルのリンクを作成
for dotfile in .??*; do
  [ "${dotfile}" = ".git" ] && continue
  [ "${dotfile}" = ".github" ] && continue
  [ "${dotfile}" = ".rbenv" ] && continue
  [ "${dotfile}" = ".credentials" ] && continue
  [ "${dotfile}" = ".claude" ] && continue

  create_symlink $(pwd)/${dotfile} ${HOME}/${dotfile}
done

# 必要なディレクトリのリンクを作成
create_symlink $(pwd)/.vim ${HOME}/.vim

# starship設定ファイルのリンクを作成
create_directory_if_not_exists ${HOME}/.config
create_symlink $(pwd)/starship.toml ${HOME}/.config/starship.toml

# neovim設定ファイルのリンクを作成
create_symlink $(pwd)/nvim ${HOME}/.config/nvim

# Claude Code設定ファイルのリンクを作成
create_directory_if_not_exists ${HOME}/.claude
create_symlink $(pwd)/claude/CLAUDE.md ${HOME}/.claude/CLAUDE.md
create_symlink $(pwd)/claude/settings.json ${HOME}/.claude/settings.json

create_directory_if_not_exists ${HOME}/bin

cd bin

for shell_script in ?*.sh; do
  create_symlink $(pwd)/${shell_script} ${HOME}/bin/${shell_script}
done
