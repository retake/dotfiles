---
name: IDEA 推奨方向がある場合は auto-adoptable として扱う
description: requires-human IDEA でも「推奨方向（AI 暫定）」が具体的に書かれていれば設計判断完了とみなして実装する
type: feedback
originSessionId: 0a0961c3-2796-465a-938f-776c1c95d7a7
---
IDEA の `採否フィルター` が `requires-human` でも、本文に「推奨方向（AI 暫定）」として案が具体的に指定されている場合は、設計判断が完了していると見なしてよい。

実装前に採否フィルターを `auto-adoptable` に更新し、推奨案で実装に進む。Human の明示的な承認を待つ必要はない。

**Why:** IDEA-116 で `requires-human` フィルターが formal gate として機能し、推奨方向が既に書かれているにもかかわらず Human 承認待ちで停止した。フィルターとコンテンツの乖離が無駄な停止を生む。

**How to apply:** session-start / 通常タスク選定時に `requires-human` IDEA の本文を一読し、「推奨方向（AI 暫定）」が具体的な案名を指定していれば auto-adoptable 扱いで actionable queue に入れる。
