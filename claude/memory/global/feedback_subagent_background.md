---
name: サブエージェントはバックグラウンド実行
description: サブエージェント（Implementer等）は結果待ちでもバックグラウンドで実行し、完了通知後に検証する
type: feedback
originSessionId: a8596ed1-69bd-4571-9b14-174ba8c5f214
---
サブエージェントは原則 `run_in_background: true` で実行する。結果を待って検証する場合でも、完了通知を受けてから検証に入ればよい。

**Why:** フォアグラウンドで長時間ブロックすると、ユーザーが他の作業や質問をできなくなる。

**How to apply:** orchestrateフロー内のFR-3〜FR-7の全サブエージェント呼び出しで `run_in_background: true` を使う。FR-5/FR-6の並列実行だけでなく、FR-3(Architect)、FR-4(Implementer)、FR-7(Reviewer)も同様。
