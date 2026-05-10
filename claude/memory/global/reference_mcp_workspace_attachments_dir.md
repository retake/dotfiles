---
name: workspace MCP の fileUrl は ~/.workspace-mcp/attachments/ 配下のみ
description: mcp__google-workspace__create_drive_file の fileUrl は ~/.workspace-mcp/attachments/ 以下に限定。他パスは 403。一時コピーで回避
type: reference
originSessionId: 1ff8e1db-d2a4-4b5b-a3c5-5112bf795068
---
`mcp__google-workspace__create_drive_file` の `fileUrl` パラメータで `file://` URL を渡すとき、参照可能なディレクトリは `/home/keita/.workspace-mcp/attachments/` 配下に限定されている（`ALLOWED_FILE_DIRS` 環境変数で拡張可能だが現状未設定）。

外側のパス（`/home/keita/dev/...` 等）を指定すると以下のエラーで 403:

```
Access to '<path>' is not allowed: path is outside permitted directories (/home/keita/.workspace-mcp/attachments)
```

**How to apply**: アップロードしたいファイルは事前に `cp <src> ~/.workspace-mcp/attachments/` でコピーしてから `fileUrl: file:///home/keita/.workspace-mcp/attachments/<name>` を指定する。アップロード完了後は一時コピーを `rm` で削除する（cleanup）。

恒久対策が必要なら `~/.config/workspace-mcp/` 等で `ALLOWED_FILE_DIRS` を `/home/keita/dev` まで拡張する案もあるが、副作用（任意 dev ファイルの誤アップロード）を考慮すること。
