# 自律セッション運用ガイド

PCを離れて 1 時間以上 Claude に自律実行させるときの運用手順。

---

## セッション開始前チェックリスト（人間が 5 分で完了）

- [ ] 下記「セッション契約」を記入して `task-state.md` に貼る
- [ ] `flutter analyze` / `flutter test` が全件グリーンであることを確認
- [ ] git が clean またはコミット済みであることを確認
- [ ] `settings.json` の `permissions.allow` に必要なコマンドが揃っているか確認（`fewer-permission-prompts` スキルで最新化）

---

## セッション契約テンプレート

```md
## Autonomous Session Contract
Created: YYYY-MM-DD HH:MM

### Target
<!-- 1〜2 行で「何を完成させるか」 -->
-

### Scope
- IN: <!-- 触っていいファイル・機能 -->
- OUT: <!-- 触ってはいけないファイル・機能 -->

### Stop Conditions（以下のいずれかで即停止 → handoff 起票 → 完了通知）
- テストが赤のまま N 回（目安: 3回）連続で修正できない
- 設計判断が必要（同等な選択肢が 2 つ以上ある）
- 宣言スコープ外への変更が必要になった
- 想定外の modified ファイルを検出した（別セッション干渉の疑い）
- その他:

### Pre-authorized Judgments（確認なしに進めてよい判断）
<!-- 例: テストファイルのみの追加、lint 自動修正、コミットメッセージの文言 -->
-

### Success Criteria
<!-- 何をもって「完了」とするか。テスト件数・lint 件数・動作確認項目など -->
-
```

---

## Claude の自律実行ルール

### 自律で進める（止まらない）

- `Pre-authorized Judgments` に列挙されたもの
- テスト赤 → 原因特定 → 修正 → 再テスト（Stop Conditions の上限まで）
- lint 警告の自動修正
- コミット（メッセージ日本語、スコープ内変更のみ）

### 止まる（handoff を起票してセッション終了）

- Stop Conditions に該当
- `Open Questions` に答えられない設計判断が発生した
- 外部サービス・push・PR 作成 など不可逆な操作が必要になった

### 停止時の出力フォーマット

handoff に以下を記録して止まる:

```md
## Current State
- 完了した作業:
- 残り作業:

## Open Questions
- 止まった理由（選択肢があれば列挙）

## Next Owner
Human

## Next Action
- 判断してほしいこと、または再開方法
```

---

## 再開時の手順

1. handoff の `Current State` と `Open Questions` を読む
2. 判断を `Decisions` に記入
3. `Next Owner: Claude Code` にして渡す

---

## よくある失敗パターン

| パターン | 対策 |
|---|---|
| スコープが曖昧で Claude が勝手に広げる | OUT に明示的にファイル名を書く |
| 設計判断で止まるはずが暴走する | Stop Conditions に「選択肢が 2 つ以上」を必ず入れる |
| 別セッションとファイル衝突 | 着手前に `git status` で確認を契約に入れる |
| テスト修正ループが止まらない | retry 上限（N 回）を契約に明記する |
