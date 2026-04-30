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
4. `docs/ideas-backlog.md` を Grep で採否未決の IDEA を抽出する。各 IDEA の `採否フィルター`（`auto-adoptable` / `auto-rejectable` / `requires-human`）も同時に取得する
5. `ls docs/agent-handoff-*.md 2>/dev/null` で active な handoff ファイルを列挙し、`handoff_status` と `Next Owner` を Grep で抽出する（フィルタリングはステップ 1.5 で行うので全件を取得すること）
6. `git status --short` で変更中ファイルを確認する
7. `.claude-state/task-state.md` を Read して既存タスクを確認する

### ステップ 1.4: archive_waiting handoff の自動アーカイブ（HO-157 / 2026-04-29 導入）

ステップ 1 で発見された active handoff のうち `handoff_status: archive_waiting` のものを `docs/archive/` に自動移動する。**ステップ 1.5 より先に**実行することで、survey set がクリーンな状態でフィルタリングに進む。

#### 検出

`docs/agent-handoff-*.md` を Grep し `handoff_status: archive_waiting` の handoff を抽出する（`docs/archive/` 配下は対象外）。候補が 0 件ならステップ 1.4 全体をスキップ（ログも出さない）。

#### 安全ゲート（dangling reference check）

各候補について以下を実行:

1. handoff の basename を取得（例: `agent-handoff-claudecode-ho146-session-start-batch-mode-impl-20260429`）
2. `grep -l <basename>` を以下のターゲットに対して実行:
   - `docs/traceability.md`
   - `docs/ideas-backlog.md`
   - `docs/design-summary.md`
   - 他の active handoff（自身を除く `docs/agent-handoff-*.md`）
   - これらのファイルが存在しない repo では graceful degradation（存在するものだけ check）
3. マッチした参照が **Markdown 形式の path link**（例: `[text](agent-handoff-xxx.md)` または `docs/agent-handoff-xxx.md` 直書き）なら **dangling-references** と判定して skip
4. **bare mention**（path 形式ではない、例: `HO-146 builds on...`）はゲートしない（archive 後も意味が通るため）

#### Action

- **safe** な候補: `git mv docs/agent-handoff-<file>.md docs/archive/` を実行。untracked なら先に `git add`、その後 `git mv`（履歴保全のため `archive-handoffs` SKILL の慣習に従う）
- **dangling-references** で skip した候補: そのまま放置し、Stop Report の `## Auto-archive Log` で `Skipped (dangling references; manual review required)` セクションに記録（参照元のファイルパス + line 番号を含める）

#### 制約

- **絶対に** `archive_waiting` 以外（`done` のみ等）を archive しない
- 参照元ドキュメントを自動編集してリンクを修正しない（archive-handoffs SKILL と同じ「修正は自動適用しない」方針）
- ループ中の確認プロンプトは出さない（Human はセッション開始時に auto-archive を承認済み前提）。判断は dangling check + `archive_waiting` だけで完結
- 0 件の場合は Stop Report に Auto-archive Log セクション自体を出さない（ノイズ削減）

#### Logging

ステップ 5 で出力する Stop Report の `## Auto-archive Log` に以下を蓄積する（候補 0 件の場合は section 自体を省略）:

```
## Auto-archive Log

Moved to docs/archive/:
- HO-XXX (<title>) — moved at session-start sweep
- HO-YYY (<title>) — moved during continuation re-scan

Skipped (dangling references; manual review required):
- HO-ZZZ (<title>) — referenced by docs/traceability.md:L<line>
```

### ステップ 1.5: 3 セットモデルの構築（HO-146 / 2026-04-29 導入）

ステップ 1 で集めた情報をもとに、以下の 3 セットを内部状態として構築する。これは AI の作業メモリに保持し、ユーザーへの表示はステップ 2 以降の判断ロジックの結果のみに留める。

