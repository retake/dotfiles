#!/bin/bash
# golden 画像を更新するスクリプト
#
# 使い方:
#   bash scripts/update-goldens.sh              # 全 golden 更新（既定パス使用）
#   bash scripts/update-goldens.sh <path>       # 指定パスのみ更新
#   GOLDEN_DIR=test/ui/goldens/ bash scripts/update-goldens.sh   # 環境変数で既定パスを変更
#
# 動作:
#   1. 既存の failures/ を掃除（古い diff が残ると混乱するため）
#   2. flutter test --update-goldens を実行
#   3. 更新後の差分を git diff --stat で表示
#
# 環境変数:
#   GOLDEN_DIR  第1引数未指定時の既定ターゲットパス（デフォルト: test/presentation/goldens/）
#
# 注意:
#   - 環境依存（フォント・レンダリング）で意図せず更新が混ざることがあるため、
#     更新後は git diff で目視確認してからコミットすること
#   - WSL2 arm64 で生成した golden は他環境と差が出る可能性がある
#
# @util

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

DEFAULT_GOLDEN_DIR="${GOLDEN_DIR:-test/presentation/goldens/}"
TARGET="${1:-$DEFAULT_GOLDEN_DIR}"
FAILURES_DIR="${TARGET%/}/failures"

if [ ! -e "$TARGET" ]; then
  echo "Error: $TARGET not found" >&2
  exit 1
fi

echo "==> Cleaning $FAILURES_DIR"
if [ -d "$FAILURES_DIR" ]; then
  rm -rf "$FAILURES_DIR"
fi

echo "==> Running flutter test --update-goldens on $TARGET"
flutter test --update-goldens "$TARGET"

echo ""
echo "==> Updated golden diff summary"
git diff --stat -- "${TARGET%/}/goldens/*.png" || true

echo ""
echo "Done. Review the diff visually before committing:"
echo "  git diff -- ${TARGET%/}/goldens/"
