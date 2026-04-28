---
name: session-start
description: 自律セッションのセッション契約をヒアリング形式で作成し task-state.md に書き込むスキル。PCを離れる前の 3 問ヒアリングで完結する。
model: sonnet
user-invocable: true
---

# Session Start — 自律セッション契約作成スキル

PCを離れて Claude に長時間自律実行させる前の「セッション契約」を作成し、`task-state.md` に書き込む。
自動解決できる判断は省略し、必要な場合はまず Codex に相談してから人間へエスカレーションする。

## 使い方

- `/session-start` — ヒアリング開始（自動解決できたQは省略される）

## 実行手順

### ステップ 1: コンテキスト収集（自動・ユーザーへの表示なし）

以下を並列で読む:

1. `docs/product-request.md` を Read してプロダクトの目的・解決しないこと（non-goals）・優先軸を把握する（候補のフィルタリング基準になる）
2. `docs/traceability.md` を Read して REQ ごとの実装・テスト状況を把握する（空白 = 未着手、△ = 部分実装、✅ = 完了が目安）
3. `docs/requirements.md` を Grep で REQ 一覧を取得し、traceability.md と照合して未実装・未テストの REQ を特定する
4. `docs/ideas-backlog.md` を Grep で採否未決の IDEA を抽出する
5. `ls docs/agent-handoff-*.md 2>/dev/null` で active な handoff ファイルを列挙し、`handoff_status: active` または `waiting` のものを Grep で抽出する（Next Owner が Claude Code のものを優先）
6. `git status --short` で変更中ファイルを確認する
7. `.claude/task-state.md` を Read して既存タスクを確認する

### ステップ 2: Q1（Target）の自動解決 or Codex相談 or 人間質問

収集したコンテキストをもとに以下の順で処理する。

#### 2-A: 自動解決（Q1省略）

以下の条件をすべて満たす場合、Q1をスキップして Target を自動決定する：

- `Next Owner: Claude Code` の active handoff がちょうど1件
- product-request.md の non-goals に反していない
- 他の候補より明らかに優先度が高い（2位以下と rank 差 ≥ 2）

自動決定した場合は、Q1の代わりに以下を出力してステップ 3 へ進む：

```
[SESSION START] Target 自動決定（Q1省略）

active handoff が1件のため、Target を自動選定しました:
**Target**: <handoff の概要>

異議があれば「変える」と伝えてください。なければ次へ進みます。
```

ユーザーの応答を待つ（「変える」と言われた場合は 2-C へ戻る）。

#### 2-B: Codex相談（Q1前の曖昧解消）

以下の条件のどれかに当てはまる場合、人間に聞く前に Codex design-consult を実行する：

- Next Owner: Claude Code の active handoff が 2件以上（優先順位が明確でない）
- active handoff がゼロで、未実装 REQ が 2件以上あり同ランク（コスト・依存関係の差が不明）
- product-request.md に今期の優先軸が明記されていない

**Codex相談の実行手順**:

1. 以下の内容で `docs/agent-handoff-claudecode-session-priority-<YYYYMMDD>.md` を作成する:

```md
# Session Priority Consult

task_id: SESS-PRIORITY-<YYYYMMDD>
handoff_type: design-consult
handoff_status: active
Created: <YYYY-MM-DD>
Next Owner: Codex

## Context
<プロジェクト名>のセッション開始時に着手 Target を1つ選びたい。

## Candidates
<候補リスト（各候補の概要・推定コスト・依存関係・traceability の状況）>

## Question
上記候補の中で今セッションで着手すべき最優先を1つ選び、理由を述べよ。
判断軸: ユーザー価値の実現順序、テスト網羅率の改善、依存 REQ の解消。

## Constraints
- product-request.md の non-goals に反する候補は除外
- 推定コスト「大」のものは単独セッションで完結しない可能性を考慮

## Expected Output
| 推奨 | 理由 | 懸念点 |
|---|---|---|
| (候補名) | ... | ... |
```

2. `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff docs/agent-handoff-claudecode-session-priority-<YYYYMMDD>.md --max-rounds 1` を実行する
3. Codex の回答を Read して推奨候補を抽出する
4. Codex が明確な推奨を返した場合 → それを Q1 の「推奨」として提示し確認を求める
5. Codex も ambiguous（「どちらでも可」等）な場合 → 2-C へ進み人間に最終判断を委ねる

