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
- golden が複数 REQ で重複更新される場合は REQ 単位で都度再生成してコミットに含める。最後にまとめて焼くと diff 追跡が困難になる（2026-04-alarm）
- ECRS レビューの Low 指摘は「完璧」より「二値判断で止める」方が合理的。状態別に閾値を分ける（例: 緊急ステージのみフル白・通常は半透明）とコスト小で十分な対応になる（2026-04-alarm）
- Flutter Material ボタンで `styleFrom(textStyle: const TextStyle(...))` を使うと theme の fontFamily 継承が切れる。fontSize/fontWeight のみ変えたい場合は `Text(style: ...)` 側に寄せて DefaultTextStyle.merge に任せる（2026-04-alarm）
- `google_fonts` で `allowRuntimeFetching = false` の環境では `GoogleFonts.xxx()` 関数呼び出しは実行時例外。textTheme 経由の fontFamily 指定のみ OK で、個別 TextStyle では fontFamily 直書きか DefaultTextStyle merge に寄せる（2026-04-alarm）
- orchestrate は実装完遂前提だけでなく、要件レベル意思決定（採用/保留/却下判断）にも使える。task-state.md の FR-4 以降を明示 SKIP・normal モードで FR-3 architect 停止すると「判断タスク」として完結する。architect の出力は「実装設計」ではなく「採否判断 + ideas-backlog 転記 draft」になる（2026-04-alarm）
- golden テスト追加の優先順位付けは (a) コード行数が大きい (b) 状態分岐が多い (c) 最近変更が入った の 3 条件で費用対効果が高い。「情報ノイズ回避」（1 件のみの時は進捗カウンタ非表示など）を golden の設計にも持ち込むと再利用性が上がる（2026-04-alarm）

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
