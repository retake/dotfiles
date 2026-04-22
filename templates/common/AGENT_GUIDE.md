# Agent Guide

このリポジトリで `Claude Code` と `Codex` を併用するための運用メモ。

## 前提

- アプリ種別: <!-- 例: Flutter 3.x / Linux desktop, React 18 / Web, Go 1.x / CLI -->
- 主要パッケージ・ライブラリ: <!-- 例: flutter_riverpod 2.x, shared_preferences -->
- <!-- プロジェクト固有のアーキテクチャ上の特記事項を追加 -->

## 共通ルール

- 変更後は原則 `<format コマンド>` `<lint コマンド>` を実行する。ローカルテストは変更スコープに関連するファイルに絞った部分実行でよい（毎回 full run は不要）
- **CI が full suite の回帰担保を担う**（CI 設定は `.github/workflows/ci.yml` を参照）
- <!-- プロジェクト固有の不変ルール（抽象化・禁止パターン等）をここに追加 -->
- 非同期処理は dispose 後 callback を残さない
- <!-- 状態管理フレームワーク固有の注意事項 -->

## 役割分担

役割分担は、**相談前の上下関係**ではなく、**方針決定後の実行責任**として扱う。

相談フェーズの原則:

- `Claude Code` と `Codex` は対等に議論する
- 仕様、方針、優先順位が未決なら、どちらも結論を急がず対話を継続する
- 未決事項が残っている間は、実装を既成事実化しない

決定後の原則:

- 実装と実装後の検証は `Claude Code` が担当する
- レビュー、論点整理、改善提案、リスク指摘は `Codex` が担当する
- `Codex` は明示的に依頼されない限り実装を行わず、レビューと提案を優先する

### Claude Code

主担当。

- 日常の実装作業
- 連続した試行錯誤を伴う修正
- ローカル実行と hot reload を使う UI 調整
- 反復的なテスト実行
- 実装後の検証結果の整理
- 既存の `.claude/settings*.json` を前提にした開発

Claude 側はこのリポジトリ向けの権限設定と編集後 hook が入っているため、通常開発は Claude を優先する。

### Codex

補助担当。

- 変更前の設計レビュー
- 変更後のコードレビュー
- バグの切り分け
- テスト失敗の原因分析
- コミット前の差分監査
- Claude が作った変更へのセカンドオピニオン

Codex は「節目で入れる」使い方を基本とする。日常の細かい反復作業や実装の主導は担当しない。

## Codex を呼ぶタイミング

- PR 前に差分レビューしたいとき
- 仕様変更前に設計の妥当性を確認したいとき
- 修正が長引いていて切り口を変えたいとき
- テストは通るがライフサイクルや非同期処理に不安があるとき
- <!-- プロジェクト固有の非同期・状態遷移の不整合を疑うとき -->

## Claude を呼ぶタイミング

- 実装を継続的に進めるとき
- UI を見ながら微調整するとき
- ローカル実行と hot reload を何度も回すとき
- 小さな修正を連続して積むとき

## 引き継ぎ時に残す情報

- 目的
- 変更ファイル
- 実行済みコマンド
- 未解決事項
- 既知の制約
- レビュー依頼が来た場合は、**必ず** `docs/agent-handoff-claudecode-*.md` を作成し、Claude Code へ渡す
- レビュー結果は会話だけで終わらせず、原則 `docs/agent-handoff-*.md` に残して Claude Code へ渡す

短くてもよいので、次の担当がすぐ着手できる状態にする。

### テンプレートの使い分け

- **単発レビュー依頼** → `docs/codex-request-template.md`
- **継続タスク（状態が残る）** → `docs/agent-handoff-template.md`

### 継続タスクの handoff 必須項目

継続タスクでは handoff を正本とし、以下を毎回更新する:

- `task_id` — タスク単位の固定 ID（handoff ごとではない）。形式: `HO-<連番>`
- `handoff_status` — `active` / `waiting` / `blocked` / `archive_waiting` / `done` / `archived`
- `Current State` — 今どこまで済んでいるか
- `Decisions` — 決めたこと・スコープ外にしたこと
- `Planned Follow-ups` — 複数 step の方針がある場合だけ、後続 slice と停止条件を残す
- `Open Questions` — 未確定の論点
- `Next Owner` — 次の担当（Claude Code / Codex / Human）
- `Next Action` — 次担当にしてほしい具体作業

