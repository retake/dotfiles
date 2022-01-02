#! /bin/bash -x

cd $(dirname $0)

for file in .??*
do
  [ "${file}" = ".git" ] && continue
  [ "${file}" = ".rbenv" ] && continue

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

source ~/.bash_profile

