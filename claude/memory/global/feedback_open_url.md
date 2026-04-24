---
name: URLは自動でブラウザ起動
description: 認証URLなどユーザーが開く必要があるURLは、表示するだけでなくxdg-openで自動的にブラウザで開く
type: feedback
originSessionId: ad3cd980-4a20-4f11-9640-24a5a825c0cd
---
ユーザーに開いてもらう必要があるURL（OAuth認証など）は、URLを表示するだけでなく `xdg-open "<URL>" 2>/dev/null &` で自動的にブラウザで開く。

**Why:** URLが長いと改行されてクリックできなくなるため。

**How to apply:** MCP認証やOAuthフローでURLが生成されたときは、表示と同時に xdg-open で開く。
