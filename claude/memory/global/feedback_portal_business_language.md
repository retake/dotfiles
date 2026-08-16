---
name: feedback-portal-business-language
description: logsite ポータルの UI 文言は業務寄り（意思決定の意味と観測可能な結果）で書く。実装用語を一次文言に出さない
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e15249c9-4238-451e-a1c1-f3d14d926c7d
---

logsite ポータル（および同種の Human ゲート UI）のユーザー向け文言は、実装の仕組みではなく業務上の意味で書く。

**Why:** ユーザーはポータルを「業務寄りに見るもの」として使う（2026-07-06 のフィードバック。凡例に限らずポータル全体への指摘）。poller / マージ / 書き戻し / staging / done 化 などの機構語は、判断のたびに脳内翻訳を強いる。

**How to apply:** 一次文言は「押すと業務上何が決まり、その後どう見えるか」（例: 承認 → 本番に反映され、完了すると ✅ になる）。機構の説明は副次表記か省略。正本ガイドラインは logsite の `docs/portal-ux-writing.md`（HO-223 で整備）。ボタン説明は凡例とホバーツールチップで同一ソース（HO-222）。
