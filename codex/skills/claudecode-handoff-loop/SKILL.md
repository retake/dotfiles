---
name: claudecode-handoff-loop
description: Claude Code と Codex の継続 handoff 運用を回す。ユーザーが「ClaudeCodeに返して」「handoffを確認して返信して」「継続対話を進めて」「修正対応をレビューして」「自動でループを回して」など、handoff の作成・確認・返信・archive 判定や bounded な自動往復を求めた時に使う。
metadata:
  short-description: 継続 handoff 運用
---

# ClaudeCode Handoff Loop

この skill は、`Claude Code` と `Codex` の継続 handoff を日本語で回すための運用手順を定義する。

対象は、少なくとも以下のどちらかが存在するリポジトリ。

- `AGENT_GUIDE.md`
- `docs/agent-handoff-template.md`

## いつ使うか

- ユーザーが `ClaudeCodeに返して` `ClaudeCodeに渡して` と言ったとき
- ユーザーが `handoffを確認して` `返信して` `継続対話を進めて` と言ったとき
- Claude Code からの修正対応を Codex が再レビューするとき
- active / waiting / archived の状態管理を伴う handoff 運用をするとき
- ユーザーが bounded な自動往復ループを求めたとき

## 最初に確認すること

1. `AGENT_GUIDE.md` を読む
2. `docs/agent-handoff-template.md` を読む
3. `docs/` 直下の active handoff と `docs/archive/` の関連 handoff を確認する

優先して見る項目:

- `task_id`
- `handoff_status`
- `Next Owner`
- `Next Action`
- `Final Outcome`

## 基本ルール

- handoff は **会話ログではなく正本** として扱う
- 継続タスクでは `task_id` を固定して引き継ぐ
- active な handoff は `docs/` 直下に置く
- archive 済み handoff は `docs/archive/` に置く
- archive 時は `handoff_status: archived` と `Final Outcome` を必ず入れる
- `Type: design-consult` は相談ループ、`implementation / review / bug-triage / audit / security-audit` は修正ループとして扱う
- 自動ループでは **Claude が実装領域の唯一の書き手**
- Codex は handoff ファイルのみ更新してよい

## レビュー応答ルール

- reviewer が指摘を出した handoff は、修正者が self-archive しない
- 修正者が返す時は通常:
  - `handoff_status: waiting`
  - `Next Owner: reviewer`
  - `Next Action: 修正差分の確認`
- reviewer が確認して初めて `done` または `archived` にできる
- 例外的に self-archive できるのは、reviewer が明示的に「確認不要」「対応後そのまま archive 可」と書いた場合だけ

## 相談ループと修正ループ

相談ループ (`Type: design-consult`) の原則:

- 目的は「推奨方針・採否・次アクションを固めること」
- 通常はコード修正完了まで自動で進めない
- 結論が出たら `handoff_status: done` と `Next Owner: Human` で止めるのを基本にする
- consult-only の結論は自動では archive しない

修正ループ (`Type: implementation / review / bug-triage / audit / security-audit`) の原則:

- 目的は「修正して reviewer が確認すること」
- reviewer 確認後は `archived` を基本とする
- `done` は人間の最終確認や次の判断待ちを残す時だけ使う
- 実装更新は Claude 側が行う
- handoff の議論・反論・妥協案の記述は Claude / Codex の両方が行ってよい

## 進め方

### 1. 新しい handoff を作る時

- 新規タスクなら新しい `task_id` を採番する
- 継続タスクなら既存の `task_id` を再利用する
- ファイル名は `docs/agent-handoff-claudecode-<topic>-YYYYMMDD.md` を基本にする
- 内容は `docs/agent-handoff-template.md` に従う

新しい `task_id` が必要なら、次を使ってよい。

```bash
bash /home/keita/.codex/skills/claudecode-handoff-loop/scripts/next_handoff_id.sh /path/to/repo
```

### 2. Claude Code に返す時

- まず active handoff と直近差分を確認する
- 同じタスクの follow-up なら `task_id` を引き継ぐ
- 新しい review / reply handoff を作るか、既存 active handoff を更新する
- どちらを選んでも `Next Owner` と `Next Action` は必ず更新する

判断基準:

- **新しい handoff を作る**:
  - ownership が変わる
  - reviewer の返答を独立して残したい
  - archive 済み履歴を残したい
- **既存 handoff を更新する**:
  - まだ同一手番のまま
  - 小さい追記で足りる

### 3. Claude Code の対応を確認する時

- まず `AGENT_GUIDE.md` のレビュー応答ルールに照らして状態遷移を見る
- 重点確認:
  - `task_id` が付いているか
  - `handoff_status` が実際の手番と合っているか
  - `Next Owner` と `Next Action` が埋まっているか
  - archive 済みなら `Final Outcome` があるか
- 問題が残るなら、新しい follow-up review handoff を作る
- 解消済みなら reviewer として archive を許可または実施する

### 4. archive 判定

- active のまま残す:
  - 次の担当がまだ作業する
  - reviewer 確認待ち
  - open questions が残っている
- archive する:
  - reviewer が解消確認した
  - この handoff で持っていた論点が閉じた
  - `Final Outcome` を一文で書ける

## 自動ループ

外側の orchestration が必要な場合は、次のスクリプトを使ってよい。

```bash
claude-codex-handoff-loop.sh --repo /path/to/repo --handoff docs/agent-handoff-claudecode-foo-YYYYMMDD.md
```

このスクリプトは以下を行う。

- active handoff から `task_id` と `Next Owner` を読む
- `Type` から相談ループか修正ループかを判定する
- `Claude` または `Codex` を headless で 1 ターン実行する
- `Next Owner = Codex` の時は、Codex は handoff ファイルのみ更新する
- `Next Owner = Claude` の時は、Claude は handoff と必要な実装を更新する
- handoff の状態変化を確認して、必要なら次の相手に回す
- 以下のいずれかで停止する:
  - task が archive された
  - task が `done` になった
  - `Next Owner` が `Human`
  - handoff が変化しなかった
  - 同じ agent が自分の次担当のまま残った
  - 最大ラウンド数に達した

注意:

- これは **bounded loop** であり、無制限の自己確認ループではない
- reviewer 確認前の self-archive は許容しない
- 相談ループは `done` で止め、修正ループは `archived` を基本にする
- 設計上、人間判断が必要な状態になったら止める
- 自動ループ中に Codex が implementation files を直接更新することは想定しない

## 出力の作法

- **必ず日本語で**書く
- 事実、判断、次アクションを分けて書く
- reviewer の指摘は severity を付ける
- ファイル参照はパスを明記する
- 作成または更新した handoff のパスを最後にユーザーへ伝える

## 最低限含めるべき情報

- `task_id`
- `handoff_status`
- `Goal`
- `Current State`
- `Decisions`
- `Open Questions`
- `Next Owner`
- `Next Action`

review 系では追加で次を優先する。

- `Findings`
- `Evidence`
- `Tests Run`

archive 時は追加で次を入れる。

- `Final Outcome`

## 失敗しやすい点

- reviewer の確認前に `archived` へ移す
- 同じ継続タスクなのに `task_id` を変えてしまう
- `Next Owner` / `Next Action` を空のままにする
- active handoff を `docs/archive/` に置いたまま更新する
- `Final Outcome` なしで archive する

## ユーザーへの返し方

- 何を確認したかを短く述べる
- 問題があれば findings を先に出す
- handoff を作成・更新したならそのパスを示す
- テスト未実行なら明記する
