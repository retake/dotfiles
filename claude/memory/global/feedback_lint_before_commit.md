---
name: lint問題はコミット前に解消する
description: custom_lint（cyclomatic_complexity, function_lines_of_code等）の警告は実装の流れの中で解消し、問題を抱えたままコミットしない
type: feedback
originSessionId: 87a6d805-511e-482e-9b79-011d86a0d2ca
---
lint問題はコミット前に解消する。実装フローの中で問題に気づいたら、その場でリファクタしてから commit する。

**Why:** 「問題が出るコードは流れの中で問題を解消してからコミットする」というユーザー方針。

**How to apply:** dart run custom_lint でゼロ件を確認してから git commit する。新規コードを書く際もルール（max_complexity: 12、max_lines: 80、max_parameters: 5）を意識して設計する。
