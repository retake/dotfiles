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

  # BATSはstdinをパイプに接続するため< /dev/nullで明示的に封じる
  run bash "${SCRIPT}" "${tmpfile}" < /dev/null

  assert_success
  assert_output "${tmpfile}"
}

@test "ディレクトリの絶対パスを返す" {
  # BATSはstdinをパイプに接続するため< /dev/nullで明示的に封じる
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
  # BATSはstdinをパイプに接続するため< /dev/nullで明示的に封じる
  run bash "${SCRIPT}" "${TEST_DIR}/nonexistent" < /dev/null

  assert_success
  assert_output ""
}

@test "相対パスを絶対パスに変換する" {
  local tmpfile="${TEST_DIR}/sample.txt"
  touch "${tmpfile}"

  # サブシェルでTEST_DIRに移動して相対パスで渡す
  run bash -c "cd '${TEST_DIR}' && bash '${SCRIPT}' './sample.txt' < /dev/null"

  assert_success
  assert_output "${tmpfile}"
}

@test "引数なし・stdinも空のとき出力なしで終了する" {
  run bash "${SCRIPT}" < /dev/null

  assert_success
  assert_output ""
}
