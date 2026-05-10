---
name: session-start ループの compact 復帰ルール
description: /session-start ループ実行中に compact が発生した場合、Stop Report を出さずにループを継続する
type: feedback
originSessionId: 1bf4a9a6-d105-43e8-8247-e5d8c7e14b97
---
task-state.md の `### Loop State` が `ACTIVE (next: HO-XXX)` のとき、Stop Report を出力してはならない。
compact 後に会話が再開した際は task-state.md を最初に Read し、ACTIVE なら HO-XXX から実行を再開する。

**Why:** compact 後に SKILL.md の内容がコンテキストから消え、モデルが「処理完了」と誤判断して Stop Report を出す事象が発生した。

**How to apply:** /session-start ループ中に「次に何をすべきか不明」と感じた場合は必ず task-state.md を Read してから判断する。DONE になって初めて Stop Report を出してよい。
