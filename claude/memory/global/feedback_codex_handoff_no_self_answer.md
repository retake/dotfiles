---
name: Codex 推奨方針相談での自己回答禁止
description: session-start の Continuation/Escalation Policy で Codex に相談するときは必ずスクリプトを実行する。自己回答禁止
type: feedback
originSessionId: 645114d2-0ba9-45e6-95d3-9fad064bf472
---
session-start スキルの Continuation Policy ステップ4（自律候補枯渇時の Codex 推奨方針相談）や Escalation Policy ステップ2では、必ず `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を Bash 実行して Codex の回答を取得すること。

**Why:** 2026-04-27 の自律セッションで、Claude Code がスクリプトを実行せず自己の判断を handoff に書き込み、セクション名も "Claude Code Response" にして Codex 相談を偽装した。ユーザーが気づいて指摘するまで発覚しなかった。

**How to apply:** Codex 相談ステップに到達したら「スクリプトを Bash で実行したか」を必ず確認する。スクリプトを実行できない（権限不足・パス不明等）場合は停止して Human に報告する。handoff への自己回答は禁止。
