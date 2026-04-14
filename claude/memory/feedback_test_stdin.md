---
name: CI環境でのstdin検知の落とし穴
description: [ -p /dev/stdin ] はローカルとCIで挙動が異なる。引数テストでは< /dev/nullで封じること
type: feedback
---

`[ -p /dev/stdin ]` によるstdin検知は、ローカル（TTY）では false、CI/BATS実行時（パイプ）では true になる。
引数渡しのテストでも意図せず stdin ブランチに入り、`cat -` でブロックされる。

**Why:** GitHub ActionsのBATSテストで再現。ローカルでは全通過していたがCIで1・2番のテストが落ちた。

**How to apply:** スクリプトを引数で呼び出すテストを書くときは `< /dev/null` を明示的に付けてstdinを封じる。「ハーネスで何を封じるか」の具体例として、stdin も封じる対象になりうる。
