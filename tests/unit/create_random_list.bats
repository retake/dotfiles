#!/usr/bin/env bats

load '../bats-support/load'
load '../bats-assert/load'

SCRIPT="${BATS_TEST_DIRNAME}/../../bin/create_random_list.sh"

setup() {
  export TEST_DIR=$(mktemp -d)
  STUB_BIN="${TEST_DIR}/stub_bin"
  mkdir -p "${STUB_BIN}"

  printf '#!/usr/bin/env bash\n"$@"\n' > "${STUB_BIN}/sudo"
  chmod +x "${STUB_BIN}/sudo"

  printf '#!/usr/bin/env bash\necho "42"\n' > "${STUB_BIN}/random_number.sh"
  chmod +x "${STUB_BIN}/random_number.sh"

  export PATH="${STUB_BIN}:${PATH}"

  mkdir -p "${TEST_DIR}/project"
  touch "${TEST_DIR}/project/a.sh"
  touch "${TEST_DIR}/project/b.sh"
  touch "${TEST_DIR}/project/c.rb"
}

teardown() {
  rm -rf "${TEST_DIR}"
}

@test ".sh ファイルが出力に含まれる" {
  run bash "${SCRIPT}" "${TEST_DIR}/project" 1 < /dev/null

  assert_success
  assert_output --partial "a.sh"
  assert_output --partial "b.sh"
}

@test ".sh 以外のファイルは出力に含まれない" {
  run bash "${SCRIPT}" "${TEST_DIR}/project" 1 < /dev/null

  assert_success
  refute_output --partial "c.rb"
}

@test "存在しないパスを指定するとエラー終了し target_path is not exist が出る" {
  run bash "${SCRIPT}" "${TEST_DIR}/nonexistent" 1 < /dev/null

  assert_failure
  assert_output --partial "target_path is not exist"
}

@test "parallel_number=0 を指定するとエラー終了し parallel_number must be 1 or more が出る" {
  run bash "${SCRIPT}" "${TEST_DIR}/project" 0 < /dev/null

  assert_failure
  assert_output --partial "parallel_number must be 1 or more"
}

@test "parallel_number を省略すると 1 として扱われ 1: で始まる行が出る" {
  run bash "${SCRIPT}" "${TEST_DIR}/project" < /dev/null

  assert_success
  assert_output --partial "1: "
}
