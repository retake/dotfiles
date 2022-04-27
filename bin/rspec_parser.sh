#! /bin/bash -e

# 引数に指定されたrspecの項目を抜き出す
# 解析は雑なので、結果を信じすぎないこと

cat $1 \
  | sed -e "s/ do$//g" \
  | grep --color=auto -E \
    -e " +describe" \
    -e " +context" \
    -e " +scenario" \
    -e " +it" \
    -e " +example" \
    -e "^ *?feature"
