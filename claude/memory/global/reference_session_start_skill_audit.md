---
name: session-start スキル調査結果（IDEA-112 items 2-5）
description: session-start SKILL.md の 4 項目（consult cap / skip-on-stuck / Loop State 原子性 / Stop Report actionability）の調査結果
type: reference
originSessionId: 0316d6dd-309d-4e40-af13-59a36908b6ac
---
## 調査日: 2026-04-30

対象: `~/.claude/skills/session-start/SKILL.md`（alarm repo `.claude/skills/session-start/SKILL.md` も同内容）

---

## Item 2: per-session IDEA consult cap（3件）の妥当性

**判断: 問題なし**

- cap 3 件は「Codex API コスト × coverage バランス」で設計されており、根拠は合理的
- starvation 防止: priority 順 + IDEA 番号昇順で処理し、overflow 分は次セッションに繰り越し（SKILL.md L131-133）
- 各 consult は最大 2 rounds（round 1 + follow-up）なので 3 件 = 最大 6 Codex calls/session
- consult-eligible 条件（L115-123）が厳しいため実際に cap に到達するケースは稀
- **改善不要**: consult-eligible IDEA が大量にたまった場合はユーザーが手動で `auto-adoptable` / `auto-rejectable` に変換するのが正しいアプローチ

---

## Item 3: skip-on-stuck 後の再試行可能性

**判断: 問題なし（設計上の意図的な動作）**

SKILL.md の明示事項（L588-592）:
- stuck → human-judgment bucket 移動（reason source: `codex-consult-result`）
- 長期分類（IDEA filter / handoff Next Owner）は**変更しない**
- 「今セッションでは skip」という意味

**次セッションでの再試行**: 意図的に保証されている
- handoff Target: next session の step 1 re-scan で `Next Owner: Claude Code` + `active/waiting` のまま → actionable queue に再投入される
- IDEA Target: `auto-adoptable` filter が変わっていないため → actionable queue に再投入される

**ループ防止設計**:
- stuck 時に作成した consult handoff が Stop Report に表示される → Human が原因を解消すれば次セッションで成功する
- Human が解消しない場合も Stop Report で毎セッション可視化されるため放置は難しい
- IDEA-level の `consult-attempted` マーカー（L180-184）は design-consult 自動起票フローの話。skip-on-stuck はこれとは別フロー

**明文化の不足（SKILL.md の課題）**:
- skip-on-stuck 後の consult handoff の `handoff_status` 更新手順が未記載（どのタイミングで Next Owner: Human にするか不明確）
- ただし実運用への影響は低い。Codex の応答 が handoff に追記されれば Human は状況を把握できる

---

## Item 4: Loop State 更新の原子性リスク

**判断: 軽微なリスクあり（許容可能）**

問題の構造:
1. Claude が actionable queue から Target を選択（内部状態のみ）
2. **ここでコンテキスト圧縮が発生すると→**
3. Loop State の Edit が実行されず古い状態のまま
4. 次セッション: old Loop State または `ACTIVE (next: 前の Target)` が残る

**影響**:
- 最悪ケース: 選んだ Target が重複実行される
- ただし re-scan（step 1）で実装済み状態を検出するため多くの場合は自然に解消される
- Edit 失敗（パターン不一致）は Silent fail → Loop State が stale のまま残る可能性

**改善案（SKILL.md への追記候補、Human 判断）**:
- ✅ 現在の順序: Target 取り出し → Loop State Edit → 実行開始（SKILL.md L572-576）
  - 圧縮が Edit の後に起きれば問題なし。問題は Edit 前の圧縮
- 代替案: Loop State に「実行中」フラグを追加（e.g., `ACTIVE (running: HO-XXX)`）し、実行完了後に `ACTIVE (next: ...)` へ更新する二段階マーク
- 実質リスク: コンテキスト圧縮は Claude Code が自動的に行うもので、特定の操作直後に発生するとは限らない。通常は問題にならない

**結論**: 現状のまま許容。複数セッション連続で同じ Target が重複実行されるようなら二段階マークを検討する。

---

## Item 5: Stop Report の actionability レビュー

**判断: 良好（Step 1.7 導入後に大幅改善）**

過去の問題（retrospective-draft.md より）:
- IDEA-116, HO-170/171/172 が Human-judgment bucket に入りすぎた → Human が「なぜ実行していないか」と問い直す事態
- Stop Report に余分な項目が入ると「次に Human が決めること」が不明確になる

**Step 1.7（Pre-bucket execution）導入後の改善**:
- docs-only / copy-only / backlog 更新 / no-change 確認 は bucket に入れても即実行する
- 結果として Stop Report に残るアイテムは「真に Human 判断が必要なもの」だけになった
- 現行 task-state.md（2026-04-30）の bucket: HO-168/169/139（実機確認・"go"指示）、IDEA-85/93/105（calendar 依存・HO 依存）— すべて具体的な action が付与されており actionable

**改善余地（低優先度）**:
- 「次に Human が決めること」のリストが template では 2 項目固定（L627-629）。bucket が 5 件以上の場合は priority フィールドを使った自動ソートを明記するとより actionable
- 現状は bucket テーブルの順序が reason source（handoff > filter）の暗黙的優先度に依存しており、Human には優先順が伝わりにくい
