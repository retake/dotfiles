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
  run bash "${DOTFILES_DIR}/setup.sh"
  assert_success
}

@test ".bashrc のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh"
  assert [ -L "${FAKE_HOME}/.bashrc" ]
}

@test ".bashrc のリンク先が dotfiles のファイルを指している" {
  bash "${DOTFILES_DIR}/setup.sh"
  local link_target
  link_target=$(readlink "${FAKE_HOME}/.bashrc")
  assert_equal "${link_target}" "${DOTFILES_DIR}/.bashrc"
}

@test "starship.toml のシンボリックリンクが作成される" {
  bash "${DOTFILES_DIR}/setup.sh"
  assert [ -L "${FAKE_HOME}/.config/starship.toml" ]
}
