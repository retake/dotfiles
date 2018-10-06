#! /bin/bash

cd $(dirname $0)

if [ ! -d ~/.vim ];then
  cp -rf ./.vim ~/.vim
fi

if [ ! -d ~/.rbenv ];then
  cp -rf ./.rbenv ~/.rbenv
fi
