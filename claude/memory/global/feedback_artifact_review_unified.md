---
name: 複数 artifact の確認は 1 画面に集約する
description: スクリーンショット・レポート等の確認用 artifact を複数提示するときは、index.html 等で 1 画面に並べて確認できる形にする
type: feedback
originSessionId: 4cd076f7-97ee-4d64-875a-f1019659bea8
---
スクリーンショット・golden 画像・レポートなど、複数の artifact を Human にレビューしてもらう場面では、最初から **1 画面で全件並べて見られる形** を用意する。1 つずつ Read で表示したり個別ファイルを開かせたりすると、レビュー負担が高く、全体の整合性も把握しにくい。

**Why**: 2026-05-05、HO-212 の screenshot harness 実装後に PNG 7 枚を 1 つずつ Read で表示したところ「一つずつ確認するのは大変なので、今後は html を作って一画面で全部確認できるようにして」と指摘を受けた。複数 artifact を生成する仕組みを作る時点で、index 化を含めるべき。

**How to apply**:
- screenshot 生成スクリプトには PNG と一緒に `index.html`（grid layout）を出力する step を含める
- レポート系（diff 一覧・lint 一覧等）も同様に summary.md / index.html を併走させる
- Human への提示順は「最初に index、必要なら個別 artifact」。逆順にしない
- 個別 Read の繰り返しは「ユーザーが詳細を見たい」と明示した場合に限る
