---
name: Google Workspace MCP 連携アカウント
description: Claude の google-workspace MCP サーバーが OAuth 連携しているアカウントは retake272@gmail.com（keita.matsuura.272 ではない）
type: reference
originSessionId: 1ff8e1db-d2a4-4b5b-a3c5-5112bf795068
---
Claude Code の `mcp__google-workspace__*` ツール（Drive / Calendar / Gmail 等）が OAuth 連携しているアカウントは **`retake272@gmail.com`**。

`user_google_email` パラメータには必ずこのアドレスを渡す。同名 `keita.matsuura.272@gmail.com` 等は別アカウント（user_email_accounts.md 参照）で、MCP からはアクセス不可。

OAuth client が紐づく GCP project は別途存在する（project ID は OAuth エラー応答に含まれるので必要時に確認）。Drive API 等の有効化はそのプロジェクトで行う。

**How to apply**: Google Workspace MCP ツール呼び出し前に `user_google_email: retake272@gmail.com` を指定する。ハンドオフ等のドキュメント記載でも同様。
