---
name: feedback_agent_worktree_paths
description: サブエージェントに worktree を使わせるとき、絶対パスを明示しないと本体リポジトリを直接編集してしまう
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f79279a1-f3e7-43bf-a07e-94eae0ff7c04
---

サブエージェントへのプロンプトで "Working directory: <worktree>" と書くだけでは不十分。
エージェントはハンドオフに書かれた `src/...` 等の相対形式パスから本体リポジトリ (`/home/keita/dev/logsite/`) を直接探しに行き、そちらで Edit/Write/git commit を実行してしまう。

**Why:** エージェントの Read/Edit ツールは cwd ではなく絶対パスで動作するため、プロンプト中の "Working directory" は git コンテキストには効くが、ツール呼び出しパスには効かない。

**How to apply:** エージェントプロンプトに以下を毎回明示する：

```
All file edits MUST use paths under the worktree:
  <worktree_path>/
Do NOT use paths under <main_repo_path>/ directly.
Run all git commands with: git -C <worktree_path> ...
or cd into <worktree_path> before any git command.
```

[[feedback_always_worktree]] [[feedback_implementation_agent_policy]]