- **Survey set**: ステップ 1 で読み取った全 IDEA・全 handoff・traceability の REQ・git status の変更ファイル等を保持する。**フィルタで除外しても survey set からは消さない**。説明可能性のため。
- **Actionable queue**: 後述の「フィルタルール」を通過した item のみ。優先順位順に並べる（priority key: handoff `Next Owner: Claude Code` 既在 > REQ 未テスト > REQ 未実装 > IDEA `auto-adoptable`）。Target はここから選ぶ。
- **Human-judgment bucket**: フィルタで除外された item を `reason source` 付きで保持する。停止時の Stop Report で使う。

#### フィルタルール

**actionable queue から除外**（human-judgment bucket に reason source 付きで配置）:

- IDEA で採否フィルターが `auto-rejectable` → reason source: `filter` / 詳細: `IDEA filter = auto-rejectable`
- IDEA で採否フィルターが `requires-human` かつ **consult-eligible でない**（後述の sub-bucket 条件を満たさない） → reason source: `filter` / 詳細: `IDEA filter = requires-human`
- Handoff で `Next Owner: Human` または `Next Owner: Codex` → reason source: `handoff` / 詳細: `Next Owner = <value>`
- Handoff で `handoff_status` が `blocked` / `archive_waiting` / `done` / `archived` → reason source: `handoff` / 詳細: `handoff_status = <value>`（ただし `done` の design-consult は別経路で「auto-adoption candidate」として扱う、後述）
- Item の親 design-consult handoff が `active` で未解決（依存ガード） → reason source: `dependency` / 詳細: `parent HO-XXX unresolved`
- Codex 相談を経て stuck と判明した item（実行中に検出） → reason source: `codex-consult-result` / 詳細: `Codex returned <ambiguous | Human-required>`
- ステップ 1.6 の Auto-adoption 経路で `Ambiguous` または safety-valve に該当した design-consult → reason source: `consult-ambiguous` または `safety-valve`

**actionable queue に投入**（順次実行候補）:

- Handoff: `Next Owner: Claude Code` かつ `handoff_status: active` または `waiting` かつ `Next Action` に具体記述あり
- IDEA: 採否フィルターが `auto-adoptable` かつ `product-request.md` non-goals に抵触しない
- REQ: traceability で「未実装」または「実装済みだがテスト未作成」かつ前提（依存 REQ・親 design-consult）が解決済み
- ステップ 1.6 で `Concrete` 判定された design-consult から自動起票された implementation handoff

**Graceful degradation**: 採否フィルター未付与の IDEA や非標準 handoff フォーマットは、**そのソースからは auto-adoptable と判定しない**。他のソース（例えば handoff `Next Owner: Claude Code`）が候補化条件を満たす場合のみ queue に入る。

このフィルタは repo によって metadata 充足度が異なる前提で設計されている。alarm 以外の repo で IDEA 採否フィルターが整備されていない場合、stop report に "filter coverage limited in this repo" の 1 行を出すだけで実行は継続する。

#### consult-eligible IDEAs sub-bucket（HO-154 / 2026-04-29 導入）

`requires-human` IDEA のうち、Codex 相談を経て auto-adopt 可能性があるものは **consult-eligible IDEAs sub-bucket** に配置する。これらはステップ 1.6.5 で per-session cap (= 3 件) まで自動 design-consult 化される。

**consult-eligible 条件**（すべて満たす）:

1. IDEA の採否フィルターが `requires-human`
2. IDEA を `## Context` で参照する active な `Type: implementation` または `Type: design-consult` handoff が存在しない（cross-reference idempotency）
3. IDEA 本文に `consult-attempted: <date> → <Concrete | Ambiguous | safety-valve>` のマーカー行が**存在しない**（terminal-result idempotency）。`codex-unavailable` の場合は 1 度だけ自動再試行可（2 度目以降は Ambiguous 扱い）
4. IDEA 採否フィルター注釈に `(HO-XXX dependent)` 等の依存表記があり、参照先 handoff が未解決でない（依存ガード）
5. ステップ 1.6.5 の safety-valve pre-check（後述）に抵触しない

条件を満たさない `requires-human` IDEA は通常通り human-judgment bucket に入る（reason source: `filter` / `dependency` / `consult-attempted`）。

### ステップ 1.6.5: IDEA design-consult 自動起票（HO-154 / 2026-04-29 導入）

