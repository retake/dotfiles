---
name: handoff-loop
description: Codex と Claude Code の bounded handoff loop を開始または継続する。引数に handoff パスまたは task_id を渡して、相談ループ / 修正ループを回す。
---

# handoff-loop

Codex と Claude Code の handoff loop を開始または継続する。

## 使い方

- `/handoff-loop docs/agent-handoff-claudecode-foo-YYYYMMDD.md`
- `/handoff-loop HO-001`
- `/handoff-loop docs/agent-handoff-claudecode-foo-YYYYMMDD.md --max-rounds 4`

## ルール

1. 現在の作業ディレクトリを repo root として扱う
2. 引数が `HO-` で始まれば `task_id` とみなす
3. それ以外は handoff パスとみなす
4. 実行前に `AGENT_GUIDE.md` と `docs/agent-handoff-template.md` が存在することを確認する
5. 実行は `claude-codex-handoff-loop.sh` を使う

## 実行コマンド

### 引数が task_id の場合

```bash
claude-codex-handoff-loop.sh --repo "$(pwd)" --task-id "$ARGUMENTS"
```

### 引数が handoff パスの場合

```bash
claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff "$ARGUMENTS"
```

### `--max-rounds` を含む場合

引数をそのまま末尾に渡してよい。

例:

```bash
claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff docs/agent-handoff-claudecode-foo-YYYYMMDD.md --max-rounds 4
```

## 補足

- `Type: design-consult` は相談ループとして扱われ、通常は `done + Human` で止まる
- `Type: implementation / review / bug-triage / audit / security-audit` は修正ループとして扱われ、通常は reviewer 確認後 `archived` で閉じる
- Codex は handoff ファイルだけを更新し、実装ファイルは Claude Code が更新する
- script 実行後は、停止理由と更新された handoff をユーザーへ短く報告する
