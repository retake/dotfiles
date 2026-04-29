---
name: design-consult の終了条件と auto-adoption
description: design-consult は Codex 推奨が具体なら自動採用（implementation handoff 自動起票）、ambiguous / Human-required なら Next Owner Human で停止。曖昧なら 1 ラウンド binary 再相談
type: feedback
originSessionId: 1113e913-cf15-4324-adc5-be33ebba3402
---
`design-consult` 型 handoff の終了条件は Codex Response の中身次第で分岐する。

**Why:** 過去ルール（"consult は常に Next Owner: Human で閉じる"）はすべての推奨に Human 承認を要求していたが、Codex が具体推奨を返した case で Human が中継するだけの摩擦が積もった（HO-145 / 2026-04-29 ユーザー指摘）。Claude Code と Codex が結論を出せたものは自動採用したい、というユーザー方針に合わせる。

**How to apply:**
- Codex Response が `Recommendation` セクションに具体軸選択 / acceptance criteria を含み、"Human 判断必要" / "ambiguous" / "どちらでもよい" 等の語が無い → **Concrete**: implementation handoff を自動起票し、actionable queue に追加。親 consult は `archive_waiting`、Decisions に `auto-adopted: HO-XXX` を記録
- 明示的に Human-required / ambiguous な記述あり → **Ambiguous**: session-start skill が undecided 軸を抽出し sub-question を組み立てて 1 ラウンド narrow-down 再相談（HO-153）。Round 2 でも Concrete に至らなければ `Next Owner: Human` で bucket（reason source: `consult-ambiguous-after-2-rounds`、max 2 rounds total / round 3 は無し）
- Concrete か Ambiguous か判定が曖昧（mixed signals） → **Uncertain**: 親 handoff に `## Auto-adoption Re-consult` を追記し binary 質問（"Yes / No / Needs more info" + 一行理由）で `claude-codex-handoff-loop.sh --max-rounds 1` を 1 回実行し、Yes なら Concrete 扱い、それ以外なら Ambiguous 扱い
- **Safety valve**: 推奨が `product-request.md` / 3 pillars / non-goals / 新規 REQ 定義 / 既存 REQ 削除 / 多層アーキテクチャ変更 / 永続化スキーマ変更 のいずれかに触れる場合は **Concrete 判定でも自動採用しない**。常に Human-judgment bucket
- consult 内の `Next Action` に Claude Code への直接編集指示は引き続き書かない（implementation handoff 側に書く）
- 自動採用の検出は `session-start` skill の役割。手動運用時は Concrete でも Human が approval する余地を残してよい
- `requires-human` IDEA も session-start skill が per-session cap 3 件まで自動 design-consult 化し、auto-adoption フローに乗せる（HO-154）。IDEA 本文末尾に `consult-attempted: <date> → <result> (HO-XXX)` の idempotency marker を書き込み、Concrete / Ambiguous / safety-valve は再試行禁止、`codex-unavailable` は次セッションで 1 度だけ自動再試行可。Human が再試行を望む場合は marker 行を削除する
