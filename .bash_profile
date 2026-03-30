# .bash_profile

source ~/.bashrc

export MANPATH=${MANPATH}:/usr/local/share/man/ja

# starship プロンプト
eval "$(starship init bash)"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

set -a
source ~/.credentials
set +a

# terraformのパス
export PATH="$HOME/.tfenv/bin:$PATH"
