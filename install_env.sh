#! /bin/bash

cd $(dirname $0)

for file in .??*
do
  [ "${file}" = ".git" ] && continue
  [ "${file}" = ".vim" ] && continue

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
