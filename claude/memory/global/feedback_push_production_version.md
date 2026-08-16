---
name: feedback_push_production_version
description: 本番にデプロイする版は必ず git push する。push は確認を待たず実行してよい（全プロジェクト共通ルール）
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 633ab73d-78da-4764-a6ee-e716aef0e17f
  modified: 2026-08-09T14:22:18.382Z
---

本番環境にデプロイする（した）版は、必ず `git push` してリモートに残す。すべての開発の共通ルール。

**Why:** ローカルにしかないコミットが本番で動いている状態は、リモート・本番・ローカルが静かに乖離する。ロールバック先が特定できず、他マシン・他 worktree・他セッションからその版を再現できない。本番の正本がローカルの作業ツリーにぶら下がるのは事故の温床。

**How to apply:**
- 本番デプロイ（`wrangler deploy` の prod 環境、リリースタグ付与など）の**前に** commit → push を済ませる。デプロイ後に気づいて push、ではなく前段に置く
- この push は「外部への送信は都度確認」の例外。ユーザーから恒久的な許可を得ているので確認せず実行する（ローカル実験・砂場ブランチの push はこの限りではない＝通常どおり必要なら聞く）
- `GITHUB_TOKEN` / `GH_TOKEN` が環境にあると `gh auth` が通っていても 403 で落ちる。`env -u GITHUB_TOKEN -u GH_TOKEN git push` で回避（[[reference_github_token_env_blocks_push]]）
- 検証 green 後のリリース自走ルールと組み合わせる（[[feedback_logsite_release_autonomy]]）
