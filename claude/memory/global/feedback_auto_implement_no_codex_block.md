---
name: auto-implement-no-codex-block
description: 自動実装パイプラインは Codex/Human の応答待ちでブロックせず、可能な限り staging deploy まで自走させる
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 69b110d3-5778-4987-a74b-686d20d7da9e
---

自動実装（logsite の /auto-implement 等の cron パイプライン）は「Codex 相談待ち」「Human 承認待ち」で止めない。可能な限り staging deploy まで自走させる。

**Why:** Codex 待ちで auto_implementable フラグの昇格が手動コミット頼みになり、cron が数サイクル「候補なし」で空転していた（2026-07-02 に指摘）。staging は壊れてよい環境なので、レビューを実装前に置く必然性がない。

**How to apply:**
- 実装前の Codex 相談をゲートにしない。Codex review は staging deploy 後の risk-based（auth・非同期ライフサイクル・大規模リファクタのみ）に後置する
- gating フラグ（auto_implementable 等）は自動昇格判定で立てる: deny list 通過 + 実装方向が具体的 + 未回答の設計判断なし、なら自動で true
- Human 判断が本当に必要なのは prod deploy と設計の分岐のみ。[[feedback-idea-recommendation-auto-adopt]] と同様、「推奨方向（AI暫定）」が具体的なら設計判断済みとみなす
- 関連: [[feedback-handoff-waiting-continue]]（waiting 中も次タスク継続）