#### 2-C: 人間への Q1 提示

自動解決も Codex相談でも絞れなかった場合のみ、以下を出力してユーザー回答を待つ。

出力フォーマット:

```
[SESSION START] Q1/3

traceability・handoff・バックログを確認しました。
<Codex相談を実施した場合: 「Codex の推奨: <候補> （理由: <要約>）。以下から選択してください。」>

**今回のセッションで何を完成させますか？**

候補:
  a) <REQ-XX または IDEA-NN の概要>（推定コスト: 小/中/大）
  b) <REQ-XX または IDEA-NN の概要>（推定コスト: 小/中/大）
  c) その他 → 自由に記述

→ a / b / c または自由記述でどうぞ
```

候補のランキング基準（降順）:
1. active handoff で `Next Owner: Claude Code` のもの（着手待ち作業が既にある）
2. traceability.md で「実装済みだがテスト未作成」の REQ（テストが抜けている）
3. traceability.md で「未実装」の REQ のうち、requirements.md 末尾寄り（新しい）もの
4. ideas-backlog.md で「採用」かつ未着手の IDEA

**フィルタリング**: product-request.md の non-goals・解決しないこと に反する候補は除外し、その旨を Q1 に明示する。

### ステップ 3: Q2（Scope OUT）の自動解決 or 人間質問

ユーザーの Target（または自動決定した Target）を受けて以下を判定する。

#### 3-A: Q2自動解決（Q2省略）

以下の条件をすべて満たす場合、Q2をスキップする：

- Target が単一の REQ または handoff に明確に対応している
- 変更対象ファイルが traceability.md または handoff の scope に明記されており、ドメイン層・他 REQ との重複がない
- git status の変更中ファイルがすべて Target スコープ内

スキップ時は Scope OUT をデフォルト値（`docs/requirements.md` のみ）で埋めてステップ 4 へ進む。

#### 3-B: 人間への Q2 提示

```
[SESSION START] Q2/3

**触ってはいけないファイル・機能はどれですか？**（複数可、なければ「なし」）

デフォルトで除外済み:
  - docs/requirements.md（製品仕様のため）
  - lib/domain/**（ドメイン層。今回の Target 対象でなければ）

追加で除外したいものがあれば記述してください。
→ なし / ファイルパスまたは機能名
```

ユーザーの回答を待つ。

### ステップ 4: Q3（カスタム条件）の自動解決 or 人間質問

#### 4-A: Q3自動解決（Q3省略）

以下の条件をすべて満たす場合、Q3をスキップしデフォルト条件のみで進む：

- task-state.md の過去セッションで Q3 追加条件が「なし」だった
- Target が通常の実装タスク（auth/crypto/非同期ライフサイクル変更を含まない）

#### 4-B: 人間への Q3 提示

```
[SESSION START] Q3/3

**デフォルト以外に追加したい stop condition や権限はありますか？**

デフォルトの判断詰まり時の動作（Codex優先エスカレーション）:
  1. 自律判断を試みる
  2. 解が定まらない → Codex に design-consult で相談し、回答に従って進む
  3. Codex も判断不能と返した場合のみ → 停止してユーザーに報告
     （報告には「何に詰まったか」「Codex の回答」「何があれば介入不要だったか」を含める）

デフォルト stop conditions（Codex相談後も解決しない場合のみ停止）:
  - テスト赤が 3 回連続修正できない（Codex に修正方針を相談してから3回）
  - 設計の選択肢があり Codex も判断できない
  - 宣言スコープ外への変更が必要で Codex も回避策を提示できない

デフォルト pre-authorized（確認不要の判断）:
  - コミットメッセージの文言
  - lint 自動修正
  - golden 更新（flutter test --update-goldens）
  - Codex の推奨に従う実装方針の選択

→ 追加 stop condition・追加権限、または「なし」
```

ユーザーの回答を待つ。

### ステップ 5: 契約を task-state.md に書き込む + 介入分析を出力する

3 問の回答（または自動解決した値）をもとに以下のテンプレートを埋めて `task-state.md` を **Write（上書き）** する。

