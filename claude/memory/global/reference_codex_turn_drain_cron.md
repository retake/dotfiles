---
name: codex-turn-drain-cron
description: logsite の Next Owner=Codex な stall HO を15分ごとに自動検出してCodex相談を回すcron
metadata: 
  node_type: memory
  type: reference
  originSessionId: fe259231-39a3-4167-8f72-a371987b84a5
---

logsite リポジトリに `scripts/codex-turn-drain-cron.sh`（+ `scripts/codex-turn-queue.py`）がある。`*/15 * * * *` で crontab 登録済み（2026-07-11 追加）。

`docs/handoffs/*.md`（archive除く）を走査し、`handoff_status ∈ {open,active,waiting}` かつ `Next Owner: Codex` かつ `Next Action` が空/TBDでない HO を検出し、各HOに `claude-codex-handoff-loop.sh --max-rounds 1` を実行する。fail-closed（パース不能は対象外、deny-by-default）。

**Why 作られたか**: [[feedback_auto_implement_no_codex_block]] は「実装前のCodexゲートにしない」はカバーしていたが、design consult 選択後に `Next Owner: Codex` で止まった HO を毎時 `auto-implement-cron.sh` が `skip (already registered)` を繰り返すだけで誰も処理しない、という別の穴があった（HO-235で5日間 stall した実例）。

**How to apply**: logsite で「Codex 待ちで進まない」と相談されたら、まずこの cron が正常に走っているか（`.claude-state/codex-turn-drain-cron.log`）を確認する。新しい同種の stall を見つけても、まずこの仕組みが機能しているか確認してから対処する。
