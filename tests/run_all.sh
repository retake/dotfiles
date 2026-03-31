#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

"${SCRIPT_DIR}/bats/bin/bats" \
  "${SCRIPT_DIR}/unit/" \
  "${SCRIPT_DIR}/integration/"
