# .bash_profile

source ~/.bashrc

export MANPATH=${MANPATH}:/usr/local/share/man/ja
export PS1="\[\e[1;36m\][\W]\[\e[1;37m\]:\[\e[4;32m\](\$(parse_git_branch.sh))\[\e[0;37m\]\\$ "

export PATH="$HOME/.local/bin:$HOME/.rbenv/bin:$HOME/bin:$PATH"
eval "$(rbenv init -)"