`Next Owner` と `Next Action` が未記載の handoff は未完成扱いとする。
同一タスクの後続 handoff は同じ `task_id` を使い、状態更新として束ねる。
長い修正方針を Codex セッション内にだけ保持しない。複数 step の計画を立てたら、少なくとも採用順・保留条件・後続 slice を handoff 側へ昇格してから次に渡す。

### 相談ループと修正ループ

- `Type: design-consult` は **相談ループ**
- `Type: implementation` / `review` / `bug-triage` / `audit` / `security-audit` は **修正ループ**

相談ループの原則:

- 目的は「結論を出すこと」であり、修正完了まで進めることではない
- `Claude Code` と `Codex` は対等に相談し、合意できるまで議論を継続してよい
- Human 判断待ちの間は、通常 `handoff_status: active` + `Next Owner: Human` で止める
- Human に判断を委ねる説明は、実装都合より先にドメイン言語で「誰の何がどう変わるか」「どの体験や運用差を選ぶか」を書く
- change-layer や実装詳細が必要な場合は、主説明と分けて短い補足として添える
- 相談だけで閉じた handoff は、自動では archive しない
- 長い改修案を固めた場合、consult handoff を「親」として残し、全体方針は `Decisions` と `Planned Follow-ups` に書く
- 実装へ進める時は、親 consult から独立した `Type: implementation` handoff を slice ごとに切る
- implementation handoff の `Next Action` は当該 slice だけを書く。後続 step の構想は親 consult 側に残す

**相談終了条件（AND 条件）**:
- `Decisions` に採用案と却下案が両方記載されている
- 残存する `Open Questions` にすべて `Next Owner` が明示されている（Human / Claude Code / Codex のいずれか）
- 「採用案だけ決まった」「Open Questions が曖昧に残った」状態では handoff を完了扱いにしない
- 相談論点が収束しても Human 判断や起票判断が残る間は `active` のままにし、`done` は新規運用では原則使わない

**意見不一致のエスカレーション**:
- 主条件（いずれかに該当すれば即 `Next Owner: Human`）:
  - product-layer の変更を伴う
  - 優先順位の変更を伴う
  - リスク評価が割れている
- 補助目安: 同一論点で 3 ラウンド以上収束しない場合も強制エスカレーション

修正ループの原則:

- 目的は「修正して reviewer が確認すること」
- reviewer 確認後は `archived` を基本とする
- 人間の最終判断待ちが残る場合も `active` のままにし、判断後に `archive_waiting` または `archived` へ進める
- 実装ファイルの更新は Claude Code が担当する
- handoff 上の議論・反論・妥協案の記述は Claude Code / Codex の両方が行ってよい

### Active / Archive の運用ルール

- `docs/` 直下の handoff は未 archive のもの（`active` / `waiting` / `blocked` / `archive_waiting` / `done`）を置く
- 完了・中断した handoff は `docs/archive/` へ `git mv` で移動する
- archive 条件: 全指摘が ✅ 対応済 or ⚪ 要判断で別トラックに引き継がれた
- archive 時に `handoff_status` を `archived` に更新し、`Final Outcome` を一文追記する

### レビュー指摘への応答ルール

- 指摘を受けた側は、修正完了後に自分で archive せず、`handoff_status` を `waiting` にして reviewer へ返す
- このとき `Next Owner` は元の reviewer、`Next Action` は「修正差分の確認」にする
- reviewer が指摘解消を確認した時点で `archive_waiting` または `archived` に更新する。Human 判断や別 owner の次アクションが残るなら `active` に戻す
- 軽微な文言修正や明白な書式修正でも、原則は reviewer 確認を通す
- 例外的に self-archive できるのは、reviewer が handoff 内で明示的に「確認不要」「対応後そのまま archive 可」と書いた場合のみ

**レビュー完了条件（3項目すべて満たすこと）**:
1. 既存指摘がすべて「解消済み」または「要判断として明示移送済み」
2. 修正者が示した `Tests Run` と根拠を reviewer が確認済み
3. 未対応事項があるなら `Decisions` または `Open Questions` に明記済み
- 完了は **reviewer 自身が** `handoff_status: archive_waiting` または `archived` に更新して示す。Human 判断や別 owner の次アクションが残る場合は `active` にする。修正者は `waiting` にして返すだけとし、自己判断での archive は行わない

**Codex の実装例外ルール**:
- Codex は原則として implementation files を編集しない
- 例外として編集可能なもの:
  - handoff ファイル（`docs/agent-handoff-*.md`）
  - 運用文書（`AGENT_GUIDE.md`・`docs/agent-handoff-template.md`）
