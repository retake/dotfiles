# .bash_profile

source ~/.bashrc

export MANPATH=${MANPATH}:/usr/local/share/man/ja
export PS1="\[\e[1;36m\][\W]\[\e[1;37m\]:\[\e[4;32m\](\$(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'))\[\e[0;37m\]\\$ "

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

set -a
source ~/.credentials
set +a

# terraformのパス
export PATH="$HOME/.tfenv/bin:$PATH"