ステップ 1.5 で抽出した consult-eligible IDEAs sub-bucket を per-session cap まで処理する。**ステップ 1.6 より先に実行**することで、新規起票された design-consult handoff も同セッション内の Step 1.6 auto-adoption フローに乗る。

#### Per-session cap

- **デフォルト 3 件**（hard-coded）。コスト（Codex API）と coverage のバランスから設定
- 候補が cap を超える場合、優先順位で選別: `priority: high > normal > low`、tie-break は IDEA 番号昇順（古いものから処理）
- 残った候補は次セッションで処理される（starvation 防止のため番号昇順）

#### Safety-valve pre-check

Codex を呼ぶ前に、IDEA 本文を読んで以下のキーワード / scope を含む場合は `safety-valve` と判定して **consult を試行せず** idempotency marker を書く:

- `product-request.md` への参照（case-insensitive）
- 「新規 REQ」「new REQ」「REQ 追加」
- 「REQ 削除」「remove REQ」「REQ 廃止」
- `domain` + `application` + `presentation` の同時言及（多層アーキ変更）
- `persistence schema` / 「永続化スキーマ」 / `domain model` + `breaking`

該当した IDEA は IDEA 本文末尾に `- consult-attempted: <YYYY-MM-DD> → safety-valve (no HO)` を追記、Stop Report の Auto-adoption Log に `IDEA-NN → safety-valve (touches <領域>); skipped without consult` と記録、human-judgment bucket に入れる。

#### 自動 design-consult 起票

safety-valve をパスした各 candidate に対して以下を実行:

1. **新規 handoff ファイル作成**:
   - パス: `docs/agent-handoff-claudecode-ho<next>-idea<NN>-consult-<YYYYMMDD>.md`
   - `<next>` は次の HO 番号、`<NN>` は IDEA 番号、`<YYYYMMDD>` は本日

2. **handoff 本文を IDEA から transcribe**:
   - `## task_id`: `HO-<next>`
   - `## handoff_status`: `active`
   - `## priority`: IDEA の priority に準ずる（理由は IDEA から要約）
   - `## Goal`: IDEA タイトル + IDEA 本文の 1〜2 行要約
   - `## Context`: IDEA の出所 / 現状認識 / **必ず `IDEA-<NN>` への back-reference を含める**（idempotency 検出のため）
   - `## Type`: `design-consult`
   - `## Scope`: IDEA 本文の `scope` 節があればそのまま転記、無ければ「TBD by Codex」
   - `## Axes`: IDEA 本文の `軸` / `候補` / `論点` 節を整形して列挙。section が無い場合は「`open axis`: 1 つの軸として記載、Codex が options を提案する余地」と書く
   - `## Open Questions`: IDEA 本文の論点 / 不確定事項を箇条書き化
   - `## Ask`: 以下のテンプレート文を生成
     ```
     Codex, please review this IDEA and provide a concrete recommendation.
     1. For each axis above, pick one option (or propose a new one) and explain in one line.
     2. Identify any safety-valve concerns (product-request / new REQ / multi-layer / persistence). If found, say so explicitly.
     3. Output as `## Codex Response` with sub-headings `Recommendation`, `Pushbacks`, `Safety considerations`, `Slice 2 acceptance criteria` (if Concrete).
     ```
   - `## Next Owner`: `Codex`
   - `## Next Action`: `Codex reviews and writes ## Codex Response.`

3. **Codex 実行**: `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <new-handoff-path> --max-rounds 1` を実行（**自己回答禁止**: `feedback_codex_handoff_no_self_answer.md` 準拠。Claude Code は handoff structure を生成するが `## Codex Response` セクションを書くことは禁止）

4. **結果のステップ 1.6 への引き渡し**: 新規 handoff は survey set に追加され、ステップ 1.6 の first-pass classifier で処理される。Concrete / Ambiguous / Uncertain / safety-valve のいずれかに分類され、各経路は HO-146 / HO-153 のロジックそのまま

