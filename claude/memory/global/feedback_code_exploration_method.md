---
name: feedback_code_exploration_method
description: 既存コード解析は全文Readでなくgrep先取り→部分Read→広域はExplore委譲を既定にする
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7a801503-b267-46d2-b2f7-d572e40ac582
---

既存コードを解析するとき、ファイル全体を `Read` してから探すのをやめ、次の順序を既定にする：

1. `Grep` / `grep` で該当シンボル・行番号を先に特定する
2. その行の周辺だけを `offset`/`limit` 付きで部分 `Read` する
3. 複数ファイル・命名規約をまたぐ広域探索は `Explore` エージェント（全文でなく抜粋を読む read-only 探索）に委譲する
4. 一度読んだ内容を再読しない

**Why:** ユーザーから「既存コードの解析に時間がかかりすぎる」と指摘された。実測ではコード規模・構造・docs はむしろ良好で、主因は私の探索手順（大ファイルの全文走査・再読）だった。これはこのセッション限りの意図では次セッションに引き継がれないため、永続化する。

**How to apply:** 大きいファイル（数百〜千行）を触る前に必ず grep で入口を絞る。リポジトリに `docs/code-map.md`（機能→ファイル・行アンカーの索引）があればまずそれを見る。logsite では CLAUDE.md がこのマップ参照を指示している。
