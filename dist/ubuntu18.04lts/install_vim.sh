#! /bin/bash -eux

#sudo add-apt-repository ppa:jonathonf/vim
#sudo apt update
#sudo apt install -y vim-gtk

git clone https://github.com/vim/vim.git
cd vim
./configure --with-features=huge --enable-gui=gtk2 --enable-fail-if-missing
make
sudo make install
cd ..
rm -rf vim

