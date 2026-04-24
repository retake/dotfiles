#!/bin/bash
# 次の REQ 番号を標準出力に返す（欠番があっても「最大+1」）
#
# 使い方:
#   bash scripts/next-req.sh
#   REQUIREMENTS_FILE=docs/reqs.md bash scripts/next-req.sh
#
# 出力例: REQ-33
#
# 環境変数:
#   REQUIREMENTS_FILE  要件ファイルのパス（デフォルト: docs/requirements.md）
#
# @util

set -e

cd "$(git rev-parse --show-toplevel)"

REQUIREMENTS_FILE="${REQUIREMENTS_FILE:-docs/requirements.md}"

if [ ! -f "$REQUIREMENTS_FILE" ]; then
  echo "Error: $REQUIREMENTS_FILE not found" >&2
  exit 1
fi

max=$(grep -oE "REQ-[0-9]+" "$REQUIREMENTS_FILE" | sed 's/REQ-//' | sort -n | tail -1)

if [ -z "$max" ]; then
  echo "REQ-1"
else
  echo "REQ-$((max + 1))"
fi