5. **idempotency marker の書き込み**: ステップ 1.6 の最終分類が確定した後、IDEA 本文末尾に追記:
   - Concrete + 自動採用 → `- consult-attempted: <YYYY-MM-DD> → Concrete (HO-<auto-implementation-handoff>)`
   - Ambiguous（round 2 でも未決） → `- consult-attempted: <YYYY-MM-DD> → Ambiguous (HO-<consult>)`
   - safety-valve（pre-check 後の round 1 で発覚） → `- consult-attempted: <YYYY-MM-DD> → safety-valve (HO-<consult>)`
   - Codex 実行不能 → `- consult-attempted: <YYYY-MM-DD> → codex-unavailable (HO-<consult>)`
   - **重要**: Concrete 以外は再試行されない。Human が再試行を望む場合は marker 行を削除する

#### Logging

- Stop Report の Auto-adoption Log に IDEA-derived consult のラインを必ず含める。例:
  - `IDEA-105 → HO-200 (auto-created consult): Round 1 Concrete → auto-adopted as HO-201`
  - `IDEA-99 → HO-202 (auto-created consult): Round 1 Ambiguous → Round 2 Concrete → auto-adopted as HO-203`
  - `IDEA-97 → safety-valve (touches new REQ definition); skipped without consult`
  - `IDEA-93 → cap reached (3/3 already consulted this session); deferred to next session`

### ステップ 1.6: Design-consult auto-adoption 判定（HO-146 / 2026-04-29 導入）

`Type: design-consult` で `handoff_status: done` かつ `## Codex Response` セクションが非空の handoff を **auto-adoption candidate** として抽出する。各 candidate に対して以下を実行:

#### Idempotency check（最初に行う）

以下のいずれかに該当すれば、既に採用済みなので **skip**（再度 implementation handoff を作らない）:

- active な handoff のうち `Type: implementation` で、`## Context` セクション内にこの親 consult の task_id（`HO-XXX`）への参照を含むものが存在する（**最も信頼できる primary signal**。手動採用された場合もこれが立つ）
- 親 consult の `## Decisions` に `auto-adopted: HO-XXX` の行がある（この skill が自動起票したときに残るマーク）

skip の場合は survey set にだけ残し、actionable queue にも human-judgment bucket にも入れない。Stop Report の Auto-adoption Log には `HO-<parent>: Idempotent skip (covered by HO-<child>)` を 1 行残す。

#### IDEA-level Idempotency（並行 implementation handoff 検出）

IDEA を actionable queue に投入する前に、以下を確認:

- active な handoff のうち `Type: implementation` で、`## Context` または `## Goal` 内にこの IDEA の ID（`IDEA-NN`）への参照を含むものが存在する → IDEA は queue に入れず、reason source `idempotent`（詳細: `IDEA-NN already in flight as HO-XXX`）で human-judgment bucket に入れる。Stop Report ではこの bucket 行を「実行中なので Human 操作不要、HO-XXX 完了後に消える」と注記する

これにより、別セッションが手動で IDEA を implementation handoff に昇格させた場合でも重複起票しない。

#### First-pass classification（Claude Code が一次判定）

以下のチェックリストを順に評価する:

1. `## Codex Response` セクションが存在し、`Recommendation` 見出し（または同等の節）を含むか
2. Recommendation に具体的な軸選択（"option X を採用" / "axis Y は value Z" 等）または Slice 2 acceptance criteria が含まれているか
3. Recommendation 本文に "Human 判断必要" / "ambiguous" / "どちらでもよい" / "either approach is fine" / "Human-required" / "Need more info" 等の文言が **含まれていない**か
4. Recommendation が **safety-valve 領域に触れていない**か（次節）

| 評価結果 | 分類 |
|---|---|
| 1〜4 すべて Yes | **Concrete** |
| 1〜3 のいずれかが明確に No | **Ambiguous** |
| Yes / No が混在し判定不能 | **Uncertain** |

#### Safety valve

Recommendation が以下のいずれかに触れる場合、Concrete 判定でも **自動採用しない**。`reason source: safety-valve` で human-judgment bucket に入れる:

- `docs/product-request.md`（3 pillars / persona / non-goals）の変更
- 新規 REQ 定義（recommendation が新しい REQ-XX を導入）
- 既存 REQ の削除 / scope 縮小
- 多層アーキテクチャ変更（domain + application + presentation を同時に触る）
- 永続化スキーマ / domain model の breaking change

