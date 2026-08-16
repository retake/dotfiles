#!/usr/bin/env bash
# xtrace（-x）は使わない。下の sed は secret を展開した状態でコマンドラインに載るため、
# トレースを有効にすると Todoist トークン・Google OAuth シークレットが端末・ログ・
# エージェントのトランスクリプトへ平文で出る（2026-08-16 に実際に発生）。
# 進捗は ln -v と echo で十分に見える。claude/scripts/setup-mcp.sh も同じ方針。
set -euo pipefail

# Claude Code 開発環境のセットアップ
# 基本dotfiles（setup.sh）とは独立して実行できる

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

create_symlink() {
  local source_path=$1
  local target_path=$2
  ln -snfv "${source_path}" "${target_path}"
}

create_directory_if_not_exists() {
  local dir_path=$1
  if [ ! -d "${dir_path}" ]; then
    mkdir -p "${dir_path}"
  fi
}

create_directory_if_not_exists "${HOME}/.claude"

create_directory_if_not_exists "${HOME}/.claude/scripts"

create_symlink "${DOTFILES_DIR}/claude/scripts/notify.sh" "${HOME}/.claude/scripts/notify.sh"
create_symlink "${DOTFILES_DIR}/claude/scripts/worktree-check.sh" "${HOME}/.claude/scripts/worktree-check.sh"
create_symlink "${DOTFILES_DIR}/claude/CLAUDE.md"       "${HOME}/.claude/CLAUDE.md"

# dev/ 配下の共通CLAUDE.md（全プロジェクト共通の開発スタイル・Codex連携設定）
create_directory_if_not_exists "${HOME}/dev"
create_symlink "${DOTFILES_DIR}/claude/dev-CLAUDE.md"  "${HOME}/dev/CLAUDE.md"
# skills/agents/docs はディレクトリシンボリンクにしない。
# ディレクトリ丸ごとリンクすると ~/.claude/ 側への書き込みが
# dotfiles の実体を破壊するリスクがある（循環シンボリンク事故の再発防止）。
# サブディレクトリを作り、中のファイルを個別にリンクする。
link_directory_contents() {
  local src_dir=$1
  local dst_dir=$2
  # 既存のディレクトリシンボリンクがあれば除去（移行用）
  [ -L "${dst_dir}" ] && rm -f "${dst_dir}"
  create_directory_if_not_exists "${dst_dir}"
  for child in "${src_dir}"/*/; do
    [ -d "$child" ] || continue
    local name
    name=$(basename "$child")
    create_directory_if_not_exists "${dst_dir}/${name}"
    for file in "$child"*; do
      [ -f "$file" ] || continue
      create_symlink "$file" "${dst_dir}/${name}/$(basename "$file")"
    done
  done
  # ディレクトリ直下のファイル（サブディレクトリを持たないケース）
  for file in "${src_dir}"/*; do
    [ -f "$file" ] || continue
    create_symlink "$file" "${dst_dir}/$(basename "$file")"
  done
}

# Claude Code は親ディレクトリの .claude/skills/ を探索しないため、
# dev-skills も ~/.claude/skills/ にリンクする（dotfiles 上の論理分離は維持）。
link_directory_contents "${DOTFILES_DIR}/claude/skills"     "${HOME}/.claude/skills"
link_directory_contents "${DOTFILES_DIR}/claude/dev-skills" "${HOME}/.claude/skills"
link_directory_contents "${DOTFILES_DIR}/claude/agents" "${HOME}/.claude/agents"
link_directory_contents "${DOTFILES_DIR}/claude/commands" "${HOME}/.claude/commands"
link_directory_contents "${DOTFILES_DIR}/claude/docs"   "${HOME}/.claude/docs"
create_symlink "${DOTFILES_DIR}/claude/keybindings.json" "${HOME}/.claude/keybindings.json"
create_symlink "${DOTFILES_DIR}/retrospectives"         "${HOME}/retrospectives"

# MCP 用の機密値を .mcp.env から取り込む（あれば）。形式: KEY=value
MCP_ENV_FILE="${DOTFILES_DIR}/claude/.mcp.env"
if [ -f "${MCP_ENV_FILE}" ]; then
  set -a
  # shellcheck disable=SC1090
  . "${MCP_ENV_FILE}"
  set +a
else
  echo "WARNING: ${MCP_ENV_FILE} が見つかりません。MCP のトークンが未展開のまま設定が生成されます。" >&2
fi

# settings.jsonはテンプレートからホームディレクトリを展開して実ファイルとして生成する
# （シンボリックリンクにするとパスがハードコードされたまま別マシンで機能しないため）
[ -L "${HOME}/.claude/settings.json" ] && rm -f "${HOME}/.claude/settings.json"
sed \
  -e "s|__HOME__|${HOME}|g" \
  -e "s|__TODOIST_API_TOKEN__|${TODOIST_API_TOKEN:-}|g" \
  -e "s|__GOOGLE_OAUTH_CLIENT_ID__|${GOOGLE_OAUTH_CLIENT_ID:-}|g" \
  -e "s|__GOOGLE_OAUTH_CLIENT_SECRET__|${GOOGLE_OAUTH_CLIENT_SECRET:-}|g" \
  -e "s|__GITHUB_TOKEN__|${GITHUB_TOKEN:-}|g" \
  "${DOTFILES_DIR}/claude/settings.template.json" > "${HOME}/.claude/settings.json"
echo "Generated: ${HOME}/.claude/settings.json (HOME=${HOME})"

# 未置換プレースホルダーの警告
if grep -q '__[A-Z_]*__' "${HOME}/.claude/settings.json"; then
  echo "WARNING: settings.json に未設定のプレースホルダーが残っています:" >&2
  grep -o '__[A-Z_]*__' "${HOME}/.claude/settings.json" | sort -u >&2
fi

# プロジェクト横断 MCP 設定 (~/.mcp.json) を生成
if [ -f "${MCP_ENV_FILE}" ] && [ -x "${DOTFILES_DIR}/claude/scripts/setup-mcp.sh" ]; then
  "${DOTFILES_DIR}/claude/scripts/setup-mcp.sh"
fi
