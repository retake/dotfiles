# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias dimages="docker images"
alias dps="docker ps --all"
alias drun="docker run"
alias drm="docker rm"
alias drmi="docker rmi"
alias gadd="git add"
alias gst="git status"
alias gcom="git commit"
alias glog="git log"
alias gbr="git branch --all"
alias gf="git fetch"
alias gpu="git pull"
alias lsa="ls -la"
alias psa="ps -ef"
alias wca="wc -l"
alias dcom="docker-compose"
alias ls="ls -lah --color"
alias dkia="docker ps --all | awk '{print $1}' | xargs docker kill > /dev/null 2>&1"
alias drma="docker ps --all | awk '{print $1}' | xargs docker rm > /dev/null 2>&1"
alias less="less -RMN"
alias glogone='git log --pretty=oneline'
alias grebase='git rebase'

export RBENV_ROOT="${HOME}/.rbenv"
if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi

cd ~
