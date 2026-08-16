---
name: reference-github-token-env-blocks-push
description: GITHUB_TOKEN環境変数が書き込み権限のない古いトークンだとgit pushが403になる。gh authは正常でも環境変数が優先される
metadata: 
  node_type: memory
  type: reference
  originSessionId: 1ce746a9-e281-4a05-85ce-81a83247387b
  modified: 2026-08-10T01:08:46.606Z
---

シェル環境に `GITHUB_TOKEN`（または `GH_TOKEN`）環境変数がセットされていると、`gh auth git-credential`（`gh auth setup-git` で設定される credential helper）よりそちらが優先され、そのトークンに write 権限がないと `git push` が 403 で失敗する。`gh auth status` は別の認証（`~/.config/gh/hosts.yml`）が正常でも、環境変数の存在だけでこの問題が起きる。

**症状の見分け方**: `git push` が `401`（Username読めない）や `403 Write access to repository not granted` で失敗するが、`gh auth status` は正常。

**一時回避**: `env -u GITHUB_TOKEN -u GH_TOKEN git push ...` で環境変数を外して実行する。

**根本解決（2026-08-10 実施済み）**: 出所は `~/dotfiles/.credentials`（`.bash_profile` から source、`.gitignore` 済み）。`.bash_profile:10` に `set -a`（allexport）があるため、`export` を書かなくても代入した変数は全て export される。そのため変数名を `GITHUB_TOKEN` → `GITHUB_PAT_MCP` にリネームして退避した。MCP セットアップ（`dotfiles/claude/scripts/setup-mcp.sh`）は別ファイル `dotfiles/claude/.mcp.env` を読むので影響しない。この修正後に環境変数由来の 403 が再発したら、`.credentials` 以外の注入元（VSCode 拡張ホストの環境など）を疑う。

2026-07-11、logsite リポジトリで発生（[reference_logsite_portal_db](reference_logsite_portal_db.md) と同じ運用文脈）。2026-08-10、trpg リポジトリで `git fetch` が同じ 403 を返し、根本原因を特定・解消。
