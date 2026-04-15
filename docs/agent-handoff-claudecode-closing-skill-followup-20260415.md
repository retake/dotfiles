## ハンドオフ: /closing スキル試運転の残論点（alarm セッションから引き継ぎ）

**作成日**: 2026-04-15
**担当**: Claude（alarm セッション）→ dotfiles セッション（次回）
**起点**: alarm リポジトリでの `/closing` スキル初回試運転
**元 handoff**: `~/dev/alarm/docs/archive/agent-handoff-claudecode-closing-skill-trial-findings-20260415.md`（alarm 側で archive 予定）

---

## 背景

alarm リポジトリ（master, 450b282）で `/closing` スキル（`~/dotfiles/claude/skills/closing/SKILL.md`）の初回試運転を実施し、以下が判明した。T-1（REQ-UI-4 マーカー掃除）と T-5（対話 UX 改善）は alarm / dotfiles 側でそれぞれ既に対応済み。残る T-2 / T-3 / T-4 は `~/dotfiles/claude/skills/` の設計判断であり alarm リポジトリでは着手不可のため、dotfiles セッションに引き継ぐ。

---

## 残タスク（dotfiles セッションで対応）

### T-2: sync スキルの `src/` ハードコード問題

**該当**: `~/dotfiles/claude/skills/sync/SKILL.md`

**論点**: sync は `src/` 配下を前提とした要件照合ロジックで書かれているが、Flutter プロジェクト（alarm）では `lib/` が該当。alarm 試運転では Grep 対象を手動で `lib/` に切り替えたため動作したが、他プロジェクトで `/closing` が呼ばれると sync が fail しうる。

**選択肢**:
- (a) sync スキル本体を技術スタック非依存に改修（`lib/` / `src/` / `app/` を自動探索）
- (b) closing 側でプロジェクトタイプを検出し sync に引数で伝える
- (c) 各プロジェクトの CLAUDE.md にパス宣言を持たせる

**推奨**: `~/dev/CLAUDE.md` のスキル設計原則節「クロスプロジェクトは技術スタック非依存で書く」に従えば (a) が正道。ただし (c) の CLAUDE.md 宣言併用も現実的。

---

### T-3: `/closing` ステップ7 Codex レビュー未実施警告の精度検証

**該当**: `~/dotfiles/claude/skills/closing/SKILL.md` ステップ7

**論点**: SKILL.md の仕様では `auth/session/token/crypto` / `Timer/Stream/dispose` / `+300 行リファクタ` を含むコミットを検出して Codex 未レビュー警告を出すとしたが、`git log -p` の grep で十分な精度（フォールスポジティブ率）が出るか未検証。alarm 試運転ではステップ7 に到達せず。

**対応方針**: 次回 `/closing` 実行時にステップ7 まで走らせてフォールスポジティブを実測する。精度不足なら規則を絞り込むか、diff 行数の閾値を調整する。

---

### T-4: コード側マーカー不整合を `/closing` 警告で拾うか

**該当**: `~/dotfiles/claude/skills/closing/SKILL.md` / `~/dotfiles/claude/skills/sync/SKILL.md`

**論点**: alarm 試運転で sync が REQ-UI-4 派生マーカーを検出したが、sync は「コード修正しない」制約のため放置される結果となった。この種の検出を `/closing` ステップ7 の警告候補に追加するかが未決。

**選択肢**:
- (a) sync 出力を構造化パースして closing ステップ7 に引き継ぐ
- (b) sync 側に「コード側掃除が必要な項目」のサマリ出力を追加し、closing はそれを転記するだけに留める
- (c) 拡張しない（運用で覚える）

**推奨**: `~/dev/CLAUDE.md`「スキル間の情報連携はファイル経由で構造化する」原則に従えば (b) が最小実装で整合する。

---

## T-6 メモ（対応不要・運用観察）

- `/audit-handoffs` 出力と `/closing` ステップ4 Q1（残タスク）は情報が重なる
- alarm 試運転では「audit で記録済みの項目を Q1 に書き直さない」運用で進めた
- このまま運用観察し、負担が続くなら SKILL.md に明示する

---

## Status

| # | 項目 | 判定 | 対応 |
|---|---|---|---|
| T-2 | sync の `src/` ハードコード | 要判断 | dotfiles セッションで (a)/(b)/(c) 決定 |
| T-3 | ステップ7 警告の精度検証 | 要判断 | 次回 `/closing` でフォールスポジティブ実測 |
| T-4 | コードマーカー不整合の closing 拾い上げ | 要判断 | dotfiles セッションで (a)/(b)/(c) 決定 |
| T-6 | audit と closing Q1 重複 | メモ | 運用観察継続、対応不要 |
