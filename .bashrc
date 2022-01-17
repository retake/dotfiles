# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias lsa="ls -la"
alias psa="ps -ef"
alias wca="wc -l"
alias ls="ls -lah --color"
alias less="less -RMN"

if docker --version > /dev/null 2>&1; then
  alias dimages="docker images"
  alias dps="docker ps --all"
  alias drun="docker run"
  alias drm="docker rm"
  alias drmi="docker rmi"
  alias dkia="docker ps --all | awk '{print $1}' | xargs docker kill > /dev/null 2>&1"
  alias drma="docker ps --all | awk '{print $1}' | xargs docker rm > /dev/null 2>&1"
  alias dcom="docker compose"
fi


if git --version > /dev/null 2>&1; then
  alias gadd="git add"
  alias gst="git status"
  alias gcom="git commit"
  alias glog="git log"
  alias gbr="git branch --all"
  alias gf="git fetch"
  alias gpu="git pull"
  alias glogone='git log --pretty=oneline'
  alias grebase='git rebase'
fi

if gh --version > /dev/null 2>&1; then
  eval "$(gh completion -s bash)"
  alias prs='gh pr status'
  alias iss='gh issue status'
fi

if ~/.rbenv/bin/rbenv --version > /dev/null 2>&1; then
  export PATH="~/.rbenv/bin:${PATH}"
  eval "$(rbenv init -)"
fi

cd ~
