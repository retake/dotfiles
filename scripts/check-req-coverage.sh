#!/bin/bash
# check-req-coverage.sh: requirements.md の全 REQ-ID にテストが存在するか確認する
#
# 使い方:
#   bash scripts/check-req-coverage.sh
#
# 終了コード:
#   0 = 全 REQ がいずれかのテストで参照されている
#   1 = 1件以上の REQ がテストで参照されていない
#
# テスト内の参照形式（いずれも有効）:
#   // @req REQ-42
#   // @req REQ-26, REQ-27
#   // シナリオ11: 設定変更（REQ-7, REQ-8）
#
# 環境変数:
#   REQUIREMENTS_FILE  要件ファイルのパス（デフォルト: docs/requirements.md）
#   TEST_DIR           テストディレクトリのパス（デフォルト: test/）
#
# スキップ設定:
#   プロジェクト直下の .reqcoverageignore ファイルに 1 行 1 REQ-ID を記載する。
#   # で始まる行はコメントとして無視される。空行は無視される。
#   例:
#     # Web プラットフォーム（Linux 自動テスト外）
#     REQ-18
#     REQ-19
#
# @util

set -e

cd "$(git rev-parse --show-toplevel)"

REQUIREMENTS_FILE="${REQUIREMENTS_FILE:-docs/requirements.md}"
TEST_DIR="${TEST_DIR:-test}"

if [ ! -f "$REQUIREMENTS_FILE" ]; then
  echo "❌ $REQUIREMENTS_FILE が見つかりません"
  exit 1
fi

# .reqcoverageignore から SKIP_REQS を読み込む（コメント・空行は除外）
SKIP_REQS=""
if [ -f ".reqcoverageignore" ]; then
  while IFS= read -r line; do
    # 空行・コメント行をスキップ
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    # REQ-<数字> 形式の行のみ受け付ける
    if [[ "$line" =~ ^[[:space:]]*(REQ-[0-9]+)[[:space:]]*$ ]]; then
      req_id="${BASH_REMATCH[1]}"
      SKIP_REQS="$SKIP_REQS $req_id"
    else
      echo "Warning: .reqcoverageignore の不正な行を無視します: $line" >&2
    fi
  done < ".reqcoverageignore"
fi

# テーブル行（^| REQ-XX |）のみから REQ-ID を抽出（廃止済み注釈行を除く）
req_ids=$(grep -oE '^\| REQ-[0-9]+' "$REQUIREMENTS_FILE" | grep -oE 'REQ-[0-9]+' | sort -u)
total=$(echo "$req_ids" | grep -c 'REQ-' || true)

if [ "$total" -eq 0 ]; then
  echo "✓ REQ カバレッジ: 要件が 0 件のため確認をスキップします"
  exit 0
fi

uncovered=()
for req_id in $req_ids; do
  # SKIP_REQS に含まれていればスキップ
  if echo "$SKIP_REQS" | grep -qw "$req_id"; then
    continue
  fi

  # TEST_DIR 内に REQ-XX への言及が1件以上あるか確認（タグ形式問わず）
  if ! grep -rq "\b${req_id}\b" "$TEST_DIR" 2>/dev/null; then
    uncovered+=("$req_id")
  fi
done

if [ ${#uncovered[@]} -eq 0 ]; then
  echo "✓ REQ カバレッジ: 全 ${total} 件がテストで参照されています"
  exit 0
else
  echo "❌ テストで参照されていない REQ-ID: ${#uncovered[@]} / ${total} 件"
  for req_id in "${uncovered[@]}"; do
    desc=$(grep -oE "^\| ${req_id} \|[^|]+" "$REQUIREMENTS_FILE" | sed "s/^| ${req_id} | //")
    echo "  - ${req_id}: ${desc:0:70}"
  done
  echo ""
  echo "  移設リファクタ後は移設先テストに // @req ${uncovered[0]} を追加してから削除元テストを消してください"
  exit 1
fi
