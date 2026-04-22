#!/bin/bash
# 次の REQ 番号を標準出力に返す（欠番があっても「最大+1」）
# 使い方: bash scripts/next-req.sh
# 出力例: REQ-33

set -e

cd "$(git rev-parse --show-toplevel)"

if [ ! -f docs/requirements.md ]; then
  echo "Error: docs/requirements.md not found" >&2
  exit 1
fi

max=$(grep -oE "REQ-[0-9]+" docs/requirements.md | sed 's/REQ-//' | sort -n | tail -1)

if [ -z "$max" ]; then
  echo "REQ-1"
else
  echo "REQ-$((max + 1))"
fi
