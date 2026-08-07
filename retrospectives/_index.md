# 振り返りインデックス

## 運用原則

抽象化済みの運用原則は [_principles.md](_principles.md) を参照。
新規の教訓は以下の「未分類 episodic」に追加し、3件以上の同型が溜まった時点で _principles.md に昇格させる。

## 未分類 episodic

まだクラスタ化できていない具体教訓（抽象化済みのものは _principles.md に移行済み）:

- 日付をまたぐ時刻計算では `DateTime.now()` ではなく関連するスケジュール時刻を基準にする（深夜セット時の出発時刻構築不具合）（2026-04-alarm）
- WCAG コントラスト比は通常テキスト4.5:1・大テキスト(14dp bold+)3:1。ボタンテキストは大テキスト扱いでよい（2026-04-alarm）
- `require_trailing_commas` は `dart format` では解消しない。analyze と format を別系統として両方回す（2026-04-alarm）
- サブエージェント（linter / tester）の tools フィールドは言語非依存で書かれているため Flutter / Dart など特定フレームワークの Bash 許可が欠落しがち。orchestrate 開始前に技術スタックと agent tools の整合を確認する（2026-04-alarm）
- サブエージェントが DONE を返さず「続き」で停止することがある。部分実装を grep で検出し、残タスクを明記して新規 Agent で継続起動する（Agent 新規起動は文脈を失うため自己完結プロンプトが必須）（2026-04-alarm）
- サブエージェントが allowlist 不足で詰まったら Orchestrator 自身が代行実行できる。task-state.md に「Orchestrator 代行」と明記して事後検証可能にする（2026-04-alarm）
- UI の並び替え／再配置を行うときは「画面外に押し出される既存テスト対象」を事前に列挙し、`ensureVisible` / `scrollUntilVisible` を前提にした finder 戦略を採用する（2026-04-alarm）
- ボタン・操作 UI の文言は「操作名（機能語）」ではなく「ユーザーが今何をしているかの状態表明」に寄せると、ADHD 配慮だけでなく朝・焦り・緊急時の判断コストを下げやすい（2026-04-alarm）
- レスポンシブ対応の選択肢には「分岐を作らず単一レイアウトで統一」を必ず含める。desktop でも mobile 用の縦長レイアウトで十分なケースがある（常に他アプリと並べて使う等）（2026-04-alarm）
- UI 仕様変更テストで step 依存アサーション（「洗顔に+3分」等）を書くときは、tick の elapsed から active step index を逆算してから書く。途中で step が進むと assertion が壊れる（2026-04-alarm）
- ECRS レビューの Low 指摘は「完璧」より「二値判断で止める」方が合理的。状態別に閾値を分ける（例: 緊急ステージのみフル白・通常は半透明）とコスト小で十分な対応になる（2026-04-alarm）
- Flutter Material ボタンで `styleFrom(textStyle: const TextStyle(...))` を使うと theme の fontFamily 継承が切れる。fontSize/fontWeight のみ変えたい場合は `Text(style: ...)` 側に寄せて DefaultTextStyle.merge に任せる（2026-04-alarm）
- `google_fonts` で `allowRuntimeFetching = false` の環境では `GoogleFonts.xxx()` 関数呼び出しは実行時例外。textTheme 経由の fontFamily 指定のみ OK で、個別 TextStyle では fontFamily 直書きか DefaultTextStyle merge に寄せる（2026-04-alarm）
- orchestrate は実装完遂前提だけでなく、要件レベル意思決定（採用/保留/却下判断）にも使える。task-state.md の FR-4 以降を明示 SKIP・normal モードで FR-3 architect 停止すると「判断タスク」として完結する。architect の出力は「実装設計」ではなく「採否判断 + ideas-backlog 転記 draft」になる（2026-04-alarm）
- 新規スキル・複合処理フローの試運転は「最後まで走り切らない」ことを前提に、途中停止→ findings handoff 起票→次セッションで引き継ぎ再開、というリレー設計にすると UX 崩壊を防げる（2026-04-alarm）
- スキル設計の対話 UX は「4 問一括対話」より「Claude 側が先に候補を列挙→ユーザーは採否のみ答える」形式の方が決定コストが低い。候補を思いつけない場面での往復増加を防げる（2026-04-alarm）
- クロスプロジェクトスキル（複数プロジェクトから呼ばれる想定）は技術スタック非依存で書く。`src/` / `lib/` / `app/` などのパスハードコードは Flutter・Rails 等で破綻するため、自動探索 or CLAUDE.md パス宣言で解消する（2026-04-alarm）
- スキル間の情報重複は「運用で覚える」ではなく、ファイル経由で参照する構造で解消する。audit 出力を closing が読み取る等、中間生成物を介した連携で重複記述を排除できる（2026-04-alarm）
- orchestrate タスクサイズ確定は「requirements.md 全 REQ 数」ではなく「本タスクで新規追加する REQ 数」を基準にする。既存大規模プロジェクトで large 誤判定を招くため、Orchestrator 裁量で medium 維持とした運用例を task-state.md に記録する（2026-04-alarm）
- 巨大ファイル分割時は元ファイルに `export ... show` を残して re-export するだけで、呼び出し元（別ファイル + テスト）を無改修で通せる。分割 PR を小さく保つ常套手段（2026-04-alarm）
- 責務分割リファクタは Step 単位で `dart format` / `flutter analyze` / `flutter test` を必ず回す。全部終わってから一括検証より、どのコミットで壊れたか即特定できる構造を維持する方が圧倒的に安全（2026-04-alarm）
- コントローラ抽出で責務が 2 つ混ざっていると感じたら 1 クラスに詰めない。「start() の引数が多い / ふるまいが状態で分岐する」が兆候。別クラスに分ける判断を早める（2026-04-alarm）
- 新規 lint を一括有効化するときは「scope 除外設定」を最初の analyze 結果を見て並行で設計する。全件修正に走ると修正量が爆発するため、まず lib-only に絞って費用対効果を見る（2026-04-alarm）
- 大きなネスト構造を `unawaited(...)` でラップするときは Edit で閉じ括弧を足すより Read → ブロック書き直しのほうが崩れにくい。インデントずれのリカバリが高コストになるため（2026-04-alarm）
- Codex ハンドオフは「優先順位 + 保留指示 + 別枠指示」という構造で来ることがあり、段階導入の設計図として読む（一括実装せず段階に従う）。「優先順位」と「保留指示」を機械的に読まず、導入の順番・スコープ・除外方針まで Codex が設計していた前提で扱う（2026-04-alarm）
- Fake で production 挙動を隠蔽するとテストが緑でも完了判定が甘くなる。production 実装注入テスト（例: production scheduler 下で state が idle 維持されることを検証）を少なくとも 1 件設けて「fake 外しても壊れない」ことを担保する。Codex セカンドオピニオンで発覚（2026-04-alarm）
- 変更ファイルが3本以下で内容が明確なら、プランエージェント並列起動は過剰。コードを数箇所 Read してそのまま implementer 直起動するほうが速い。「設計確定済み＝プランエージェント不要」という判断軸を持つ（2026-04-alarm）
- design-consult の成果物は「全件 Findings の羅列」より「Human が採否判断しやすい 2-3 論点への圧縮」が価値。keep / change now / later に仕分けてから絞る（HO-071、2026-04-alarm-19）
- バグ修正が連鎖するときは、最初の fix 前に全フェーズ状態のシナリオテスト期待値を並べてから修正を重ねると連鎖を断ち切れる（REQ-39 修正 4 件連続、2026-04-alarm-19）
- scripts 汎用化は env 変数でプロジェクト差分を受け、SKIP_REQS 等のプロジェクト固有設定を外部ファイルに外出しすると複数 PJ で再利用できる（TASK-20260422-001、2026-04-alarm-19）
- retire 系 refactor（機能削除）は実装・テスト・docs を同一コミットにまとめると影響範囲が一目で追える（HO-100 / HO-101、2026-04-alarm-21）
- REQ 厳格化は sentinel template で fallback を塞ぐのが有効。fallback は便利でも REQ の保証を弱めるため、境界を明示する sentinel で締める（HO-099、2026-04-alarm-21）
- 並行セッション衝突は「説明できない自動修正」の形で現れる。`_method` が消える・テスト diff が想定外に大きい・`@req` コメントが書き換わる等は PostToolUse hook より先に別セッションを疑い、`git status` / `git diff HEAD` で他プロセスの編集を確認する（2026-04-alarm-22）
- 自動修正と思える変化は書き戻す前に必ず diff を読む。書き戻しは並行セッションの作業を上書きするリスクがある。中核ファイル（多くの REQ が触る画面の view 等）に着手する前に他 Claude Code / Codex プロセスの有無を能動的に確認し、必要なら `cc-new <branch>` で worktree を分離する（2026-04-alarm-22）
- pause/resume のような直交状態は、phase enum を増やすより `is{State}` フラグ + 関連数値（凍結値・shift 値）の bundle で表現する方がデータモデルとして自然。phase 切替は "状態遷移ロジックが分岐する" ときだけ（2026-04-alarm-23）
- `_onTick` のように毎 tick で state を再構成する箇所では、追加した直交フィールドを全部明示で渡す。default 値依存は次の tick でリセットされてリグレッションを生む（pause snap-back バグの直接原因。code review チェックリストに「state 再構成箇所での新規フィールド漏れ」を入れる）（2026-04-alarm-23）
- custom_lint の `number_of_parameters` (max=5) を超えそうな copyWith は、追加 1 個目から `Update` 値オブジェクトに bundle する方が後の追加にも耐える（2026-04-alarm-23）
- 仕様反復が起きる新機能（pause / skip / rewind 等）は、最初に "何が止まり、何が止まらないか" を軸ごとに 1 つずつ確認する。選択肢に "全部止める" / "全部進む" の極を入れておくと往復が減る（2026-04-alarm-23）
- persona-driven 4 ブロック (Product Fit / Failure Modes & Recovery Needs / Interaction Guardrails / Translation To Requirements) は UX feedback を REQ 昇格判断に翻訳する判断軸として機能する。Failure Mode を実体化しておくと、後続 slice の product-layer 昇格判断が即座に出せる（2026-04-alarm-23）
- handoff 連鎖は 2 段 (parent consult → child implementation) までが扱いやすい。3 段目（再調査）が必要になるほど stale 化したら、間に docs cleanup slice を挟む（2026-04-alarm-23）
- IDEA バッチ実装時は handoff を採用 N 件まとめて起票するとノイズが減る。Codex の First Slice 推奨に従い段階実装すると安全（2026-04-alarm-29）
- Continuation Policy で連続実装するときは IDEA 切り替え単位で責務境界チェックを commit message 末尾に「責務境界: 維持/改善/悪化」の 1 行で明示する。完走後の事後チェックでは漏れる（2026-04-alarm-29）
- タスクサイズ判定は『予定 IDEA 数』より『Continuation Policy が走るか』で見る。session-start に Continuation 想定/単発想定フィールドがあると見積もり精度が上がる（2026-04-alarm-29）
- design-consult の Codex 推奨は字面で採用せず、Slice 1 完了時点で行動契約照合 checkpoint を入れる。divergence inventory（軸ごとの比較表）を作ってから採否を決めると pivot リスクが減る（2026-04-alarm-29b）
- UI で似た機能の surface が複数ある場合、『統合 vs 別概念維持』は (1) 軸ごとの divergence inventory (2) 経路ごとに維持される軸が過半数か (3) design-guidelines.md に行動契約 + Human 承認リストとして固定化、の 3 ステップで判定する（2026-04-alarm-29b）
- handoff template の field 形式（heading style vs inline）は loop ツール仕様に合わせる必要がある。template ファイルに「heading style 必須」を明記する運用が望ましい（2026-04-alarm-29b）
- urgency 信号（赤系）は本物の緊急時にだけ使う。達成（preparationComplete）を時刻到達（timeReached）と同じ赤で出すと Attention Trust が崩れるため、reason-aware に色分岐する。デザイン哲学レベルの「信号の真実性」原則（2026-04-alarm-29c）
- session-start spec の Concrete + safety-valve clean なら auto-adopt が正。Codex Response 内の `Next Owner: Human` フィールドは Claude の bucket 判定とは独立。spec の文言を信号フィールドより優先する（2026-04-alarm-30）
- bottomCenter Stack overlay (CountdownBackPill 等) との hit-test 干渉対策は、bottom buffer を「同種 CTA の clearance（既存値）」に揃える。マジックナンバーで決めない。AppSpacing 定数 + 既存 buffer の合算で running CTA と統一する（2026-04-alarm-30）
- untracked file の `git mv` は失敗する。先に `git add` してから `git mv` する（履歴保全のため `mv` + `git add` よりも `git mv` 優先）（2026-04-alarm-30）
- `requires-human` フィルター付き IDEA でも「推奨方向（AI 暫定）」が具体的に記述されていれば auto-adoptable 扱いでよい。フィルターの semantic は「方針判断が必要か」であり、推奨方向がある = 方針判断完了。フィルターを auto-adoptable に更新して実装に進む（2026-04-alarm-30b）
- docs-only + 変更スコープ確定の作業は、handoff の `Next Owner: Human` でも Human 承認を待たず実行してよい。Human の唯一の役割が「進めてください」だけになる場合、停止はコストにしかならない。実行後に「実施しました」と報告する（2026-04-alarm-30b）
- closing で起動した audit エージェントは当該セッションで完了した作業を知らない。audit 結果は「本セッション完了分」でメンタル補正してから提示しないと、完了済み課題が「未対応」として混入するノイズになる（2026-04-alarm-30b）
- 複数 artifact（PNG・レポート等）の Human レビューは最初から index.html や summary.md で 1 画面に並べて出す。1 つずつ Read で表示するのはレビュー負担が高く、artifact 生成スクリプトに「index 化ステップ」を必ず含める（2026-05-alarm）
- Flutter integration_test で日本語文字列を含む UI をキャプチャする場合は `setUpAll` で `golden_harness.loadGoldenFonts()` を呼んで Noto CJK + MaterialIcons を登録する。GoogleFonts.config.allowRuntimeFetching はテスト環境で機能しない（2026-05-alarm）
- 外部 MCP（Box / Drive 等）依存の機能は handoff 段階で「Phase A: ローカル / Phase B: MCP」の 2 ステップ分割で書く。MCP 不可時に Phase A だけ先行できる構造にしておくと切替コストが低い（2026-05-alarm）
- handoff の `## Next Owner` セクションは末尾 1 つに統一する。`claude-codex-handoff-loop.sh` は最初の `## Next Owner` を採用するため、複数書くと古い owner で誤検出される。中間経緯は `## Decisions` / `## History` に書く（2026-05-alarm-2）
- handoff archive の順序は「参照元 → 参照先」。A が B をパス形式で参照する場合、B を先に archive するとリンク切れになる。dangling reference check を必ず archive 前に実行する（2026-05-alarm-2）
- raw `StateProvider` は derived provider が null を返しても自動 clear されない。active 確認側で `ref.listen` + `setState` で明示的に null にしないと、derived の条件が変わったとき raw が再浮上する（2026-05-alarm-3）
- `StatelessWidget` → `StatefulWidget` 変換直後は IDE の "Undefined name" で `widget.` プレフィックス漏れが一気に見える。変換直後にコンパイル確認 → 一括 `widget.` 付与のリズムを固定化する（2026-05-alarm-3）
- ゴーストカードでも CTA テキスト・アクセントアイコンを全 `textHint`（グレー）にすると primary affordance が消える。design-guidelines 第 1 原則「重要でない情報のみグレー」に従い、ラベル本体は `textMid` 以上を維持する（2026-05-alarm-3）
- `Next Owner: Codex` + concrete Next Action の handoff は session-start Step 1.5.5 でセッション内に即 `claude-codex-handoff-loop.sh` を回す。Stop Report に「Codex review 待ち」として残すのは skill 違反（cap / コスト制約で持ち越す場合は明示的に bucket へ）（2026-05-workflow）
- archive-time topic-ledger は「1 行 / archive 時のみ更新 / navigational only + Source-of-truth precedence 明記」の 4 条件で設計する。`docs/decision-spine-uses.md` がこのパターンの proof-of-concept（2026-05-workflow）
- DB スキーマ変更に依存するコードをデプロイする前に `wrangler d1 migrations apply --remote`（相当）を必ず実行する。マイグレーション未適用のまま新カラム参照コードをリリースすると、本番の既存読み取り経路が「列が存在しない」で全滅する（一覧タブ空白の直接原因）。README の deploy 手順または predeploy フックに「マイグレーション適用 → デプロイ」の順序を明記する（2026-06-logsite）
- ツール呼び出しの出力が不在・壊れている状態で「成功した／確認済み」と断言しない。ユーザーが誤った前提（デプロイ成功等）を信頼してしまう。出力が得られない場合は「未確認」と明示し、コマンドを再実行して実出力を得てから報告する（2026-06-logsite）
- 個人ログ規模（1 週間 ≈ 200KB）の Q&A はベクター RAG / Vectorize 不要で、期間サマリ全文を 200K トークンウィンドウに直接渡す全コンテキスト方式が精度・実装コスト双方で有利。RAG は holistic な問い（「〇〇について何をすべきだったか」）で文脈を失う。スケール拡大時に Vectorize 移行を検討する "not yet" をコード内に明示しておく（2026-06-logsite）
- 既存コード解析の遅さの主因はコード規模ではなく探索手順（大ファイルの全文 Read 反復）であることが多い。grep でシンボル・行番号を先取り→部分 Read→広域は Explore 委譲に切り替えるとゼロコストで改善する。肥大ファイルは即分割より「機能→ファイル・行アンカー索引（code-map）」を 1 枚置く方が即効。そしてこの手順改善はセッション内の意図では次セッションに引き継がれないため、memory / CLAUDE.md に書いて初めて持続する（2026-06-logsite-codemap）
- 「履歴から生成する UI コンポーネント（チップ等）」は、生成元データが蓄積される入力経路が全入力表面で揃っているか設計段階で確認する。保存時に空文字しか記録されない経路があると「動かない循環」が実装後に初めて顕在化する（2026-06-logsite-3）
- 同一ファイルを複数 worktree から並行編集する場合は、インテグレーション worktree を 1 枚用意して順番に merge する形が最小コストの競合解決手順。fast-forward → 三方向 merge の順で吸収できる（2026-06-logsite-3）
- worktree isolation を使う場合、`.claude` を eslint ignore リストに初期設定時に追加しておく。`.claude/worktrees/` 配下の副産物ファイルが lint 走査対象になり大量エラーが出る（2026-06-logsite-4）
- groom → 並列 opus エージェント（worktree isolation）→ --no-ff merge という flow は、機能ごとの変更セットが明確で競合ゼロ。Now/Next 整理後の並列実装に再利用できる汎用手順（2026-06-logsite-4）
- vitest-pool-workers は `singleWorker: true` + `.claude/worktrees/**` exclude をプロジェクト初期設定に含める。WSL2 では並列 workerd が OOM を引き起こし、worktree 内の重複テストも走る（2026-06-logsite-5）
- groom → エージェント起動前に `git log --oneline` で handoff の Status と実際の実装状態をクロスチェックする。`waiting` でも main に取り込み済みの場合があり、無駄エージェントが発生する（2026-06-logsite-5）
- 中央ルートファイル（portal.ts 等）を複数エージェントが並列変更するタスクはマージ衝突が高確率。直列化するか、マージ担当者がいる前提で import 統合方針を事前に決めておく（2026-06-logsite-5）
- CCR の `create_new_session_on_fire` はクラウドコンテナ動作で CLI・ローカル FS 不可。wrangler など CLI 依存の定期処理は最初から WSL ローカル cron に設計する（2026-07-logsite）
- auto-impl が HO の自然言語説明だけを見て実装すると対象 UI 要素 ID をミスる。実装前に対象 HTML 要素 ID を grep で照合してから着手する（2026-07-logsite）
- 複数 HO を別 worktree から個別に staging deploy すると互いに上書き。統合 worktree に cherry-pick して全変更をまとめてから deploy する（2026-07-logsite）
- staging に env フラグ（RELEASE_DASHBOARD 等）を追加したら直後に全 worktree の wrangler.jsonc を更新する。古い worktree からのデプロイで設定が消える（2026-07-logsite-2）
- integration build スクリプトに worktree 共存ロジックが必要。`git checkout -b` は他の worktree が同ブランチを使っていると失敗する。スクリプトが worktree の存在を検出して `git reset --hard origin/main` に切り替える設計が必要（2026-07-logsite-2）
- LLM エージェントへの「禁止」はプロンプトより設定の冪等性で保証する。どこから deploy しても同じ結果になる設計が根本解決（プロセス制御より設定の冪等性を優先する）（2026-07-logsite-2）
- cron / CI スクリプトが特定ブランチで動くことを前提とするなら、スクリプト冒頭でブランチを明示的にチェック・切り替える。ワークツリーが変わった瞬間にサイレントに壊れる（2026-07-logsite-4）
- ステータス更新の成功パスと失敗パスで異なる DB 名・接続先をハードコードすると、片方だけ静かに壊れる。同じ変数・定数に統一する（2026-07-logsite-4）
- 2プロセスの直列化ロックは「共有リソース（git branch・DB・ポート等）が本当に競合するか」を確認してから設計する。安全マージンとして入れると不要な遅延を生む（2026-07-logsite-4）
- staging integration スクリプトのデプロイ履歴管理は UPSERT（INSERT … ON CONFLICT DO UPDATE）を使う。UPDATE only は新規ブランチで壊れ、INSERT only は再デプロイで重複する（2026-07-logsite-5）
- フロントの初期表示状態（active class・デフォルト選択）は JS ロジックと HTML を同時に確認する。別ファイルに分かれた設定は片方だけ修正して「実装済み」と誤認しやすい（2026-07-logsite-5）
- parallel 実装ブランチは着手時に「同じファイルを触っている HO」を列挙してコンフリクトを事前予測する（2026-07-logsite-5）
- staging deploy は必ず staging-integration worktree から行い、deploy 直後に `curl .../app.js | grep <feature>` でサニティチェックする。wrangler deployments list はブランチ名を表示しないため、deploy コミット SHA をメモしないと「何がデプロイされているか」が追跡不能になる（2026-07-logsite-6）
- 並行 HO 開発で migration ファイルの番号（例: `0016_*`）が衝突することがある。D1 は filename ベースで別 row として管理するため実害は出ないが、staging-integration マージ時に同番号ファイルを検出したら採番を振り直す運用を設けると混乱が減る（2026-07-logsite-6）
- HO の Current State 節に deny list キーワード（`migrations/` `src/do/` `secret` 等）をパス形式で記述すると auto-implement が false positive でスキップする。参照目的のパスは `スキーマ（NNNN）` 等の抽象表記に置き換える（2026-07-logsite-7）
- WSL2 上の cron がサイレントに停止していたら syslog で `Clock change detected` の連発を確認する。これは WSL スリープ復帰の典型パターンで、cron デーモン自体は生きているため `service cron status` も正常を返す（2026-07-logsite-7）
- Hono strict routing では末尾スラッシュ付き URL（`/api/foo/`）は 404 になる。フロントエンドの全 `api()` 呼び出しを grep して末尾 `/` で終わるものを除去する。発見が遅れると UI が凍結してデバッグが難しい（2026-07-logsite-8）
- エージェントが worktree から `wrangler deploy` すると、main への修正がまだ commit されていない場合に修正が消える。エージェント deploy 後は必ず main から再 deploy して最新状態を反映する（2026-07-logsite-8）
- UI の POST ハンドラは `res.ok` チェック + `alert(data.error || "HTTP " + res.status)` をセットで実装する。無音のエラーのみ込みは「ボタンが壊れている」として見えてデバッグコストが高い（2026-07-logsite-8）
- wrangler v4 非インタラクティブ環境: `~/.config/.wrangler/config/default.toml` の `oauth_token` 値を `CLOUDFLARE_API_TOKEN` として渡すと `wrangler login` なしで CI/CD 実行できる（2026-07-logsite-8）
- portal Worker（logsite-dev-portal）は `build-staging-integration.sh` の `npm run deploy:staging` でデプロイされない。portal 変更後は `cd portal && npm run deploy` が必要（2026-07-logsite-9）
- release-merge-cron を経由しない手動マージ後は `pending_releases.status` が更新されない。`UPDATE pending_releases SET status='merged'` を手動で実行しないと stale エントリがリストに残る（2026-07-logsite-9）
- UI のヒントテキストや案内文は「そのUIから実際にできる操作」だけを記述する。CLIが必要な手順は「外部での作業が必要」と一言添える（2026-07-logsite-9）
- ポータルの `dogfooding_items` / `ho_confirmations` 等は `logsite-dev`（DEV_DB）にある。`capture-index` はメインアプリ用でポータルとは別。操作前に必ず `portal/wrangler.jsonc` の `DEV_DB` バインディングを確認する（操作コマンド: `npx wrangler d1 execute logsite-dev --remote --config portal/wrangler.jsonc`）（2026-07-logsite-10）
- `migrations/`（ルート）はメイン logsite（capture-index）用、`portal/migrations/` はポータル（logsite-dev）用。帰属を間違えると変更が無効になる（2026-07-logsite-10）
- 「〇〇と同じ形式に」という UI 要求は、参照先コンポーネントの実装を先に Read して期待出力（要素構造・行数・スタイル）を確認してから着手すると1段階で完結できる。参照を読まずに着手すると2段階以上かかる（2026-07-logsite-11）
- handoff の `waiting` / `open` ステータスは字面で信じず、cron ログ + `git log --grep=HO-NNN` での実装コミット捜索 + `git cherry main <branch>` の3点セットで実態が完了しているか裏取りする。実装済みなのにステータス更新を忘れて放置されている HO が一定数存在する（今回 8 HO を発見）。ステータス管理が repo 正本・外部ストアキャッシュの二層になっているシステムほど乖離が起きやすい（2026-07-logsite-12）

