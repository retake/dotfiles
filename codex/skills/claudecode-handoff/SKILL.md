---
name: claudecode-handoff
description: Claude Codeに渡すレビュー/調査結果のhandoff文書を日本語で作成する。ユーザーが「claudecodeに渡して」「レビュー結果を教えて」などと言った時に使う。
metadata:
  short-description: Claude Code向けhandoff作成
---

# Claude Code Handoff Skill

このskillは、Codexで行ったレビュー/調査結果をClaude Codeに渡すための
`docs/agent-handoff-claudecode-*.md` を作成するための手順を定義する。

## いつ使うか

- ユーザーが「Claude Codeに渡して」「レビュー結果を教えて」など、Claude Code向けの引き継ぎを求めたとき
- 既存のレビュー結果を日本語で整理し直して、Claude Codeがそのまま作業に入れる形で残す必要があるとき

## 出力ルール

- **必ず日本語で**書く
- `docs/agent-handoff-claudecode-<topic>-YYYYMMDD.md` を新規作成する
  - `<topic>` は短い英字の要約（例: `req26-secondary-review`）
  - 日付は `YYYYMMDD`
- 既存の handoff と重複しないファイル名にする

## 推奨テンプレ

以下の構成を基本にする。

- Goal
- Findings（重大度順。High/Medium/Low で明示）
- Evidence（関連ファイル・行を明記）
- Tests Run（実行したコマンドと結果）
- Suggested Priority（必要なら）
- Notes

## 最低限含めるべき情報

- 何のレビュー/調査か（Goal）
- **指摘事項の要点**（Findings）
- **該当ファイルのパス**（Evidence）
- 実行したテストや未実行ならその旨（Tests Run）
- 具体的な修正方向（必要なら）

## 書き方の注意

- 同じ指摘を重複しない
- ファイル参照はパスを明記する（例: `lib/application/schedule_notifier.dart:250`）
- 断定が難しい場合は「可能性がある」「要確認」と書く

## 仕上げのルール

- 作成したファイルパスを**必ず**ユーザーに提示する
- Handoffを作った旨を簡潔に伝える

