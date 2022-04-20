#! /bin/bash -x

sudo apt update

./install_tools.sh
./install_github_cli.sh
./install_rbenv.sh
./install_awscli.sh
./install_npm.sh
./install_vim.sh
../linux/install_markdown_parser.sh

