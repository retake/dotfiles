#! /bin/bash

cd $(dirname $0)

sudo yum install epel-release
sudo yum install python-pip
sudo pip install pip --upgrade
pip install awscli --user

if [ ! -d ~/.vim ];then
  cp -rf ./.vim ~/.vim
fi

if [ ! -d ~/.rbenv ];then
  cp -rf ./.rbenv ~/.rbenv
fi
