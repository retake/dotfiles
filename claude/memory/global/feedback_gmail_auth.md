---
name: Gmail認証方式
description: 4つのGoogleアカウントはGoogle Workspace MCPで認証済み。初回エラーでも再試行すれば通る場合がある
type: feedback
originSessionId: be991924-ed0b-455a-9759-0797faf2335f
---
4つのGoogleアカウント（retake272, k_matsuura@kogasoftware, keita.matsuura.272, matsuura.finances.1121）はすべてGoogle Workspace MCPツール経由でGmail認証済み。

**Why:** 初回リクエストで認証エラーが返ることがあるが、再試行すれば通る。最初のセッションで認証不要と言われたのに認証リンクを提示してしまい不要な手間をかけた。

**How to apply:** Gmail操作時は4アカウントをそのまま使う。認証エラーが出ても、まず再試行を試みてから認証リンクを提示する。架空のメールアドレスを推測で使わない。
