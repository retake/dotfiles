#! /bin/bash -x

# 関連インストール
sudo apt update
sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev -y

# rbenvインストール
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
# install_env.shによって、`rbenv init -`が含まれたbashrcがあるはずなので、sourceを実行すればよい
source ~/.bashrc

# ruby-buildインストール
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
