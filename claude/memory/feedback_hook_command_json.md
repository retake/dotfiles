---
name: command型フックの出力はJSON形式が必要
description: settings.jsonのcommand型フックはstdoutをJSONとして解釈する。catのプレーンテキストは無視される
type: feedback
---

Claude Code の `command` 型フックは stdout を JSON として解釈する。プレーンテキストを出力しても無視される。

**Why:** `PreToolUse` フックで `cat _index.md` を実行したが、出力がプレーンテキストだったため additionalContext に反映されなかった。

**How to apply:** `command` 型フックで additionalContext を注入するには、以下の形式の JSON を stdout に出力する必要がある。`jq` がなければ `python3` で代替する。

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "<内容>"
  }
}
```

python3 での実装例：
```bash
python3 -c "import json,sys,os; content=open(sys.argv[1]).read() if os.path.exists(sys.argv[1]) else ''; print(json.dumps({'hookSpecificOutput':{'hookEventName':'PreToolUse','additionalContext':content}}))" <ファイルパス>
```
