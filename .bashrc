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
  alias glogone='git log --pretty=oneline --graph'
  alias grebase='git rebase'
fi

# --- Claude/Codex 同時セッション用 worktree ヘルパー ---
# cc-new <branch> [base]
#   現在のリポジトリを ../<repo>-<branch> に worktree として切り出して cd する。
#   base を省略すると origin の既定ブランチ、無ければ HEAD から分岐。
cc-new() {
  local branch="$1"
  local base="$2"
  if [ -z "$branch" ]; then
    echo "usage: cc-new <branch> [base]" >&2
    return 1
  fi
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not in a git repo" >&2; return 1; }
  local repo
  repo=$(basename "$root")
  local wt="${root%/*}/${repo}-${branch}"
  if [ -e "$wt" ]; then
    echo "already exists: $wt" >&2
    return 1
  fi
  if git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$root" worktree add "$wt" "$branch" || return 1
  else
    if [ -z "$base" ]; then
      base=$(git -C "$root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
      [ -z "$base" ] && base=HEAD
    fi
    git -C "$root" worktree add -b "$branch" "$wt" "$base" || return 1
  fi
  cd "$wt" || return 1
  echo "worktree: $wt (branch: $branch)"
}

# cc-ls: 現在のリポジトリの worktree 一覧
cc-ls() { git worktree list; }

# cc-rm <path>: worktree を削除（マージ済み前提）
cc-rm() {
  local wt="$1"
  if [ -z "$wt" ]; then
    echo "usage: cc-rm <worktree-path>" >&2
    return 1
  fi
  git worktree remove "$wt"
}
# --- /Claude worktree ヘルパー ---


if gh --version > /dev/null 2>&1; then
  eval "$(gh completion -s bash)"
  alias prs='gh pr status'
  alias iss='gh issue status'
fi

if "${HOME}/.rbenv/bin/rbenv" --version > /dev/null 2>&1; then
  export PATH="${HOME}/.rbenv/bin:${PATH}"
  eval "$(rbenv init -)"
fi


# --- PATH ---
export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
export PATH="${HOME}/.tfenv/bin:${PATH}"
export PATH="${PATH}:/usr/local/go/bin"
export PATH="${PATH}:${HOME}/go/bin"
# --- PATH ---

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=wslview
alias vim=nvim

export PATH="$HOME/dev/tools/flutter/bin:$PATH"
