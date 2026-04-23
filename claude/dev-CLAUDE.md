# 開発スタイル

## 基本方針

- ソロ開発。目的は特定プロダクトの完成より**再現性ある開発スタイルの確立**

## 要件定義

> **要件の内容（正本）は各 repo の `docs/product-request.md` / `docs/requirements.md` / `AGENT_GUIDE.md` を参照する。この節は「要件をどう扱うか」の原則（meta-process）であり、要件そのものは repo docs に委譲する。**

- 目的・スコープ・制約・判断基準を最初に明確化する
- 曖昧な要件はそのまま進めず、論点を整理して確認する
- 機能一覧より「何を解決するか」「何を解決しないか」を先に定義する

## 実装

- 技術選定時は選択肢・トレードオフ・推奨理由を明示する
- スモールスタート：動く最小構成から始め、段階的に拡張する
- 選択肢のある実装（ツール・バージョン・設定値等）は作る前に確認する。作ってから修正しない
- 環境依存の操作（バイナリ取得・インストール等）の前にOS・アーキテクチャ等の前提を確認する。普段使う環境のカタログは `~/dev/environments/_index.md` にあるので、ライブラリ追加・ビルドツール選定の前にまず参照する
- ネイティブ依存ライブラリ（FFI / C++ プラグイン等）を追加する前に、bundled binary のアーキテクチャ・compile-time マクロ・対象 OS を確認する。事後の linker error / runtime 無音は手戻りが大きい
- pub-cache / node_modules 等の管理外ツリーを直接編集するのは「動作確認のための一時手段」に限る。永続化策（fork / postinstall script / pubspec override）を決めずに依存しない
- 既存設定の移植時は「なぜあるか・今も使うか」を確認してから判断する。あるから持ち込まない
- 外部リソース（ディレクトリ・ファイル・リポジトリ）の存在・状態に言及する前に、必ず実在を確認する
- リネーム／用語統一リファクタは新規テストを書かない。既存テストの緑維持が回帰条件
- 用語揺れを解消する際は「名前の根拠がある方（enum/class 名などの第一定義）」を正とし、派生・コメント・テスト文言を寄せる
- 巨大ファイル分割リファクタでは re-export パターンで step 単位 format/lint/test を回す（詳細: `~/dev/ai-coding-principles.md`）

## テスト

- 実装と並走してテストを設計する（後付けしない）
- テスト戦略（単体・結合・E2Eの範囲）を実装前に合意する
- ハーネスのセットアップをCIに組み込む（手動実行に依存しない）
- 改修規模の見積もりは行数ではなく、既存の Fake 注入点・抽象インタフェース・純関数化の有無で決まる。大規模に見える改修でもハーネスが揃っていれば TDD で想定より短時間で収束する
- バグ修正のテストは「修正を一時巻き戻して赤転するか」まで確認してから fix を再適用する。緑のみの確認では機能保証テストに留まり、本症状の再現にならない

ハーネス設計の問いかけ（技術スタックを問わず共通）：
- **何を封じるか** — 副作用・外部依存（ファイルシステム・ネットワーク・環境変数）を制御する
- **何を注入するか** — 入力・状態・コンテキストをテスト側から与える
- **何を観測するか** — 出力・状態変化・副作用の痕跡を検証する

### UI コンポーネント実装チェックリスト（Flutter/モバイル）

詳細: `~/dev/ui-checklist.md`（状態列挙・境界条件・インタラクション品質・ボタン文言の指針）

- 実装着手前に `~/dev/ai-coding-principles.md` の AI 共通原則を確認する

## Git運用

- 運用ルール（コミットメッセージ・ブランチ戦略）は初回プロジェクト時に合意して以降統一する

## Lint・CI/CD

- lintは実装開始前に設定する（後付けしない）
- 設定ファイルはリポジトリにコミットする（ローカル依存・暗黙の設定にしない）

## 成果物管理

- 各プロジェクト：`CLAUDE.md` と `docs/`（product-request.md → requirements.md・test-plan.md）を置く。`product-request.md` が要求層の最上流正本。**要件の内容・層定義はすべて repo docs が source of truth。この文書に要件の内容を重複記載しない**
- 振り返り：`~/retrospectives/_index.md`（dotfiles管理）、個別ファイルはローカルのみ
- 運用原則（episodic 教訓を抽象化したもの）：`~/retrospectives/_principles.md`。新しい教訓は `_index.md` 未分類 episodic に追加し、同型が3件以上溜まったら `/retro` が原則への昇格を提案する
- 開発環境カタログ：`~/dev/environments/_index.md`（普段使う環境ごとに 1 ファイル。OS・arch・既知制約・ライブラリ落とし穴を記録）
- プロジェクト作業時はそのリポジトリの `CLAUDE.md` と `docs/` を参照する

---

# orchestrate・サブエージェント・スキル設計

詳細は `~/.claude/docs/orchestrate-ops.md` を参照。orchestrate 実行時・スキル設計時のみ読めばよい。

日常の手動実装では:
- ドキュメントを触った時 or REQ 追加時のみ `/sync` を実行（毎回必須ではない）
- `/audit-handoffs` → `/archive-handoffs` で残課題の視認性を維持

---

# Codex連携

Claude Code主担当、Codex補助の体制。共通ルールは各リポジトリの `AGENT_GUIDE.md` に集約する。依頼は `~/.claude/docs/codex-request-template.md` に沿う。

## handoff loop

継続対話が必要な場合は `claude-codex-handoff-loop.sh` で bounded handoff loop を開始または継続できる。役割分担原則（done+Human タイミング・担当分離）: `~/.claude/docs/orchestrate-ops.md` 参照

開始方法: `/handoff-loop <path|HO-NNN>` または `claude-codex-handoff-loop.sh --repo "$(pwd)" --handoff <path>`

## CLAUDE.md context hygiene

CLAUDE.md が厚くなったら以下の分類基準で整理する：

- **原則 vs ケーススタディ** — 特定の事例由来の説明は repo CLAUDE.md または reference ファイルへ委譲する
- **常時必要 vs 特定操作時のみ** — 後者は操作ドキュメントへのポインタ1行に圧縮する
- **技術スタック横断 vs 特定スタック前提** — 後者は条件付きにするか、スタック固有の CLAUDE.md へ降格する

横展開トリガー（別 repo に hygiene を適用する条件）：

- CLAUDE.md が 150 行を超えた
- 実装時に CLAUDE.md から探す手間が増えたと感じた
- 新しい原則を追加した際に既存の類似節と重複する

---

## Codex review はリスクベース

以下に該当する場合のみ Codex review を実施する（小規模改修・typo・文言変更・局所 UI 修正は不要）:

- auth/session/token/crypto 関連の変更
- Timer/Stream/dispose 等の非同期ライフサイクル変更
- 大きなリファクタリング後
- ユーザーが不安を表明した場合
- orchestrate FR-10完了後にリスクレベルが high の場合
