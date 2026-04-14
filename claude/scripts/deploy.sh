#!/usr/bin/env bash
# Claude Code 設定デプロイスクリプト
# Usage: ./deploy.sh
#
# dotfiles/claude/ の設定を各ディレクトリに展開する
# - グローバル設定 → ~/.claude/
# - ロール別設定 → ~/consulting/, ~/work/, ~/life/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_CLAUDE="${SCRIPT_DIR}/.."
ENV_FILE="${DOTFILES_CLAUDE}/.mcp.env"
HOME_DIR="$HOME"

# --- ユーティリティ ---

safe_link() {
  local src="$1"
  local dst="$2"
  local abs_src
  abs_src="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$abs_src")" ]; then
    return 0
  fi
  [ -e "$dst" ] && rm -f "$dst"
  ln -s "$abs_src" "$dst"
}

replace_placeholders() {
  local content="$1"
  # HOME パス置換
  content=$(echo "$content" | sed "s|__HOME__|${HOME_DIR}|g")
  # .mcp.env から変数置換
  if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
      [[ -z "$key" || "$key" =~ ^# ]] && continue
      value=$(echo "$value" | xargs)
      content=$(echo "$content" | sed "s|__${key}__|${value}|g")
    done < "$ENV_FILE"
  fi
  echo "$content"
}

deploy_file() {
  local src="$1"
  local dst="$2"
  local do_replace="${3:-false}"

  mkdir -p "$(dirname "$dst")"
  if [ "$do_replace" = "true" ]; then
    # テンプレート置換が必要なファイルは実体ファイルとして生成
    replace_placeholders "$(cat "$src")" > "$dst"
  else
    # それ以外はシンボリックリンク
    safe_link "$src" "$dst"
  fi
  echo "  deployed: $dst"
}

# --- 1. グローバル設定 ---

echo "=== グローバル設定 ==="
deploy_file "${DOTFILES_CLAUDE}/settings.template.json" "${HOME_DIR}/.claude/settings.json" true
deploy_file "${DOTFILES_CLAUDE}/CLAUDE.md" "${HOME_DIR}/.claude/CLAUDE.md"
deploy_file "${DOTFILES_CLAUDE}/keybindings.json" "${HOME_DIR}/.claude/keybindings.json"

# スクリプト
mkdir -p "${HOME_DIR}/.claude/scripts"
for f in "${DOTFILES_CLAUDE}/scripts/"*.sh; do
  [ -f "$f" ] || continue
  fname=$(basename "$f")
  [ "$fname" = "deploy.sh" ] && continue
  [ "$fname" = "setup-mcp.sh" ] && continue
  deploy_file "$f" "${HOME_DIR}/.claude/scripts/${fname}"
  chmod +x "${HOME_DIR}/.claude/scripts/${fname}"
done

# スキル（グローバル = 開発用スキル）
if [ -d "${DOTFILES_CLAUDE}/skills" ]; then
  for skill_dir in "${DOTFILES_CLAUDE}/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    mkdir -p "${HOME_DIR}/.claude/skills/${skill_name}"
    for f in "${skill_dir}"*; do
      [ -f "$f" ] || continue
      safe_link "$f" "${HOME_DIR}/.claude/skills/${skill_name}/$(basename "$f")"
    done
    echo "  deployed skill: ${skill_name}"
  done
fi

# エージェント
if [ -d "${DOTFILES_CLAUDE}/agents" ]; then
  mkdir -p "${HOME_DIR}/.claude/agents"
  for f in "${DOTFILES_CLAUDE}/agents/"*; do
    [ -f "$f" ] || continue
    safe_link "$f" "${HOME_DIR}/.claude/agents/$(basename "$f")"
  done
  echo "  deployed agents"
fi

# --- 2. ロール別設定 ---

for role in consulting work life; do
  role_dir="${DOTFILES_CLAUDE}/roles/${role}"
  target_dir="${HOME_DIR}/${role}"

  [ -d "$role_dir" ] || continue

  echo "=== ${role} ==="
  mkdir -p "${target_dir}/.claude"

  # CLAUDE.md（プロジェクトルートに配置）
  if [ -f "${role_dir}/CLAUDE.md" ]; then
    deploy_file "${role_dir}/CLAUDE.md" "${target_dir}/CLAUDE.md"
  fi

  # settings.json（.claude/ 配下に配置）
  if [ -f "${role_dir}/settings.json" ]; then
    deploy_file "${role_dir}/settings.json" "${target_dir}/.claude/settings.json"
  fi

  # ロール別コマンド
  if [ -d "${role_dir}/commands" ] && [ "$(ls -A "${role_dir}/commands" 2>/dev/null)" ]; then
    mkdir -p "${target_dir}/.claude/commands"
    for f in "${role_dir}/commands/"*; do
      [ -f "$f" ] || continue
      safe_link "$f" "${target_dir}/.claude/commands/$(basename "$f")"
    done
    echo "  deployed commands for ${role}"
  fi

  # ロール別スキル
  if [ -d "${role_dir}/skills" ] && [ "$(ls -A "${role_dir}/skills" 2>/dev/null)" ]; then
    for skill_dir in "${role_dir}/skills/"*/; do
      [ -d "$skill_dir" ] || continue
      skill_name=$(basename "$skill_dir")
      mkdir -p "${target_dir}/.claude/skills/${skill_name}"
      for f in "${skill_dir}"*; do
        [ -f "$f" ] || continue
        ln -sf "$(cd "$(dirname "$f")" && pwd)/$(basename "$f")" "${target_dir}/.claude/skills/${skill_name}/$(basename "$f")"
      done
      echo "  deployed skill: ${skill_name} for ${role}"
    done
  fi
done

# --- 3. グローバルコマンド ---

echo "=== グローバルコマンド ==="
mkdir -p "${HOME_DIR}/.claude/commands"

if [ -d "${DOTFILES_CLAUDE}/commands" ] && [ "$(ls -A "${DOTFILES_CLAUDE}/commands" 2>/dev/null)" ]; then
  for f in "${DOTFILES_CLAUDE}/commands/"*; do
    [ -f "$f" ] || continue
    safe_link "$f" "${HOME_DIR}/.claude/commands/$(basename "$f")"
  done
  echo "  deployed global commands"
fi

echo ""
echo "=== デプロイ完了 ==="
echo "使い方:"
echo "  cd ~/consulting && claude  # 診断士モード"
echo "  cd ~/work && claude        # 開発モード"
echo "  cd ~/life && claude        # 生活管理モード"
