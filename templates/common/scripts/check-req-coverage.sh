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
# テスト内の参照形式（いずれも有効、言語問わず）:
#   // @req REQ-42          (Dart / JS / Go)
#   # @req REQ-42           (Python / Ruby / Shell)
#   -- @req REQ-42          (SQL / Lua)
#   /* @req REQ-42 */       (C / CSS)
#   @req REQ-42             (プレフィックス不問でマッチ)
#
# 自動テストが存在しない既知のスコープ外 REQ はここに列挙する
# 例: SKIP_REQS="REQ-18 REQ-19"
SKIP_REQS=""

REQUIREMENTS="docs/requirements.md"
TEST_DIR="test"

if [ ! -f "$REQUIREMENTS" ]; then
  echo "❌ $REQUIREMENTS が見つかりません"
  exit 1
fi

# テーブル行（^| REQ-XX |）のみから REQ-ID を抽出（廃止済み注釈行を除く）
req_ids=$(grep -oE '^\| REQ-[0-9]+' "$REQUIREMENTS" | grep -oE 'REQ-[0-9]+' | sort -u)
total=$(echo "$req_ids" | wc -w)

uncovered=()
for req_id in $req_ids; do
  # SKIP_REQS に含まれていればスキップ
  if echo "$SKIP_REQS" | grep -qw "$req_id"; then
    continue
  fi

  # test/ 内に REQ-XX への言及が1件以上あるか確認（タグ形式問わず）
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
    desc=$(grep -oE "^\| ${req_id} \|[^|]+" "$REQUIREMENTS" | sed "s/^| ${req_id} | //")
    echo "  - ${req_id}: ${desc:0:70}"
  done
  echo ""
  echo "  移設リファクタ後は移設先テストに @req ${uncovered[0]} を追加してから削除元テストを消してください"
  exit 1
fi
