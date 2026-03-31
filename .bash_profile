# .bash_profile

source ~/.bashrc

export MANPATH=${MANPATH}:/usr/local/share/man/ja

# starship プロンプト
eval "$(starship init bash)"

set -a
source ~/.credentials
set +a
