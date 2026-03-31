#!/usr/bin/env bats

load '../bats-support/load'
load '../bats-assert/load'

SCRIPT="${BATS_TEST_DIRNAME}/../../bin/absolute_path.sh"

setup() {
  TEST_DIR=$(mktemp -d)
}

teardown() {
  rm -rf "${TEST_DIR}"
}

@test "ファイルの絶対パスを返す" {
  local tmpfile="${TEST_DIR}/sample.txt"
  touch "${tmpfile}"

  run bash "${SCRIPT}" "${tmpfile}" < /dev/null

  assert_success
  assert_output "${tmpfile}"
}

@test "ディレクトリの絶対パスを返す" {
  run bash "${SCRIPT}" "${TEST_DIR}" < /dev/null

  assert_success
  assert_output "${TEST_DIR}"
}

@test "stdin からパスを受け取る" {
  local tmpfile="${TEST_DIR}/sample.txt"
  touch "${tmpfile}"

  run bash -c "echo '${tmpfile}' | bash '${SCRIPT}'"

  assert_success
  assert_output "${tmpfile}"
}

@test "存在しないパスは出力なしで終了する" {
  run bash "${SCRIPT}" "${TEST_DIR}/nonexistent"

  assert_success
  assert_output ""
}