#### Routing

- **Concrete** + safety-valve clean → **auto-adopt**:
  1. 新規 implementation handoff `HO-<next>` を作成。Codex の acceptance criteria を `## Acceptance Criteria` に転記し、親 consult を `## Context` で参照、`Next Owner: Claude Code`、`handoff_status: active`
  2. 親 consult を Edit して `## Decisions` に `auto-adopted: HO-<next> (session-start auto-adoption)` を追記、`handoff_status: archive_waiting` に変更
  3. 新規 implementation handoff を actionable queue に投入
  4. Stop report の executed items 欄に `auto-adopted HO-<next> (parent: HO-<parent>): <one-line>` を記録予定
- **Ambiguous** → **Round 2 narrow-down consult を試行**（HO-153 / 2026-04-29 導入）:
  1. **Idempotency check**: 親 handoff に `## Round 2 Consult` セクションが既に存在する場合は round 2 を再実行しない（前回 session で実施済み）。Round 2 が既に終わっているのに最終分類が未確定なら bucket に直接入れる
  2. **Undecided 軸の抽出**: round 1 `## Codex Response` を再読し、`Recommendation` 内で「single chosen value が無い」「either is fine / depends on / どちらでも 等の語で回避された」軸を最大 3 軸まで列挙する（visibility 順 — 最初に / 最も多く言及された軸を優先）
  3. **Sub-question 生成**: 各軸ごとに以下のテンプレートで specific 質問を作る（Claude Code が組み立てるが**回答は禁止**）:
     ```
     Axis: <axis-name>
     Options: <option list from round 1 or original handoff ## Axes>
     Pick one and explain in one line.
     If you genuinely cannot pick, say `Human required: <one-line reason>`.
     ```
  4. **親 handoff に追記**: 新規セクション `## Round 2 Consult` を親 handoff の末尾近く（`## Codex Response` の後）に追記し、上記 sub-questions を順に列挙する
  5. **Codex 実行**: `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を実行（**自己回答禁止**: `feedback_codex_handoff_no_self_answer.md` 準拠）
  6. **Round 2 分類**: 返ってきた応答を **同じ first-pass classifier** に通す（safety valve も再評価）:
     - **Round-2 Concrete** + safety-valve clean → Concrete 経路で auto-adopt（`HO-XXX: Round 1 Ambiguous → Round 2 Concrete → auto-adopted as HO-YYY` を log）
     - **Round-2 Concrete** + safety-valve hit → bucket（reason source: `safety-valve`）
     - **Round-2 Ambiguous または Uncertain** → bucket（reason source: `consult-ambiguous-after-2-rounds`、詳細: 残った undecided 軸名と Codex の一行理由）
  7. **Hard cap**: round 3 は無し。Round 2 でも未決なら必ず Human に上げる
  8. **Codex 実行不能時**（network / CLI error 等）: round 2 を試行せず、reason source `codex-unavailable` で bucket に直接入れる（content-level ambiguity と infrastructure failure を区別）
- **Uncertain** → **bounded binary re-consult**（round 2 narrow-down とは**別経路**、one-shot binary 質問のみ。Uncertain → binary が No / Needs more info を返しても round 2 narrow-down には**再帰しない** — 全 design-consult について Codex 対話は max 2 rounds total を超えない）:
  1. 親 handoff に `## Auto-adoption Re-consult` セクションを追記し、binary 質問を 1 つだけ書く: "Is your recommendation in `## Codex Response` concrete enough to auto-adopt without further Human input? Answer Yes / No / Needs more info, with a one-line reason."
  2. `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を実行（**自己回答禁止**: `feedback_codex_handoff_no_self_answer.md` 準拠）
  3. Codex 回答が `Yes` → Concrete 経路で auto-adopt
  4. Codex 回答が `No` または `Needs more info` → 直接 bucket（reason source: `consult-ambiguous-after-binary-recheck`、詳細: `binary re-consult: <Codex の一行理由>`）。**round 2 narrow-down は試行しない**

#### Logging

- すべての分類結果を Stop Report の `## Auto-adoption Log`（後述）に 1 行ずつ記録する。**ラウンド数を必ず明記**する（HO-153 / 2026-04-29 導入）
- 例:
  - `HO-143: Round 1 Concrete → auto-adopted as HO-151 (header CTA consolidation)`
  - `HO-144: Round 1 Concrete + safety-valve (touches REQ-27/REQ-50 wall-clock invariant) → bucket`
  - `HO-145: Idempotent (covered by HO-146) → skip`
  - `HO-XXX: Round 1 Ambiguous → Round 2 Concrete → auto-adopted as HO-YYY`
  - `HO-XXX: Round 1 Ambiguous → Round 2 Ambiguous → bucket (reason: consult-ambiguous-after-2-rounds, axis: <name>)`
  - `HO-XXX: Round 1 Uncertain → binary re-consult Yes → Concrete → auto-adopted as HO-YYY`
  - `HO-XXX: Round 1 Uncertain → binary re-consult No → bucket (reason: consult-ambiguous-after-binary-recheck)`
