#!/usr/bin/env bash
# mcp.template.json + .mcp.env → ~/.mcp.json を生成するスクリプト
# Usage: ./setup-mcp.sh
#
# .mcp.env の形式:
#   TODOIST_API_TOKEN=xxxxx
#   GOOGLE_OAUTH_CLIENT_ID=xxxxx
#   GOOGLE_OAUTH_CLIENT_SECRET=xxxxx
#   GITHUB_TOKEN=xxxxx

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/../mcp.template.json"
ENV_FILE="${SCRIPT_DIR}/../.mcp.env"
OUTPUT="${HOME}/.mcp.json"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: テンプレートが見つかりません: $TEMPLATE" >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: 環境変数ファイルが見つかりません: $ENV_FILE" >&2
  echo "  ${ENV_FILE} を作成してください。例:" >&2
  echo "    TODOIST_API_TOKEN=your_token_here" >&2
  echo "    GOOGLE_OAUTH_CLIENT_ID=your_client_id_here" >&2
  echo "    GOOGLE_OAUTH_CLIENT_SECRET=your_secret_here" >&2
  echo "    GITHUB_TOKEN=your_github_token_here" >&2
  exit 1
fi

result=$(cat "$TEMPLATE")

while IFS='=' read -r key value; do
  # 空行・コメント行をスキップ
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  # 値の前後の空白を除去
  value=$(echo "$value" | xargs)
  result=$(echo "$result" | sed "s|__${key}__|${value}|g")
done < "$ENV_FILE"

# 未置換のプレースホルダーがないかチェック
if echo "$result" | grep -q '__.*__'; then
  echo "WARNING: 未設定のプレースホルダーがあります:" >&2
  echo "$result" | grep -o '__[A-Z_]*__' | sort -u >&2
fi

echo "$result" > "$OUTPUT"
chmod 600 "$OUTPUT"
echo "Generated: $OUTPUT"
