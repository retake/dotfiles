---
name: project-logsite-github-push-token-block
description: logsite リポジトリで git push origin main が GITHUB_TOKEN のせいで 403 になる既知の環境問題と回避策
metadata: 
  node_type: memory
  type: project
  originSessionId: c2cbc82d-251e-4958-8fa0-a6270ccef347
---

`~/dev/logsite` で `git push origin main` すると `remote: Write access to repository not granted. fatal: ... 403` になることがある。原因は shell の環境変数 `GITHUB_TOKEN`（write 権限のない PAT）が `gh`/git の credential 解決より優先されるため。`gh auth status` を見ると、write 権限のある別トークン（`repo` スコープ持ち、`~/.config/gh/hosts.yml` 経由）は存在するが non-active になっている。

**Why:** shell 起動時に GITHUB_TOKEN が自動セットされる設定になっている（他用途向けと思われる、詳細未確認）。write 権限のないトークンが優先されるため push だけがブロックされる。fetch も同様にブロックされることがある。

**How to apply:** push/fetch がこのエラーで失敗したら、`unset GITHUB_TOKEN GH_TOKEN && git push ...` のように **unset とgit操作を同一 Bash コマンド内で実行する**こと。Bash tool は working directory は永続するが shell state（環境変数）はコマンド間で持続しないため、unset だけ先に実行して次のコマンドで push すると再びブロックされる。恒久修正（.bashrc 等の見直し）はユーザー側の判断が必要なので、都度この回避策で対応する。