- **重要**: binary re-consult は "round 2" と数えない。round 2 narrow-down 経路（Ambiguous trigger）と binary re-consult 経路（Uncertain trigger）は別概念。両方合わせても 1 design-consult あたり Codex 対話は **max 2 回**（round 1 + 1 follow-up）。

### ステップ 2: Q1（Target）の自動解決 or Codex相談 or 人間質問

ステップ 1.5 で構築した actionable queue を起点に、以下の順で処理する。**新仕様（HO-146 / 2026-04-29）では Q1 は例外パスであり、actionable queue に明確な top item があれば省略する**。

#### 2-A: 自動解決（Q1省略・通常パス）

以下の条件をすべて満たす場合、Q1をスキップして Target を自動決定する：

- actionable queue が非空（少なくとも 1 件以上の auto-adoptable / `Next Owner: Claude Code` 候補がある）
- queue 先頭 item の scope（変更対象ファイル群 / `Next Action`）が一意に推測可能
- queue 先頭 item と 2 位以下に scope 競合がない（同じファイルを違う方向で改修する候補が並んでいない）
- product-request.md の non-goals に反していない

自動決定した場合は、Q1の代わりに以下を出力してステップ 3 へ進む：

```
[SESSION START] Target 自動決定（Q1省略）

actionable queue から Target を自動選定しました:
**Target**: <queue 先頭 item の概要>
**Queue 残り**: <queue 残数> 件
**Human-judgment bucket**: <bucket 件数> 件（停止時に summary 出力）

異議があれば「変える」と伝えてください。なければ次へ進みます。
```

ユーザーの応答を待つ（「変える」と言われた場合は 2-C へ戻る）。

#### 2-B: Codex相談（例外パス・曖昧時のみ）

以下のいずれかに当てはまる場合、人間に聞く前に Codex design-consult を実行する：

- actionable queue が空で、survey set には候補があるが metadata 不足で auto-adoptable と判定できない
- queue 先頭 item と 2 位以下が scope 競合しており優先順位が判別できない
- product-request.md に今期の優先軸が明記されておらず、queue 内の複数候補が異なる軸を要求する

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

### Continuation Policy（Target 完了後の振る舞い・batch loop）

Target の Success Criteria を満たしたら停止せず、以下のループを actionable queue が空になるまで回す。queue 空 → Stop Report 出力 → 停止。

1. **Groom + Re-scan**
   - `flutter test` と `flutter analyze`（or repo 同等のテスト・lint）でクリーン状態を確認する
   - 完了した Target の traceability.md / handoff status を更新する
   - **ステップ 1 → 1.4 → 1.5 → 1.6 を再実行**: survey set / actionable queue / human-judgment bucket を再構築する。auto-adoption も再評価（前回 skip だった consult が新たに Concrete 化していれば取り込む）。**ステップ 1.4 で auto-archive sweep も毎ループ実行**: 前ループで `archive_waiting` になった親 consult を即座に archive へ移動できる

