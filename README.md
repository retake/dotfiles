# dotfiles

git clone git@github.com:retake/dotfiles.git<br>
cd dotfiles<br>
sh install.sh<br>

注意点
deinの最新版が vimの8以上にしか対応しておらず、 yumやaptで7系だと動かない。
現時点（2019-08-05）だと、centos7は7.4なので、deinのバージョンを、1.5にすれば動かせる。
一度vimを起動し、deinをインストールした後に、以下を実行

git clone https://github.com/vim/vim.git
cd .cache/dein/repos/github.com/Shougo/dein.vim/
git checkout -b 1.5 refs/tags/1.5


vim の fuzzy finder（ctrlp）は、agと連携させているので、使いたければインストールが必要

sudo apt install silversearcher-ag
