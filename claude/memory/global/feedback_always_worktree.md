---
name: feedback_always_worktree
description: 開発着手時は並行作業が明示されていなくても常に worktree を分ける
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 55505cc9-05a6-4b0e-92c8-144732d53556
---

コード変更を伴う開発の着手時は、並行作業が明示されていなくても**常に** `cc-new <branch>`（git worktree）で本体ツリーから分離してから始める。本体（共有ツリー）で直接コードを書き始めない。

**Why:** 別セッション（別の Claude / Codex）が同じ repo で同時に動いていると、変更が同一ファイルに混在する。実例として、片方が機能修正、もう片方が Phase 7（API コスト計測）を同じ作業ツリーで進めた結果、`extraction.ts` / `index-store.ts` 等に両者のコードが混ざり、green を保ったまま機能別にコミット分割するのが不可能になった（中間コミットが必ず赤くなる）。最初から worktree を分けていれば回避できた。

**How to apply:**
- 着手前に `cc-new <branch>`（`git worktree add ../<repo>-<branch>`）で分離 → そのツリーで作業・commit
- worktree には node_modules が無いので、テスト実行前に本体から `ln -s` でリンクし、commit には含めない
- 例外（本体ツリーで可）: typo 修正・ドキュメントのみの微修正・read-only 調査
- 終了時は `git worktree remove` で畳む（CLAUDE.md「並行 worktree の整理」手順に従う）

旧運用（`~/.claude/CLAUDE.md`「並行セッション時の作業分離」）は"並行が明示された時"の提案だったが、今後は明示が無くてもこれをデフォルトにする。意図スレッドの分離は [[feedback_session_boundary]] も参照。
