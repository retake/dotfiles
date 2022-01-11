#! /bin/bash -x

# radeon系CPUを使っている場合は別の仕組みが必要

wget https://github.com/MichaelMure/mdr/releases/download/v0.2.5/mdr_linux_386
chmod 755 mdr_linux_386
mv mdr_linux_386 ~/bin/mdr

