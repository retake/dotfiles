#! /bin/bash -x

sudo apt update
sudo apt install jq silversearcher-ag -y

sudo apt install -y \
    gcc make \
    pkg-config autoconf automake \
    python3-docutils \
    libseccomp-dev \
    libjansson-dev \
    libyaml-dev \
    libxml2-dev

git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure --prefix=/usr/local # defaults to /usr/local
make
sudo make install # may require extra privileges depending on where to install