- それ以外は、Human が handoff 内に**対象ファイルパスを明記して**依頼した単一ファイルの修正に限る（「最小修正」という形容詞だけでは例外として認めない）

### handoff 上の対話

- handoff は結論だけを書く場ではなく、反論・懸念・妥協案を書く場として使ってよい
- Codex と Claude Code は同じ `task_id` の handoff 上で応答を重ねてよい
- 反論する場合は、相手の判断を否定するだけでなく、理由と代替案をセットで書く
- 結論が変わった場合は `Decisions` を更新し、古い案を `Notes` や対話ログに落とす

### 長い修正方針の残し方

- Codex が 3 step 以上の修正方針を考えたら、その要旨を会話だけで終わらせず handoff に残す
- 推奨形は次の 2 層:
  - 親: `Type: design-consult`。採用方針、却下案、`Planned Follow-ups`、各 slice の着手条件を保持する
  - 子: `Type: implementation`。今すぐ実行する 1 slice だけを対象にする
- 親 consult は「なぜこの順番か」「step 2 以降をいつ開くか」を残す場所として使う
- 子 implementation は「今回どこまで触るか」「完了条件は何か」を残す場所として使う
- 後続 slice を開く時は、親 consult を参照元として明記し、必要なら `Planned Follow-ups` を更新してから新しい implementation handoff を切る

### Codex から Claude への relay 方法

- この repo では、Codex から Claude Code への relay は **handoff に明示指示を書いて渡す運用**を標準とする
- 推奨フロー:
  - Codex が handoff を作成または更新する
  - `Ask` に、参照してほしいファイル・禁止事項・返答してほしい節見出しを**明示指示として書く**
  - その handoff を Human または Claude Code に渡す
  - Claude の返答が得られたら、handoff の `Claude Code Response` へ転記する
  - その返答を踏まえて、トップレベルの `Decisions` / `Open Questions` / `Next Owner` / `Next Action` / `handoff_status` を Codex 側で確定する
- `Ask` は「そのまま Claude に読ませれば返答できる明示指示」にする
  - 見てほしいファイル
  - 実装してよいか / 調査だけか
  - 返答してほしい節見出し
  - 除外したい論点
  - 返答を短く絞る条件
- `Ask` やテンプレート内の記入例に `## Next Owner` / `## Next Action` などの見出しをコードブロックで埋め込まない。必要なら prose で「返答末尾に次担当と次アクションも追記」と書く

### Tests Run の最低要件

handoff の `Tests Run` 欄には以下を**すべて**記載する（省略時は理由を明記する）:

- 実行したコマンドとその出力（抜粋可）
- 実施しなかったコマンドがある場合はその理由
- 手動確認が必要なケースは再現手順

handoff template の `Tests Run` 欄はこの要件への参照とし、両方に全文を書かない（乖離防止）。

### Claude Code 並行実装時の worktree ルール

- `Type: implementation` の handoff が 2 件以上 `active` になる場合、Claude Code の各実装は原則として別 `git worktree` で行う
- `design-consult`、`docs-only`、handoff 更新のみのタスクでは `git worktree` を必須にしない
- 各 implementation handoff には、開始前に `worktree` のパスまたは識別子を記載する
- 各 implementation handoff の `Scope` には `Files` と `Out of scope` を必ず書き、active な handoff 同士で実装ファイルを重複させない
- dirty な既定 worktree に未確定変更がある場合、そのファイルを別 handoff の実装対象にしない
- テスト実行や生成物を書き込む検証は worktree を分けても衝突しうるため、同時実行せず直列で回す
- 実装中に別 handoff の担当ファイルへ触れる必要が出たら、scope を更新せずに続行せず、`handoff_status: blocked` または `waiting` にして返す

## Codex 側で最低限揃える承認

<!-- プロジェクトの言語・ツールに合わせて埋める。例: -->
<!-- dart format, flutter analyze, flutter test, flutter run, flutter build -->
<!-- go test, go build, go vet -->
<!-- npm test, npm run lint, npm run build -->

Claude と完全に同じ権限セットへ寄せる必要はない。Codex は補助担当なので、よく使うコマンドだけ事前承認しておけば十分。

## プロジェクト固有の注意

<!-- プロジェクト固有のトラップ・注意事項をここに列挙する -->
<!-- 例: パッケージ名の変遷、アセット命名規則、競合する設定値、即時発火タイミング等 -->

## モデル運用

