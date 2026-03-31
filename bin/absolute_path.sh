#!/usr/bin/env bash
set -euo pipefail

if [ -p /dev/stdin ]; then
  relative_path=$(cat -)
else
  relative_path=${1:-}
fi
export relative_path
if [ -e "${relative_path}" ];then
  if [ -d "${relative_path}" ]; then
    echo "$(cd "${relative_path}";pwd)"
  else
    if [ -f "${relative_path}" ]; then
      dir_path=$(dirname "${relative_path}")
      absolute_dir_path=$(cd "${dir_path}";pwd)
      echo "${absolute_dir_path}/$(basename "${relative_path}")"
    else
      exit 1
    fi
  fi
fi


