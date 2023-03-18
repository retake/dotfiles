#! /bin/bash -ex

cd $(dirname $0)

# 必要なファイルのリンクを作成
for file in .??*
do
  [ "${file}" = ".git" ] && continue
  [ "${file}" = ".github" ] && continue
  [ "${file}" = ".rbenv" ] && continue

  ln -snfv $(pwd)/${file} ~/${file}
done

# 必要なディレクトリのリンクを作成
ln -snfv $(pwd)/.vim ~/.vim

if [ ! -d ~/bin ];then
  mkdir ~/bin
fi

cd bin
for script in ?*.sh
do
  ln -snfv $(pwd)/${script} ~/bin/${script}
done

