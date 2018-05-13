#!/bin/bash -x

usage_message="Usage: $0 [-v] [-t|--true] [-f|--false] [-i|--input input_value] [pfile_ath]"
flg=false
value_input=''
file_path=''

# TODO 現状では同じオプション/pathが指定された場合、後勝ちになる。エラーを出す形に変更しても良い
# 概要
# 引数がある場合、全部の引数に対して順次解析を行っている。
if [ $# -eq 0 ];then  echo $usage_message; return 1; fi
while [ $# -gt 0 ];do
  case $1 in
    '-v' )
      echo $usage_message
      return 1;;
    '--true' | '-t' )
      flg=true ;;
    '--false' | '-f' )
      flg=false ;;
    '--input' | '-i' )
      value_input=$2
      shift ;;
    * )
      file_path=$1 ;;
  esac
  shift
done


echo "flg: $flg"
echo "input: $value_input"
echo "path: $file_path"