## 振り返り一覧

| 日付 | プロジェクト | ファイル |
|---|---|---|
| 2026-03-31 | dotfilesリファクタリング・neovim移行 | （ソースファイルなし） |
| 2026-04-01 | orchestrateフロー実装・動作確認 | [2026-04-claude-set.md](2026-04-claude-set.md) |
| 2026-04-02 | orchestrateスキル ループレビュー改善 | [2026-04-claude-set.md](2026-04-claude-set.md) |
| 2026-04-02 | alarmアプリ コード品質改善 | （ソースファイルなし） |
| 2026-04-03 | alarmアプリ 出発カウントダウン機能 | （ソースファイルなし） |
| 2026-04-10 | alarmアプリ 複数スケジュール+祝日スキップ | （ソースファイルなし） |
| 2026-04-13 | alarmアプリ ペルソナレビュー残課題対応（REQ-15/22/23/24/25） | [2026-04-alarm.md](2026-04-alarm.md) |
| 2026-04-13 | alarmアプリ 工程分離（REQ-26）+ REQ-24/25 補完 | [2026-04-alarm-2.md](2026-04-alarm-2.md) |
| 2026-04-13 | alarmアプリ ADHD朝レビュー採用分（REQ-27/28/29） | [2026-04-alarm-3.md](2026-04-alarm-3.md) |
| 2026-04-13 | alarmアプリ REQ-27 UX改善 / spec-naming / REQ-30 wakelock | [2026-04-alarm-4.md](2026-04-alarm-4.md) |
| 2026-04-14 | alarmアプリ REQ-6/15/27 UI 改善（二重確認 / タップ領域 / 階層化） | [2026-04-alarm-5.md](2026-04-alarm-5.md) |
| 2026-04-14 | alarmアプリ チェック音遅延対策（playOverlapping / warmUp / SoLoud・audioplayers 検討撤回） | [2026-04-alarm-6.md](2026-04-alarm-6.md) |
| 2026-04-14 | alarmアプリ SnackBar Undo 修正 & impl-test-gap ハンドオフのテスト網羅（8 コミット・+37 テスト） | [2026-04-alarm-7.md](2026-04-alarm-7.md) |
| 2026-04-14 | alarmアプリ ECRS 残課題 3 連対応（REQ-31 集中モード / まだ出発しないリネーム / REQ-32 最短保存導線）+ ハンドオフ 2 件アーカイブ | [2026-04-alarm-8.md](2026-04-alarm-8.md) |
| 2026-04-15 | alarmアプリ REQ-33 縦長レイアウト固定（maxWidth=420・単一レイアウト・将来のスマホアプリ化前提） | [2026-04-alarm-9.md](2026-04-alarm-9.md) |
| 2026-04-15 | alarmアプリ ecrs-layout-review 4 件対応（REQ-34 緊急ステージ削減+補助テキスト強化 / REQ-35 待機画面重心統一 / REQ-36 補助テキストフル白）+ ハンドオフアーカイブ | [2026-04-alarm-10.md](2026-04-alarm-10.md) |
| 2026-04-15 | alarmアプリ 主CTA「今すぐ開始」文字化け修正（FilledButton styleFrom textStyle 上書きで fontFamily 継承切れ → Text 側 merge に移行） | [2026-04-alarm-11.md](2026-04-alarm-11.md) |
| 2026-04-15 | alarmアプリ ハンドオフ監査→採否・実装サイクル（golden 拡張 / CR-4 件数進捗 / messaging T-2 工程進捗 / REQ-37 最長工程 / U-1・U-5 却下 orchestrate / ハンドオフ 2 件 tracking / show-goldens スキル） | [2026-04-alarm-12.md](2026-04-alarm-12.md) |
| 2026-04-15 | alarmアプリ /closing スキル新規作成＋初回試運転（ステップ4まで実行・findings handoff 起票・messaging-completion-ux archive 移動） | [2026-04-alarm-13.md](2026-04-alarm-13.md) |
| 2026-04-15 | alarmアプリ countdown_view 4チャンク化（REQ-38 新規・chunk A-D 分離・stage5 続ける AnimatedSwitcher 昇格）+ REQ-UI-4 派生マーカー掃除 | [2026-04-alarm-14.md](2026-04-alarm-14.md) |
| 2026-04-15 | alarmアプリ countdown_view レイアウト再設計（layout-review #1-#4 解消・主操作を工程直下へ昇格・chunk B 拡張リネーム・T-38.18-24 新規）+ ハンドオフ 2 件 archive | [2026-04-alarm-15.md](2026-04-alarm-15.md) |
| 2026-04-15 | alarmアプリ 責務分割リファクタ（countdown_view 983→92 行 / schedule_notifier 511→429 行・新規 10 ファイル・UI 5 / Application 3 / Domain 2・全 481 テスト緑・振る舞い不変）+ ハンドオフ 1 件 archive | [2026-04-alarm-16.md](2026-04-alarm-16.md) |
| 2026-04-16 | alarmアプリ lint/analyzer 強化導入（strict-casts / unawaited_futures 等 6 ルール追加・lib 30 件の fire-and-forget を unawaited() 明示・test/integration_test/tool で個別 disable・全 481 テスト緑）+ ハンドオフ 1 件 archive | [2026-04-alarm-17.md](2026-04-alarm-17.md) |
| 2026-04-16 | alarmアプリ 早期完了導線の追加（REQ-39 新設 / 工程レベル secondary CTA / セッションレベル「準備完了・出発」/ Codex 指摘で _skippedDepartureTime 追加・stage4-5 文言陳腐化修正 / 511 テスト緑） | [2026-04-alarm-18.md](2026-04-alarm-18.md) |
| 2026-04-23 | alarmアプリ UI改善・domain リファクタ・scripts汎用化（REQ-39 追加修正 / HO-071 Finding 1-6 実装 / domain P1 系 4 件 + 純関数抽出 / TASK-20260422-001 scripts dotfiles 化完了） | [2026-04-alarm-19.md](2026-04-alarm-19.md) |
| 2026-04-24 | alarmアプリ 出発直前チェック工程 UI 統一 + 前倒し atDeparture 遷移（REQ-45 / `_TaskZone._buildSystemStep()` 拡張 + `AtDepartureReason` 追加 / tester 600s stall → Orchestrator 代行 / Reviewer 自動修正で depart 音二重発火潰し / golden 3 件再構成 / 全 659 テスト緑） | [2026-04-alarm-20.md](2026-04-alarm-20.md) |
| 2026-04-24 | alarmアプリ 2026-04-24 追加作業（HO-095〜101 対応 / 進捗バー配置・BottomSheet 統一 / HO-097 Slice F/I/J テスト基盤強化 / REQ-27・REQ-37 retire + REQ-43 sentinel template / 21 コミット・86 files +4,469/-1,375） | [2026-04-alarm-21.md](2026-04-alarm-21.md) |
| 2026-04-25 | alarmアプリ 集中モード除去（REQ-31 削除）+ 並行セッション衝突（同一リポジトリで別セッションが REQ-34 改訂を同時進行 / 中核ファイルへの並行編集を「自動修正」と誤認して書き戻し → ユーザー指摘で再整合 / worktree 分離していなかった反省） | [2026-04-alarm-22.md](2026-04-alarm-22.md) |
| 2026-04-25 | alarmアプリ countdown pause/resume 実装 + Slice 駆動 handoff 連鎖（HO-107〜117 を 17 commit で land / REQ-49 two-clock model / pause snap-back fix で _onTick の state 再構成漏れ判明 / Slice A persona Failure Mode 実体化 / Codex 並行投入で HO-114/115 fix / HO-116 pause後再調査 / HO-117 Slice C 起票） | [2026-04-alarm-23.md](2026-04-alarm-23.md) |
| 2026-04-29 | alarmアプリ IDEA-80〜91 実装マラソン（12 IDEA / 23 commit）+ IDEA-79 5-step Autonomy Delegation Filter ロードマップ完走（`/groom` AI ランキング 6-tier ルール明文化）+ 申し送り handoff R1-R6/M1-M2 起票 | [2026-04-alarm-29.md](2026-04-alarm-29.md) |
| 2026-04-29 | alarmアプリ closing carry-over 完遂（R1〜R5/M1/M2）+ IDEA-94/95/96/100/102/103/104 実装（11 commit）+ IDEA-104 で Codex consult → Human pivot で「2 surface 別概念」方針に転換 | [2026-04-alarm-29b.md](2026-04-alarm-29b.md) |
| 2026-04-29 | alarmアプリ HO-128 family golden review fork 全件 close（HO-129/130/131/133/135/136 実装 6 件 + HO-132/134/137 design-consult 3 件 + HO-128 parent done）+ requirements/current-architecture 整合 + atDeparture urgency reason 別色分岐実装 | [2026-04-alarm-29c.md](2026-04-alarm-29c.md) |
| 2026-04-30 | alarmアプリ HO-132〜166 backlog バッチ + session-start 拡張（HO-145〜157 で 3 セットモデル + IDEA design-consult 自動起票 + auto-archive）+ IDEA-99/110/111 実装（35 commit、+5713/-894）+ visual-confirmation 申し送り起票 | [2026-04-alarm-30.md](2026-04-alarm-30.md) |
| 2026-04-30 | alarmアプリ mobile/web platform hardening（AndroidSoloudSoundPlayer / Web WakeLock・AudioUnlock / 実機確認）+ 画面統一・背景方針 design consult（HO-170/171/172）+ IDEA-113/114 UI 改善 + IDEA-116 バグ修正 + session-start プロセス改善（自律採用ルール更新） | [2026-04-alarm-30b.md](2026-04-alarm-30b.md) |
| 2026-05-05 | alarmアプリ HO-212 screenshot harness Phase A（remote review 基盤・integration_test 7 シナリオ + index.html 生成スクリプト・Box→Drive→Phase 分割で go・MCP 不可時のローカル先行運用） | [2026-05-alarm.md](2026-05-alarm.md) |
| 2026-05-05 | alarmアプリ session-start 継続 — HO-213 Codex-owner loop 実装 + Codex-turn queue 全消化（HO-213/214/208/206/205 archive・HO-203/204/207/209 waiting/Codex・18 commit）+ ループスクリプト誤認 / golden 不足 / archive 順序の 3 課題発覚 | [2026-05-alarm-2.md](2026-05-alarm-2.md) |
| 2026-05-05 | alarmアプリ セッション継続 — HO-203 raw StateProvider clear 漏れ修正（ref.listen + flicker 修正）+ HO-218 CurrentStepCircle press feedback（AnimatedScale 120ms / Slice 3a）+ IDEA-89 ゴーストカード contrast 改善（11 commit） | [2026-05-alarm-3.md](2026-05-alarm-3.md) |
| 2026-05-06 | ai-agent-workflow HO-W019〜W023 完走（decision-spine Slice 3 / P2-P5 amendment / docs-only carve-out 昇格 + Codex review / alarm AGENT_GUIDE 読み順 First Slice / topic-ledger 新設・21 行 backfill + Archive checklist） — Step 1.5.5 違反 1 件をユーザー指摘で同セッション内解消 | [2026-05-workflow.md](2026-05-workflow.md) |
| 2026-06-15 | logsite（Universal Capture Inbox）全機能実装 + 期間Q&A（Phase 0〜7 を 42 commit で land・Cloudflare Workers + Hono + D1 / AI 日次解析・ダッシュボード・用語辞書・スパン解析 / C-1 問いフォローアップ / 全コンテキスト方式 ad-hoc Q&A「この期間に問う」）+ 本番デプロイ後リグレッション修正（migration 0008 未適用で一覧タブ空白 → remote 適用） | [2026-06-logsite.md](2026-06-logsite.md) |
| 2026-06-15 | logsite コード解析改善 — 「解析が遅い」問題を診断（主因は探索手順、コード規模ではない）→ docs/code-map.md（機能→ファイル・行アンカー索引）新設 + CLAUDE.md ポインタ + global memory に探索手順 feedback を永続化 | [2026-06-logsite-2.md](2026-06-logsite-2.md) |
| 2026-06-15 | logsite 入力体験改善 — 下部固定クイックバー・楽観的保存・音声録音ボタン・カスタム期間ピッカー・ラベルチップ設計欠陥修正（入力経路欠落の循環）+ ハンドオフ 4 件（HO-003〜006） | [2026-06-logsite-3.md](2026-06-logsite-3.md) |
| 2026-06-15 | logsite HO-003/005/006 並列実装 + デプロイ — groom→opus 4 エージェント並列（worktree isolation）→ merge→prettier→deploy。Capture タブラベルチップ共通化・AI 表示改善+コピー・プロバイダー別残予算表示。eslint の .claude ignore 追加 | [2026-06-logsite-4.md](2026-06-logsite-4.md) |
| 2026-06-18 | logsite 多機能並列実装 + テスト基盤安定化 — HO-007/008/011/012/014/015/016-C/D/E/I/J 実装（22 commit, +2434 行）+ Capture rename/edit + Staging 環境構築 + vitest singleWorker + WSL OOM 解消 | [2026-06-logsite-5.md](2026-06-logsite-5.md) |
| 2026-07-02 | logsite Phase 2 自律開発フルループ + UX 改善バンドル — label-ideas / auto-implement スキル実装・CCR→WSL cron 移行・HO-079/080/082/083/100/102/105/109 prod deploy（155 commit）| [2026-07-logsite.md](2026-07-logsite.md) |
| 2026-07-02 | logsite staging integration build + RELEASE_DASHBOARD 安定化 — integration build スクリプト worktree 共存ロジック・handoff コンフリクト自動解決・全 worktree wrangler.jsonc 更新（22 commit） | [2026-07-logsite-2.md](2026-07-logsite-2.md) |
| 2026-07-02 | logsite HO-096 コンフリクト解消 + git push 許可追加 — withPrefix + withGraphTokenRetry 両立（analyze/extraction/admin/portal）・HO-100/102 rebase で unmerged 誤検知解消・staging-integration マージ・settings.json deny エントリ削除 | [2026-07-logsite-3.md](2026-07-logsite-3.md) |
| 2026-07-02 | logsite release-merge-cron バグ修正 + パイプライン疎通 — DB 名誤り・main ブランチ保証なし・auto-implement 不要直列化の3バグ修正、HO-097/100/105/109 宙吊り解消・prod deploy 完走 | [2026-07-logsite-4.md](2026-07-logsite-4.md) |
| 2026-07-03 | logsite CI/品質ゲート + コンフリクト解消 + staging 自動化整備 — HO-113/118/124 prod・HO-120/121 impl・HO-104/096 rebase fix・UPSERT fix・done 済み 8 件アーカイブ（18 commit） | [2026-07-logsite-5.md](2026-07-logsite-5.md) |
| 2026-07-03 | logsite staging deploy 不整合修正 + HO-125 取り込み — HO-120 却下機能消失の原因調査（staging が staging-integration 以外からデプロイ）・HO-125 merge → migration 0016 衝突確認（D1 は両方適用済み）・再デプロイ（1 commit） | [2026-07-logsite-6.md](2026-07-logsite-6.md) |
| 2026-07-03 | logsite HO-127/128 ドッグフーディング強化 + cron 停止調査 — ai_questions 追跡セクション追加・判断キャンセルボタン実装・WSL スリープによる cron 欠落調査・deny list false positive 修正（7 commit） | [2026-07-logsite-7.md](2026-07-logsite-7.md) |
| 2026-07-04 | logsite HO-132〜152 マージ + ポータル安定化 — 9件 prod deploy・Hono 末尾スラッシュ修正・HO-150 heartbeat 実装・コンフリクト4ラウンド解消・承認ボタンエラーフィードバック追加（124 commit） | [2026-07-logsite-8.md](2026-07-logsite-8.md) |
| 2026-07-04 | logsite HO-167/172 リリース管理 UX 改善 — コンフリクトファイル名タグ表示 + 再試行ボタン実装・HO-167 stale pending_releases 修正（8 commit） | [2026-07-logsite-9.md](2026-07-logsite-9.md) |
| 2026-07-05 | logsite HO-214〜216・auto-impl 大量 prod 反映・ポータル DB 混乱 — ハンドオフ形式統一 + validator / 鮮度チェックパイプライン / portal confirm-archive / 11件 prod 反映 / dogfooding 日本語化 | [2026-07-logsite-10.md](2026-07-logsite-10.md) |
| 2026-07-06 | logsite ポータル リリースカード レイアウト改善 — Dogfooding 形式に統一（HO番号+バッジ1行目・タイトル2行目全幅・meta-row に staging日時/却下回数）+ deploy 済み URL 確認運用の学習 | [2026-07-logsite-11.md](2026-07-logsite-11.md) |
| 2026-07-13 | logsite /groom 横断棚卸 + 実態調査による HO 大量クローズ — 実装済みだが waiting 放置の 8 HO を発見しクローズ（cron ログ/git log --grep/git cherry で裏取り）・check-archived-unmerged.py 新設（merge-base→cherry へ設計変更）・HO-235/236 supersede 確認と orphan 削除・app-state.md 新設・ポータル handoff_status 直接同期 | [2026-07-logsite-12.md](2026-07-logsite-12.md) |
| 2026-08-07 | trpg-mcp テストプレイ（潮界都市アルヴィス 第一章シーン1完走・7ターン）— 実プレイで露見した2欠陥を憲章条項化（GM層情報の提示文漏れ防止・テンポ規範）+ record_turn の acquisition_type 許可語彙をスキーマ明記・応答遅延をログで原因分解・instructions 4000字上限に抵触し文面圧縮で対処（1 commit） | [2026-08-trpg.md](2026-08-trpg.md) |
