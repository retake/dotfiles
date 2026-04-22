# Codex Review Request

## Context
- Project: (project name and tech stack)
- Common rules: See AGENT_GUIDE.md in repository root
- Worktree / 並行作業状況:
  <!-- `git worktree list` の出力をそのまま貼る。対象ブランチが本体ツリーか派生 worktree かを明示する -->
  <!-- 他に並行作業中の worktree があれば「この依頼は <path> / <branch> のみが対象。<other-path> の変更は無関係」と明記する -->
  ```
  (paste `git worktree list` output)
  ```
  - 対象 worktree: (path)
  - 対象ブランチ: (branch)
  - 並行 worktree: なし / あり（下記参照）

## Type
<!-- review / bug-triage / design-consult / audit / security-audit -->
review

## Scope
<!-- 対象ファイルをリストする。diff の場合は git range を書く -->
- Files:
  - (file paths)
- Diff: `git diff HEAD~N..HEAD`

## Question
<!-- 具体的に何を見てほしいか。曖昧な「全体的に見て」は避ける -->


## Expected Output
<!-- severity / file / issue / action の表形式を推奨 -->
```
| severity | file | issue | action |
|---|---|---|---|
| ... | ... | ... | ... |
```

## Constraints
<!-- プロジェクト固有のルールをここに記載 -->
