#!/usr/bin/env bash
# パイプの前後（stdin/stdout）を検出するサンプルスクリプト
set -euo pipefail

if [ -p /dev/stdin ]; then
  echo "after_pipe!"
  cat -
fi

if [ -p /dev/stdout ]; then
  echo "before_pipe!"
fi