2. **次 Target の取得**
   - actionable queue 先頭から Target を 1 件取り出す
   - queue が空なら **ステップ 5（Stop Report 出力）** へ移行

3. **Target 実行 + skip-on-stuck**
   - Target を Escalation Policy に従って実行する
   - 以下のいずれかが発生したら **stuck と判定**:
     - 設計選択が必要で自律判断不能
     - scope が不明確で着手 file が決まらない
     - 依存関係の曖昧さで先に進めない
     - テスト赤が 3 連続修正できない
   - stuck になったら:
     1. consult handoff を作成 / 更新し、`claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path> --max-rounds 1` を実行（**自己回答禁止**: `feedback_codex_handoff_no_self_answer.md` 準拠）
     2. Codex が具体推奨を返した → 適用して継続
     3. Codex が ambiguous / Human-required / 実行不能を返した → Target を **human-judgment bucket** に移動（reason source: `codex-consult-result`、詳細: Codex の一行理由）。**長期分類（IDEA filter / handoff Next Owner）は変更しない**。「今セッションでは skip」という意味
   - Target が完了（または skip）したら **ステップ 1（Groom + Re-scan）** に戻る

4. （旧ステップ 4 「Codex 推奨方針相談」は廃止 — auto-adoption と skip-on-stuck で吸収済み）

