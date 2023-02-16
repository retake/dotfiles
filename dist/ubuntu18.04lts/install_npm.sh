#! /bin/bash -x

sudo apt update
sudo apt install nodejs npm yarn -y
sudo npm install -g n -y
sudo n stable -y
sudo apt purge nodejs npm -y
exec $SHELL -l

curl -fsSL https://deno.land/install.sh | sudo DENO_INSTALL=/usr/local sh
