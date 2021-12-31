#! /bin/bash

cd $(dirname $0)

for file in .??*
do
  if [ "${file}" = ".vim" ];then
    ln -nsvf git/dotfiles/.vim ~
    continue
  fi

  ln -snfv $(pwd)/${file} ~/${file}
done

if [ ! -d ~/bin ];then
  mkdir ~/bin
fi

cd bin
for script in ?*.sh
do
  ln -snfv $(pwd)/${script} ~/bin/${script}
done
