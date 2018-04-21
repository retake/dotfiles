#! /bin/bash

cd $(dirname $0)

if [ ! -d ~/.vim ];then
  cp -rf ./.vim ~/.vim
fi

