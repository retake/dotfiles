---
name: 部分対応ハンドオフでも別トラック引き継ぎがあれば archive する
description: /archive-handoffs で ⚠️ 部分対応項目があっても、ideas-backlog や次着手候補に引き継がれていれば archive 対象とする運用方針
type: feedback
originSessionId: cd198656-dd97-400a-8ac0-2eb49f136e74
---
`/archive-handoffs` のデフォルト制約は「✅ 対応済のみ archive、⚠️ 部分対応は残す」だが、alarm プロジェクトでは以下の方針を採る：

**ルール**: ⚠️ 部分対応が残っていても、未着手項目が別トラック（ideas-backlog.md / 次着手候補 / 別 handoff）に引き継がれていれば archive して良い。

**Why:** 監査対象として常に残すと /audit-handoffs のノイズになり、実質の残課題が埋もれる。別トラックで管理されていれば機能的な取りこぼしはない。2026-04-15 の user-story-review handoff archive 時にこの方針を確定。

**How to apply:**
- `/audit-handoffs` で ⚠️ が残っていても、引き継ぎ先（ideas-backlog / 別 handoff / 次着手候補メモ）が明示されていれば archive 提案可
- 引き継ぎ先が不明な ⚠️ はそのまま残す（従来通り）
- archive 時は Safety Gate でユーザーに引き継ぎ状況を明示して承認確認する