5. **Stop Report 出力 + 停止**

   actionable queue が空かつ最新 re-scan でも空のままなら、以下のテンプレートで Stop Report を task-state.md に追記しユーザーに表示して停止する:

   ```
   [SESSION START] 自律候補を処理しきりました

   実行済み:
   - <item-id>: <title> — <result / tests summary>
   - auto-adopted HO-<XXX> (parent: HO-<YYY>): <one-line>

   Auto-adoption Log:
   - HO-<n>: <Concrete | Ambiguous | Uncertain → re-consult: <Yes/No> | Idempotent skip | safety-valve> → <action>

   Auto-archive Log:（候補 0 件なら省略）
     Moved to docs/archive/:
     - HO-<n> (<title>) — moved at session-start sweep
     - HO-<m> (<title>) — moved during continuation re-scan
     Skipped (dangling references; manual review required):
     - HO-<k> (<title>) — referenced by docs/<file>:L<line>

   Human 判断が必要で残った項目:
   | item | title | reason source | reason | suggested Human action |
   |---|---|---|---|---|
   | IDEA-XX | <title> | filter (`requires-human`) | <理由要約> | <Human が次に決めること> |
   | HO-XX | <title> | handoff (`Next Owner: Human`) | <Reason for Human escalation 要約> | <Human action> |
   | HO-XX | <title> | safety-valve | recommendation touches <product-request / new REQ / 多層アーキ / 永続化> | <Human action> |
   | HO-XX | <title> | consult-ambiguous | re-consult: <Codex の一行理由> | <Human action> |
   | <item> | <title> | codex-consult-result | <Codex の一行理由> | <Human action> |

   次に Human が決めること:
   1. <最優先の判断>
   2. <必要なら次点>

   自律実行を再開する条件:
   - 上記の Human 判断を handoff / backlog / requirements に反映し、少なくとも 1 件が `auto-adoptable` または `Next Owner: Claude Code` になること

   Filter coverage 警告（該当時のみ）:
   - <repo> で IDEA 採否フィルター未付与の item が <N> 件。session-start の filter 効率が低下している可能性
   ```

   **セッション終了条件**:
   - actionable queue が空（auto-adoption 後 + 全 stuck-handling 後でも 0 件）
   - Stop Condition が連続でヒットし Codex 相談後も解決しない
   - 上記いずれかで Stop Report を出力して停止

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
- Q が自動解決された場合は、その旨を 1 行で明示する（省略したことをユーザーに見えるようにする）。新仕様（HO-146）では actionable queue が非空なら Q1 を自動省略するのが通常パス、Q2/Q3 はデフォルト値で進む
- Codex相談（セットアップ用）は Q1 のみ対象。Q2・Q3 では実施しない（スコープ設定はユーザーの意図が強いため）
- Codex相談用 handoff ファイルは一時ファイル扱い。セッション契約書き込み後も残してよい（次回の `/audit-handoffs` で処理される）
- task-state.md は Write で上書きする（追記ではない）
- 既存の task-state.md の内容は上書き前に確認不要（Write で完全置換）
- 契約作成後、確認なしで即座に実装を開始する
- 生成した Escalation Policy は「設計の選択肢が出たら Codex に相談」であり「設計の選択肢が出たら停止」ではない。契約にそのように記載すること
- Continuation Policy に従って Target 完了後も停止しない。Groom + Re-scan → queue 先頭から Target 取得 → 実行 / skip-on-stuck のサイクルを actionable queue が空になるまで繰り返す。queue 空になったら Stop Report を出力して停止
- **`claude-codex-handoff-loop.sh` の Bash 実行は以下のすべての場面で必須**: skip-on-stuck の Codex 相談 / auto-adoption の `Uncertain` binary 再相談 / auto-adoption の `Ambiguous` round 2 narrow-down 相談 / Q1 disambiguation の Codex 相談。**自己回答禁止**: 自分の判断を Codex の見解として handoff に書くことは禁止。Round 2 narrow-down では Claude Code は sub-question を generate するが、回答は決して書かない。スクリプト不実行の場合は停止 + Human 報告（`feedback_codex_handoff_no_self_answer.md`）
- **Design-consult あたりの Codex 対話は max 2 rounds**（round 1 + 1 follow-up）。Ambiguous → round 2 narrow-down 経路と Uncertain → binary re-consult 経路は別概念だが、両方を 1 つの consult に重ねがけしない。Round 2 narrow-down が ambiguous で終わったら必ず Human bucket。Binary re-consult が No で終わったら必ず Human bucket。Round 3 は無し
- **IDEA → design-consult 自動起票は per-session cap 3 件**（HO-154）。`requires-human` IDEA のうち consult-eligible 条件をすべて満たし safety-valve pre-check をパスしたものを priority 順 + IDEA 番号昇順で 3 件まで起票。残りは次セッション
- **IDEA への構造変更は idempotency marker 書き込みだけ**: skill が `docs/ideas-backlog.md` に書き込むのは `- consult-attempted: <date> → <result> (HO-XXX)` の 1 行だけ。それ以外の IDEA 本文編集は禁止
- **Auto-created consult でも `## Codex Response` を Claude Code が書くことは禁止**: handoff ファイルの structure（Goal / Context / Type / Scope / Axes / Open Questions / Ask / Next Owner / Next Action）を生成するが、Codex の応答セクションは必ず `claude-codex-handoff-loop.sh` 経由で取得する（`feedback_codex_handoff_no_self_answer.md` 準拠）
- **Auto-archive sweep（ステップ 1.4 / HO-157）は `archive_waiting` のみが対象**: `done` のみの handoff は archive しない。dangling Markdown link 検出時は skip して Stop Report `## Auto-archive Log` の Skipped 欄に記録（ループ中の確認プロンプトは出さない）。参照元ドキュメントの link 修正は自動適用しない（archive-handoffs SKILL の慣習に従う）。Sweep は session 開始時 + Continuation Policy の Re-scan ごとに実行
- **Auto-adoption の safety valve**: `## Codex Response` の recommendation が `product-request.md` / 3 pillars / non-goals / 新規 REQ / REQ 削除 / 多層アーキテクチャ / 永続化スキーマ のいずれかに触れる場合、Concrete 判定でも自動採用しない。常に human-judgment bucket（reason source: `safety-valve`）。convention は `docs/agent-handoff-template.md` および memory `feedback_consult_handoff_separation.md` と同期すること
- **Idempotency check**: auto-adoption candidate を処理する前に、親 consult の `## Decisions` に `auto-adopted: HO-XXX` の記録があるか、または親 consult を `Context` で参照する `Type: implementation` handoff が active で存在するかを確認する。いずれか該当すれば skip（重複起票しない）
- **Human-judgment bucket は survey set から削除しない**: フィルタは「実行候補から外す」だけで、ユーザー説明可能性のため survey set には残す。Stop Report はこの bucket を出力する