```md
## Autonomous Session Contract
Created: <YYYY-MM-DD HH:MM>

### Target
- <Q1 の回答を整形>

### Scope
- IN: <Target から推定した対象ファイル・ディレクトリ>
- OUT:
  - docs/requirements.md
  - <Q2 で追加された除外対象>

### Escalation Policy（判断詰まり時の行動順序）
1. **自律判断** — コンテキスト・コード・ドキュメントから解を導く
2. **Codex相談** — 解が定まらない場合、`docs/agent-handoff-claudecode-<topic>-<YYYYMMDD>.md` を作成し
   `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を実行、
   Codex の回答に従って実装を続ける
3. **停止 + 介入報告** — Codex も「Human判断が必要」と返した場合のみ停止する。
   停止報告には以下を含める:
   - **何に詰まったか**（具体的な判断ポイント）
   - **Codex の回答**（および Codex が判断できなかった理由）
   - **何があれば介入不要だったか**（ドキュメント・ルール・情報の不足点）

### Stop Conditions（Codex相談後も解決しない場合のみ停止）
- テスト赤が Codex に修正方針を相談しても 3 回連続で修正できない
- 設計の選択肢があり Codex も「どちらでも可」以外の推奨を返せない
- 宣言スコープ外への変更が必要で Codex も回避策を提示できない
- <Q3 で追加されたもの>

### Pre-authorized Judgments
- コミットメッセージの文言
- lint 自動修正
- golden 更新（flutter test --update-goldens）
- Codex の推奨に従う実装方針の選択
- <Q3 で追加されたもの>

### Success Criteria（Per-Target）
- flutter test 全件グリーン
- flutter analyze 警告ゼロ
- <Target の完了条件を REQ/IDEA から補完>

### Continuation Policy（Target 完了後の振る舞い）
Target の Success Criteria を満たしたら停止せず、以下の手順で継続する：

1. **Groom**（再整理）
   - `flutter test` と `flutter analyze` でクリーン状態を確認する
   - `docs/traceability.md`・active handoff・`docs/ideas-backlog.md` を再読し次の作業候補を洗い出す
   - 完了した Target の traceability.md ステータスを更新する

2. **次 Target の自律選定**（Q1 と同じ優先順）
   1. `Next Owner: Claude Code` の active handoff
   2. traceability.md で「実装済みだがテスト未作成」の REQ
   3. traceability.md で「未実装」の REQ（末尾寄り）
   4. `docs/ideas-backlog.md` で「採用」かつ未着手の IDEA（product-request.md の non-goals に反するものはスキップ）

   **先行 BG 起動（キュー最終判定）**: 選定後のキューが空（上記 1〜4 のいずれも残っていない）の場合、継続実行（ステップ 3）の前に以下を行う：
   - `docs/agent-handoff-claudecode-next-direction-<YYYYMMDD>.md` を作成する（ステップ 4 のテンプレートと同内容）
   - `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を **`run_in_background: true`** で Bash 起動する
   - task-state.md の Intervention Log に「BG Codex相談 起動: <handoff path>（完了通知待ち）」を追記する
   - その後 Target の実行を開始する（Codex の回答を待たない）

3. **継続実行** — 次 Target を Escalation Policy に従って実行する

4. **Codex 推奨方針相談**（自律候補が尽きた場合）
   自律選定で候補が見つからない場合（`Next Owner: Claude Code` の handoff がゼロ、未実装 REQ なし、採用 IDEA 未着手なし）、
   停止前に Codex へ推奨方針を問い合わせる：
   - **ステップ 2 の先行 BG 起動済みの場合**:
     Intervention Log の handoff パスを確認し、そのファイルを Read して Codex の回答を確認する。
     BG プロセスがまだ実行中（完了通知未着）の場合は完了通知を受けてから Read する（新規起動は不要）。
   - **先行 BG 未起動の場合**（ステップ 2 で先行起動をスキップした場合のみ）:
     `docs/agent-handoff-claudecode-next-direction-<YYYYMMDD>.md` を作成し、
     現在の traceability 状況・バックログ・product-request.md の非ゴールを添えて
     「次に取り組むべき方向を1つ推奨してほしい（推奨・理由・懸念点を表形式で）」と問う
     `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を Bash で実行して回答を取得する
   **⚠️ 自己回答禁止**: このステップでは必ずスクリプトを実行すること。Claude Code が handoff ファイルに直接回答を書くことは禁止。スクリプトを実行できない場合は停止して Human に報告する
   - Codex が**具体的な推奨**（REQ/IDEA/リファクタ方針等）を返した場合 → それを次 Target として採用し、ステップ 2 に戻って継続実行する
   - Codex も「Human判断が必要」または ambiguous な回答を返した場合 → ステップ 5 へ進む

