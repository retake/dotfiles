#! /bin/bash -x

sudo apt update
sudo apt install nodejs npm yarn -y
sudo npm install -g n -y
sudo n stable -y
sudo apt purge nodejs npm -y
exec $SHELL -l
