#!/bin/bash -ex

create_symlink() {
  local src=$1
  local dest=$2
  ln -snfv "${src}" "${dest}"
}

cd $(dirname $0)

# 必要なファイルのリンクを作成
for file in .??*; do
  [ "${file}" = ".git" ] && continue
  [ "${file}" = ".github" ] && continue
  [ "${file}" = ".rbenv" ] && continue

  create_symlink $(pwd)/${file} ${HOME}/${file}
done

# 必要なディレクトリのリンクを作成
create_symlink $(pwd)/.vim ${HOME}/.vim

if [ ! -d ${HOME}/bin ]; then
  mkdir ${HOME}/bin
fi

cd bin

for script in ?*.sh; do
  create_symlink $(pwd)/${script} ${HOME}/bin/${script}
done

