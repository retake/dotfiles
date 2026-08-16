---
name: feedback-handoff-current-state-style
description: ハンドオフの Current state 節はファイル:行ポインタのみ。コードブロック引用は禁止。コード探索は code-map → grep → 部分Read の順。
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3d9158bc-78d0-45d4-8b3c-ef27247b35fb
---

ハンドオフ作成時の `## Current state` 節はコードブロックを引用しない。
ファイル:行番号 + 1〜2行の説明のみで十分。実装者が着手時に確認する。

**Why:** コードブロック引用のために大ファイル（app.js 2764行 等）を全文読みしており、ハンドオフ作成に時間がかかりすぎていた。

**How to apply:**
1. コード探索順: `docs/code-map.md` → `grep` → `Read（行範囲指定）` の順。全文Readは禁止。
2. Current state 節の書き方:
   - 良い例: `` `src/lib/extraction.ts:38-45` — `classifyExtraction()` は VOICE/PDF/IMAGE 以外を null 返却。URL ブランチなし ``
   - 悪い例: コードブロック ` ```js ... ``` ` を Current state 節に引用する
3. What to implement 節のコード例（設計上必要な場合）は書いてよい。grep/部分Readで確認した範囲に限る。

→ 関連: [[feedback-code-exploration-method]]
