---
name: box_workflow
description: コンサル資料はBox同期フォルダへcpで連携。読み取りはBox MCPも使える。
type: feedback
---

コンサル（診断士）用の資料はBoxで管理し、スマホとシームレスに連携する。

**Why:** スマホとの即時同期が必要。Box MCPのAPI経由アップロードは遅い（12ファイルで約4分）。cpでBox同期フォルダにコピーすれば数秒で完了。

**How to apply:**
- 書き込み: `cp` で `/mnt/c/Users/keita/Box/00.仕掛り/` 配下にコピー（md, docx等全形式対応・高速）
- 読み取り: Box MCP (`get_file_content`, `search_files_keyword`) またはローカルReadで直接読む
- フォルダ作成: Box MCP (`create_folder`) またはmkdir
- フォルダは `00.仕掛り` 配下にプロジェクト単位で作成
- 各プロジェクトに tasks.md を置き、スマホ↔Claude Code間の課題管理に使う
- Box MCPの `upload_file` は .docx 非対応のため、書き込みにはcpを優先する
