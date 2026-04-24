---
name: サブエージェントへの自動委譲
description: 調査・実装・レビュー等、適切なエージェントに自動で任せる。毎回確認しない
type: feedback
originSessionId: ba372d44-e6cf-4a7f-9a37-14f0a009691e
---
適切なエージェントタイプがある作業は、ユーザーに確認せず自動的に委譲する。

**Why:** 毎回「エージェントに任せますか？」と聞くのは手間。判断をユーザーに委ねない。

**How to apply:**
- 調査・コード探索（3クエリ超） → Agent(Explore)
- 実装タスク → Agent(implementer) または直接実装
- レビュー → Agent(reviewer)
- テスト生成・実行 → Agent(tester)
- lint → Agent(linter)
- コンテキスト保護が目的の場合も積極的に Agent に投げる
- 「任せていいですか？」は聞かない。判断して即実行する
