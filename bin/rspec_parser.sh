#!/usr/bin/env bash
set -euo pipefail

# 引数に指定されたrspecの項目を抜き出す
# 解析は雑なので、結果を信じすぎないこと

sed -e "s/ do$//g" "$1" \
  | grep --color=auto -E \
    -e " +describe" \
    -e " +context" \
    -e " +scenario" \
    -e " +it" \
    -e " +example" \
    -e "^ *?feature"
