---
name: orchestrate提案の判断基準
description: 作業規模に応じてorchestrateの使用を提案する基準
type: feedback
originSessionId: 694365ce-f096-4da5-98b4-309cc57ca4da
---
実装前に規模を判定し、orchestrateが必要な場合はユーザーに提案する。

**orchestrate推奨の基準（いずれか該当）：**
- 設計判断が未確定（選択肢が複数あり合意が必要）
- 影響ファイル5個以上
- 新規アーキテクチャの導入
- 完了条件が3件以上（medium以上）

**直接実装で十分な場合：**
- 方針が確定済み
- 既存パターンの延長
- 影響範囲が3-4ファイル程度
- small相当（完了条件1-2件）

**Why:** orchestrateのフルフローは設計承認・レビューループ等のオーバーヘッドがある。小規模タスクに適用するとトークンと時間の無駄。
**How to apply:** 実装開始前に規模判定を行い、orchestrate推奨なら「orchestrateで進めることを推奨します」と助言する。判定理由も添える。
