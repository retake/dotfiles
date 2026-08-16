---
name: feedback_output_script_mix_guard
description: 私の日本語応答に異種スクリプト(ハングル等)が混入する症状と、Stop hook 検出ガードの存在
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 31405617-da29-4f3f-adf9-eb52462e5a39
---

私(Claude)の日本語応答テキストに、生成時のトークン混入でハングル・キリル等の異種スクリプト文字や無関係な英単語が時々紛れる(ユーザー体感で 1 日 1〜2 回)。私はこれを生成中に自己検知できない(自分の出力を正しいと認識してしまう)。CLAUDE.md の言語ルールは「指示」であって生成事故は止められないため、機械的検出が必要。

**対策(実装済み):** `/home/keita/.claude/scripts/lang-mix-guard.py` を Stop hook に登録済み(settings.json の `Stop` 配列、既存 notify.sh と併存)。最後の assistant メッセージをスキャンし、ハングル(U+AC00-D7A3 ほか)・キリル(U+0400-04FF)・タイ・デーヴァナーガリーを検出したら exit 2 で差し戻し、訂正版を再出力させる。`stop_hook_active` で無限ループ防止。英語・コードは誤検知回避のため対象外。

**Why:** best-of-2(2案生成して綺麗な方を表示)は Claude Code の生成=表示が結合したストリーミング構造上できない。フックは生成後の後処理のみ。検出→訂正ターン追加(壊れた版は一瞬見えるが直後に訂正)が唯一の現実解。

**How to apply:**
- 取りこぼし文字(範囲外)が見つかったら lang-mix-guard.py の SUSPECT 正規表現に範囲を追加する
- Write 生成物もカバーしたければ別途 PostToolUse hook が必要(今回は応答テキストのみ対象)
- 応答に無関係な英単語が紛れた実例(「course」)もあった。語レベルの英語混入はこのガードでは拾えない点に留意

関連: [[feedback_truncation_not_corruption]]
