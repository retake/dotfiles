#! /bin/bash -x

# 関連インストール
sudo apt update
sudo apt install unzip -y

# 展開とインストール
AWS_CLI_WORK_DIR="aws_work"
mkdir $AWS_CLI_WORK_DIR
cd $AWS_CLI_WORK_DIR
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
cd ../
sudo rm -rf $AWS_CLI_WORK_DIR
