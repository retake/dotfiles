# 新規プロジェクトセットアップ手順

dotfiles の汎用スクリプト・テンプレートを新規プロジェクトに配置するための手順書。

---

## Flutter プロジェクト

### 1. scripts/ の配置

```bash
# プロジェクトルートで実行
mkdir -p scripts/git-hooks

cp ~/dotfiles/templates/flutter/scripts/update-goldens.sh scripts/
cp ~/dotfiles/templates/flutter/scripts/git-hooks/pre-commit scripts/git-hooks/
cp ~/dotfiles/scripts/next-req.sh scripts/
cp ~/dotfiles/scripts/check-req-coverage.sh scripts/
```

### 2. 実行権限の付与

```bash
chmod +x scripts/update-goldens.sh
chmod +x scripts/git-hooks/pre-commit
chmod +x scripts/next-req.sh
chmod +x scripts/check-req-coverage.sh
```

### 3. git hook の有効化

```bash
git config core.hooksPath scripts/git-hooks
```

### 4. .reqcoverageignore の作成（必要な場合）

自動テストが存在しない REQ（Web プラットフォーム専用・superseded 等）がある場合は `.reqcoverageignore` を作成する。

```bash
# プロジェクトルート直下に作成
cat > .reqcoverageignore << 'EOF'
# Web プラットフォーム（Linux 自動テスト外）
REQ-18
REQ-19
REQ-20

# superseded（後続 REQ に置き換えられた廃止済み要件）
REQ-22
REQ-23
EOF
```

書き方のルール:
- 1 行 1 REQ-ID（`REQ-<数字>` 形式）
- `#` で始まる行はコメント（なぜスキップするかを残す）
- 空行は無視される

### 5. CLAUDE.md への記載例

プロジェクトの CLAUDE.md に以下を追記してスクリプトの存在を記録する:

```markdown
## 主要コマンド

# 次の REQ 番号を取得
bash scripts/next-req.sh

# テスト REQ カバレッジ確認
bash scripts/check-req-coverage.sh

# golden 画像を更新
bash scripts/update-goldens.sh

## 初回セットアップ

pre-commit hook を有効化する:
git config core.hooksPath scripts/git-hooks
```

---

## 汎用プロジェクト（Rails / Node / Go 等）

Flutter 固有スクリプト（`update-goldens.sh`・`pre-commit`）は不要。汎用スクリプト 2 本のみ配置する。

### 1. scripts/ の配置

```bash
mkdir -p scripts

cp ~/dotfiles/scripts/next-req.sh scripts/
cp ~/dotfiles/scripts/check-req-coverage.sh scripts/
chmod +x scripts/next-req.sh scripts/check-req-coverage.sh
```

### 2. 環境変数によるカスタマイズ

デフォルトから変更が必要な場合は環境変数で上書きする:

| 環境変数 | デフォルト | 変更例 |
|---|---|---|
| `REQUIREMENTS_FILE` | `docs/requirements.md` | `docs/reqs.md` |
| `TEST_DIR` | `test/` | `spec/` (Rails), `__tests__/` (Node) |

使用例:

```bash
# Rails プロジェクトでの REQ カバレッジ確認
TEST_DIR=spec bash scripts/check-req-coverage.sh

# 要件ファイルのパスを変更
REQUIREMENTS_FILE=docs/reqs.md bash scripts/next-req.sh
```

### 3. .reqcoverageignore の作成（必要な場合）

Flutter プロジェクトと同じ手順で作成する（上記「4. .reqcoverageignore の作成」を参照）。

---

## 検証手順

配置後のセルフチェック。`mktemp -d` で一時ディレクトリを作って実行することで実プロジェクトを汚染しない。

### next-req.sh の動作検証

```bash
# 一時 git repo を作成して動作確認
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git init -q

# 最小限の requirements.md を作成
mkdir -p docs
cat > docs/requirements.md << 'EOF'
| REQ-1 | 要件1 |
| REQ-3 | 要件3 |
EOF

# REQ-4 が返るか確認
result=$(bash ~/dotfiles/scripts/next-req.sh)
[ "$result" = "REQ-4" ] && echo "✓ next-req.sh: REQ-4 OK" || echo "❌ next-req.sh: 期待 REQ-4、実際 $result"

# REQ が無い場合は REQ-1 が返るか確認
echo "" > docs/requirements.md
result=$(bash ~/dotfiles/scripts/next-req.sh)
[ "$result" = "REQ-1" ] && echo "✓ next-req.sh: 初回 REQ-1 OK" || echo "❌ next-req.sh: 期待 REQ-1、実際 $result"

# ファイルが無い場合は exit 1 か確認
rm docs/requirements.md
bash ~/dotfiles/scripts/next-req.sh 2>/dev/null; [ $? -eq 1 ] && echo "✓ next-req.sh: ファイルなし exit 1 OK" || echo "❌ next-req.sh: exit 1 を返さなかった"

cd - && rm -rf "$TMPDIR"
```

### check-req-coverage.sh の動作検証

```bash
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
git init -q

# 最小限の requirements.md とテストファイルを作成
mkdir -p docs test
cat > docs/requirements.md << 'EOF'
| REQ-1 | 要件1 |
| REQ-2 | 要件2 |
EOF
echo '// @req REQ-1' > test/sample_test.dart
echo '// @req REQ-2' >> test/sample_test.dart

# 全件網羅 → exit 0 確認
bash ~/dotfiles/scripts/check-req-coverage.sh && echo "✓ 全件網羅 exit 0 OK" || echo "❌ 全件網羅で exit 1"

# REQ-2 を削除 → exit 1 確認
echo '// @req REQ-1' > test/sample_test.dart
bash ~/dotfiles/scripts/check-req-coverage.sh; [ $? -eq 1 ] && echo "✓ 未網羅 exit 1 OK" || echo "❌ 未網羅で exit 0"

# .reqcoverageignore で REQ-2 を skip → exit 0 確認
echo 'REQ-2' > .reqcoverageignore
bash ~/dotfiles/scripts/check-req-coverage.sh && echo "✓ ignore 適用 exit 0 OK" || echo "❌ ignore 適用で exit 1"

# コメント行が誤認されないか確認
echo '# REQ-99' >> .reqcoverageignore
bash ~/dotfiles/scripts/check-req-coverage.sh && echo "✓ コメント行無視 OK" || echo "❌ コメント行が誤認された"

cd - && rm -rf "$TMPDIR"
```

### 配置確認（ファイル存在・実行権限）

```bash
test -x ~/dotfiles/scripts/next-req.sh && echo "✓ next-req.sh 実行権あり" || echo "❌ next-req.sh"
test -x ~/dotfiles/scripts/check-req-coverage.sh && echo "✓ check-req-coverage.sh 実行権あり" || echo "❌ check-req-coverage.sh"
test -x ~/dotfiles/templates/flutter/scripts/update-goldens.sh && echo "✓ update-goldens.sh 実行権あり" || echo "❌ update-goldens.sh"
test -x ~/dotfiles/templates/flutter/scripts/git-hooks/pre-commit && echo "✓ pre-commit 実行権あり" || echo "❌ pre-commit"
test -f ~/dotfiles/docs/new-project-setup.md && echo "✓ new-project-setup.md 存在" || echo "❌ new-project-setup.md"
```
