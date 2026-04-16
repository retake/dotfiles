---
name: sync
description: コードとドキュメント（requirements.md・design-summary.md・traceability.md）の乖離を検出し、更新を提案する軽量スキル。orchestrateを通さない小規模修正の後に実行する。
user-invocable: true
argument-hint: 対象ディレクトリ（省略時はカレントディレクトリ）
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(ls*)
  - Bash(find*)
  - Bash(git diff*)
  - Bash(git log*)
  - Bash(pwd)
---

# Sync — コード↔ドキュメント同期チェック

orchestrateを通さずに行った修正が、ドキュメントに反映されているかを検出し、更新を提案する。

## 実行手順

### 1. 変更の検出

以下の順で最近の変更を把握する：

1. `git diff HEAD~5 --name-only` で直近の変更ファイルを取得する（件数は状況に応じて調整）
2. `src/` 配下の変更があるか確認する
3. 変更がない場合は「同期不要です」と表示して終了する

### 2. ドキュメントの存在確認

以下のファイルが存在するか確認する（存在しないものはスキップ）：
- `docs/requirements.md`
- `docs/current-architecture.md`
- `docs/design-summary.md`
- `docs/traceability.md`

いずれも存在しない場合は「ドキュメントが見つかりません。orchestrateで初回実行してください」と表示して終了する。

### 3. 乖離の検出

**requirements.md との乖離：**
- `src/` または `lib/` 内の `@req REQ-x.x` コメントを収集する
- requirements.mdの要件IDリストと照合する
- requirements.mdにないREQ-x.xがコードに存在する → 「要件追加の可能性」
- requirements.mdにあるREQ-x.xがコードに存在しない → 「要件削除または未実装の可能性」

**current-architecture.md / design-summary.md との乖離：**
- まず `docs/current-architecture.md` を読み、レイヤー構成・主要モジュール一覧と実際の `lib/` を照合する
- current-architecture.md に記載がないモジュールが `lib/` に存在する → 「current-architecture.md への追記が必要」
- current-architecture.md に記載があるモジュールが `lib/` に存在しない → 「current-architecture.md の更新が必要」
- **`docs/design-summary.md` は丸読みしない。** current-architecture.md との乖離が見つかった場合のみ、design-summary.md の該当セクションを行番号指定で参照する

**traceability.md との乖離：**
- traceability.mdが存在する場合、最終更新日と最新のsrc/変更日を比較する
- src/の方が新しければ → 「traceability.mdの更新が必要」

### 4. 結果の出力

```
[SYNC] ドキュメント同期チェック結果

## requirements.md
- 乖離なし / 乖離あり
  （乖離の詳細）

## design-summary.md
- 乖離なし / 乖離あり
  （乖離の詳細）

## traceability.md
- 最新 / 要更新（最終更新: YYYY-MM-DD、最新コード変更: YYYY-MM-DD）

## 推奨アクション
- [ ] （具体的な更新アクション）
```

### 5. 更新の実行

ユーザーが「更新」と入力した場合、検出した乖離に基づいてドキュメントを更新する。
ユーザーが「スキップ」と入力した場合、更新せずに終了する。

更新時のルール：
- requirements.mdの更新: 新規REQ-x.xの追加は既存の最大番号の続きで採番する
- design-summary.mdの更新: インタフェース定義テーブルに行を追加する。既存行は変更しない
- traceability.mdの更新: 全行を再生成する（部分更新は整合性リスクが高いため）

## 制約

- コードの修正は行わない（ドキュメントの更新のみ）
- git push は行わない
- 不明な場合は更新せず、ユーザーに確認する