5. **セッション終了条件**（以下のいずれかで停止する）
   - Codex 推奨方針相談でも「Human判断が必要」と返された（自律候補枯渇 → Codex も判断不能）
   - 作業候補がゼロかつ Codex 相談でも具体的な推奨なし（全 REQ ✅ かつ 採用 IDEA も全て完了）
   - Stop Condition がヒットし Codex 相談後も解決しない

### Intervention Log（停止時に記録する）
<!-- 停止が発生するたびに以下を追記する -->
<!-- 例:
- 2026-04-27 14:32: 詰まった点「StateNotifier の状態更新タイミング」
  Codex 回答: ambiguous（"どちらでも仕様依存" と返答）
  介入不要になる条件: CLAUDE.md に tick での state 再構成ルールを明記
-->
```

書き込み後、以下を出力して実装を即座に開始する:

```
[SESSION START] 完了 → 実行開始

task-state.md にセッション契約を書きました。そのまま実装を開始します。

**Target**: <1行サマリ>
**Scope**: IN <N ファイル/ディレクトリ> / OUT <M 件>
**Stop conditions**: <件数> 件（Codex相談後も解決しない場合のみ）
**Escalation**: 詰まったら Codex → それでも無理なら停止 + 介入報告
**継続実行**: Target 完了後、Groom → 次 Target 選定 → 実行 を繰り返す（終了条件に達するまで停止しない）

---

**セットアップ介入分析** (Q1〜Q3 で人間の判断が必要だったポイント)

| Q | 判定 | 理由 | 解消するには |
|---|---|---|---|
| Q1: Target選択 | 自動 / Codex相談 / 人間判断 | <理由> | <解消策> |
| Q2: Scope OUT | 自動 / 人間判断 | <理由> | <解消策> |
| Q3: Stop conditions | 自動 / 人間判断 | <理由> | <解消策> |

次回セットアップの自律度を上げるアクション:
  1. <具体的なアクション（ドキュメント追加・フィールド追加等）>

※ セッション実行中の介入ポイントは task-state.md の Intervention Log に記録されます。
```

セットアップ介入分析の「解消するには」の典型例:
- Q1が人間判断 → "handoff に priority フィールドを追加" / "product-request.md に current-focus セクションを追加"
- Q1がCodex相談止まり → "Codex が ambiguous を返した場合の tiebreak ルールを product-request.md に明記"
- Q2が人間判断 → "traceability.md の scope 列に変更対象ファイルを明記"
- Q3が人間判断 → "AGENT_GUIDE.md に常設 stop condition を追記してデフォルト化"

## 制約

- ヒアリングは最大 3 問。追加の確認をしない
- Q が自動解決された場合は、その旨を 1 行で明示する（省略したことをユーザーに見えるようにする）
- Codex相談（セットアップ用）は Q1 のみ対象。Q2・Q3 では実施しない（スコープ設定はユーザーの意図が強いため）
- Codex相談用 handoff ファイルは一時ファイル扱い。セッション契約書き込み後も残してよい（次回の `/audit-handoffs` で処理される）
- task-state.md は Write で上書きする（追記ではない）
- 既存の task-state.md の内容は上書き前に確認不要（Write で完全置換）
- 契約作成後、確認なしで即座に実装を開始する
- 生成した Escalation Policy は「設計の選択肢が出たら Codex に相談」であり「設計の選択肢が出たら停止」ではない。契約にそのように記載すること
- Continuation Policy に従って Target 完了後も停止しない。Groom → 次 Target 選定 → 実行のサイクルを繰り返す。自律候補が尽きた場合は Codex 推奨方針相談（ステップ 4）を経てから停止判断する（Codex が具体案を返したら継続、「Human判断が必要」なら停止）
- **Codex 推奨方針相談（Continuation Policy ステップ 4 / Escalation Policy ステップ 2）では必ず `claude-codex-handoff-loop.sh` を Bash 実行すること。自分の判断を Codex の見解として handoff に書く自己回答は禁止。スクリプト不実行の場合は停止 + Human 報告**
