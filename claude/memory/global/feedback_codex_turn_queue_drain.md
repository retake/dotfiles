---
name: Codex-turn queue は Stop Report 前に全件消化
description: session-start Step 1.5.5 で Next Owner=Codex + 具体的 Next Action の handoff は同セッション内に Codex loop を回す
type: feedback
originSessionId: 9279ba85-0d9e-4a9e-9b04-5b35a88d8b55
---
session-start スキル Step 1.5.5 の Codex-turn queue 規約: `Next Owner: Codex` かつ `handoff_status: active` または `waiting` かつ `## Next Action` が具体的 (空・TBD でない) な handoff は、Stop Report を出す前に **per-session 全件処理** で `claude-codex-handoff-loop.sh` を Bash 実行する。Stop Report に「Codex review 待ち」として持ち越してはならない。

**Why:** 2026-05-06 の workflow セッションで、HO-W021 を「Codex review pass 待ち」として Stop Report に残したまま停止した。これは Step 1.5.5 違反。ユーザー指摘で同セッション内に loop を実行し、結果として handoff loop が pass → archive で完走した。Step 1.5.5 を律儀に踏んでいれば最初の Stop Report で完了報告できた。

**How to apply:** Stop Report を書く直前に survey set を再走査し、`Next Owner: Codex` + waiting/active + concrete Next Action の handoff が残っていないか確認する。残っていたら全件 loop を実行してから Stop Report を書く。コスト・cap 制約で持ち越したい場合は、その理由を明示して human-judgment bucket に入れる（reason source: `codex-cap-reached` 等）。「Human の判断不要 + Codex で完結する」状況で持ち越すのは違反。
