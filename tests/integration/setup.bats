#!/usr/bin/env bats

load '../bats-support/load'
load '../bats-assert/load'

DOTFILES_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

setup() {
  FAKE_HOME=$(mktemp -d)
  export HOME="${FAKE_HOME}"
}

teardown() {
  rm -rf "${FAKE_HOME}"
}

@test "setup.sh が正常終了する" {
  run bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert_success
}

@test ".bashrc のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/.bashrc" ]
}

@test ".bashrc のリンク先が dotfiles のファイルを指している" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  local link_target
  link_target=$(readlink "${FAKE_HOME}/.bashrc")
  assert_equal "${link_target}" "${DOTFILES_DIR}/.bashrc"
}

@test "starship.toml のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/.config/starship.toml" ]
}

@test "nvim のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/.config/nvim" ]
}

@test "nvim のリンク先が dotfiles のディレクトリを指している" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  local link_target
  link_target=$(readlink "${FAKE_HOME}/.config/nvim")
  assert_equal "${link_target}" "${DOTFILES_DIR}/nvim"
}

@test "claude/CLAUDE.md のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup-claude.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/.claude/CLAUDE.md" ]
}

@test "claude/CLAUDE.md のリンク先が dotfiles のファイルを指している" {
  bash "${DOTFILES_DIR}/setup-claude.sh" < /dev/null
  local link_target
  link_target=$(readlink "${FAKE_HOME}/.claude/CLAUDE.md")
  assert_equal "${link_target}" "${DOTFILES_DIR}/claude/CLAUDE.md"
}

@test "claude/settings.json が実ファイルとして生成される" {
  bash "${DOTFILES_DIR}/setup-claude.sh" < /dev/null
  assert [ -f "${FAKE_HOME}/.claude/settings.json" ]
  assert [ ! -L "${FAKE_HOME}/.claude/settings.json" ]
}

@test "claude/settings.json に __HOME__ が残っていない" {
  bash "${DOTFILES_DIR}/setup-claude.sh" < /dev/null
  run grep "__HOME__" "${FAKE_HOME}/.claude/settings.json"
  assert_failure
}

@test "bin/absolute_path.sh のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/bin/absolute_path.sh" ]
}

@test "bin/create_random_list.sh のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/bin/create_random_list.sh" ]
}

@test "bin/random_number.sh のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/bin/random_number.sh" ]
}

@test "bin/rspec_parser.sh のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ -L "${FAKE_HOME}/bin/rspec_parser.sh" ]
}

@test ".git はシンボリックリンクされない" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ ! -e "${FAKE_HOME}/.git" ]
}

@test ".credentials はシンボリックリンクされない" {
  bash "${DOTFILES_DIR}/setup.sh" < /dev/null
  assert [ ! -e "${FAKE_HOME}/.credentials" ]
}
