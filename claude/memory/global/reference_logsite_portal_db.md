---
name: reference_logsite_portal_db
description: logsiteポータルのD1 DB構成。dogfooding_itemsなどポータルデータはlogsite-devにあり、capture-indexではない
metadata: 
  node_type: memory
  type: reference
  originSessionId: c41713ab-9532-48d8-a561-ac9cb7dfbe3d
---

## logsite の D1 DB 構成（サイト:DB = 1:1 が原則。2026-07-11 設計判断で確定）

| サイト（Worker） | DB名 | 用途 |
|---|---|---|
| logsite（本番） | `capture-index` | 本番の capture データ・本番の `ai_questions` |
| logsite-staging | `logsite-staging` | staging の capture データ（本番に対するステージ。**ポータルのデータ置き場ではない**） |
| logsite-dev-portal | `logsite-dev` | ポータル専用（`dogfooding_items`, `ho_confirmations`, `dev_jobs`, `portal_questions` 等） |

例外だった `MAIN_DB`（portal → logsite-staging の越境バインディング。`ai_questions` 用）は HO-255 で全廃。
ポータルの問い/アイデアは `logsite-dev.portal_questions` が正本。本番/staging の AI 生成問いはポータルと断絶（アプリ側で完結）。

## ポータルデータを操作するコマンド

```bash
# dogfooding_items を操作するときはこちら
npx wrangler d1 execute logsite-dev --remote --config portal/wrangler.jsonc --command "..."

# capture-index は本体（ai_questions などの読み取り用）
npx wrangler d1 execute capture-index --env staging --remote --command "..."
```

## 間違えた経緯（HO-129対応, 2026-07-05）

dogfooding_items のタイトルを日本語化する際、`capture-index --env staging` を更新してしまった。
ポータルの dogfooding データは `logsite-dev`（`portal/wrangler.jsonc` の `DEV_DB` バインディング）にある。

**How to apply:** ポータル関連のデータ（dogfooding, releases, confirmations, jobs）を操作する前に必ず `portal/wrangler.jsonc` を確認し、`logsite-dev` を対象にする。