- 上位: 設計判断、非同期バグ、状態遷移、レビュー
- 中位: 通常実装、局所修正、テスト追加
- 軽量: handoff、要約、整形

原則:
- モデル切替はセッション開始時に手動で行う
- 同一タスクの途中ではむやみに切り替えない
- small タスクで上位モデルを常用しない
- `orchestrate` を使う価値がある重いタスクでは上位を優先する

## 要件の 4 層運用

要件は次の 4 層で扱う（詳細は `docs/ideas-backlog.md` の「要件レイヤリング方針」節を正本とする）。

| 層 | 正本 | 内容 |
|---|---|---|
| Request Layer | `docs/product-request.md` | 「誰の何を解くか」の要求定義（why）。Product Layer の上位正本 |
| Product Layer | `docs/requirements.md` | プロダクトが継続して守るべき振る舞い（what） |
| Change Layer | `docs/agent-handoff-*.md` / `docs/archive/agent-handoff-*.md` | 特定改修の実装条件・受け入れ条件（how） |
| Direction Layer | `docs/ideas-backlog.md` | 長期方針・persona・ユーザーストーリー・未決 IDEA |

### REQ 追加時の判定ルール

新しい事項を `requirements.md` に書く前に、以下を確認する:

0. **request-layer か?** — 「誰の何を解くか」「何を優先するか」「何をしないか」のレベルの変更 → `docs/product-request.md` に書く。REQ は追加しない
1. **product-layer か?** — 外から観測できる振る舞いで、特定改修に閉じない → `requirements.md` に REQ として追加
2. **change-layer か?** — 実装詳細（閾値・ウィジェット名・コマンド引数等） → handoff の `Acceptance Criteria` または `Scope` に書き、`requirements.md` には振る舞い要約だけ載せる
3. **direction-layer か?** — 未確約のアイデア・長期方針 → `ideas-backlog.md` に追加

迷ったら change-layer に置いて、昇格条件（3 件以上の後続参照・ストーリー直結・不変条件・Guardrails 抵触）を満たした時点で product-layer へ昇格する。

Human 判断が必要な相談文では、request-layer / product-layer を先に書き、change-layer は補足に回す。
つまり「内部でどう実装するか」より「利用者にとって何が変わるか」「どの運用判断を求めているか」を前面に出す。

#### 後の REQ が前の REQ を制約する場合の cross-reference ルール

後の REQ が前の REQ を制約・上書き・前提とする場合は、以下を必ず行う:

- 後の REQ 本文に「`REQ-XX` の挙動を制約する」と明記する
- 前の REQ の `requirements.md` 該当行に「`REQ-YY` により制約あり」の注記を追記する
- `traceability.md` の前の REQ 行の備考欄に後の REQ を記載する

実装 handoff を開く前に、対象 REQ の先行 REQ との制約関係をすべて解消しておく。
未解消の競合が残っている場合は、`Next Owner: Human` で相談ループに差し戻す（stop condition）。

#### `requirements.md` の制約条件節は product-layer

`requirements.md` の「制約条件」節は REQ 本文と同等の product-layer 権威を持つ。
change-layer や実装との乖離は REQ 本文の乖離と同等に扱い、検出時は downstream sync の対象とする。

#### product-layer に書かない詳細（change-layer に置く）

以下は `requirements.md` に書かず、handoff の `Acceptance Criteria` / `Scope` に書く:

- 内部状態名・ステージ番号・段階閾値
- ウィジェット名・レイアウト構造名
- アセット名・バックエンド固有の動作
- 設定変数名・実装レベルの数値・内部遷移名

#### サブカテゴリ対応表

新しい REQ を追加・分類する際は、以下のサブカテゴリを参照する（プロジェクト開始時に埋める）。

| カテゴリ | サブカテゴリ | 対応 REQ |
|---|---|---|
| 機能要件 | <!-- カテゴリ名 --> | <!-- REQ-N/N/N --> |
| 非機能要件 | <!-- カテゴリ名 --> | <!-- REQ-N/N/N --> |

### requirements 変更後の downstream sync

`requirements.md` を編集した場合は、必ず `docs/traceability.md` の該当 REQ 行・ソースコードの `// @req` 注釈・テストコメントの downstream sync を確認する。

## 運用方針

- 通常開発は Claude
- 節目の確認とレビューは Codex
- 相談は対等、実行責任は決定後に分担する
- 両者に同じ設定を複製して二重管理しない
- 共通ルールはこのファイルに集約し、片方のエージェント固有設定には閉じ込めない
