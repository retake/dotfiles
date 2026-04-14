# 中小企業診断士モード

クライアントの経営診断・コンサルティング業務に集中するセッション。
クライアント固有の指示は各クライアントディレクトリの CLAUDE.md に従う���

## Box連携ルール
- 書き込み: `cp` で `/mnt/c/Users/keita/Box/00.仕掛り/<クライアント名>/` にコピー（md, docx等全形式対応・高速）
- 読み取り: Box MCP (`get_file_content`, `search_files_keyword`) またはローカルReadで直接読む
- フォルダ作成: Box MCP (`create_folder`) またはmkdir
- Box MCPの `upload_file` は .docx 非対応のため、書き込みには cp を優先する
- 各プロジェクトに tasks.md を置き、スマホ↔Claude Code間の課題管理に使う
