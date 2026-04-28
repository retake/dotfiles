---
name: 要件の更新方向（新仕様優先）
description: 後から出た仕様・実装判断が既存 requirements.md と衝突する場合、product-request.md に抵触しない限り新しい方を正とし requirements.md を更新してよい
type: feedback
originSessionId: 0a80e74d-ba69-404a-bfcd-7336e9d6d557
---
後続の実装・設計判断が既存 requirements.md と衝突するとき、「既存要件を守るために新しい仕様を小さく見る」ではなく、**ペルソナ視点で新しい判断が推奨されるなら requirements.md 側を更新する**。

**Why:** requirements.md は living document。product-request.md（製品意図の正本）に抵触しない限り、より良い UX 判断が出たら要件を書き換えるのが正しい運用。過去の記述に引っ張られて新仕様を「partial revoke」「deviation」と位置づけるのは誤り。

**How to apply:**
- 新しい実装が既存 requirements の検証条件・仕様記述と乖離したとき、まず「新しい方が product-request.md の製品意図に沿うか」を判定する
- 沿うなら（強く推奨できるなら）確認なく requirements.md を更新してよい
- 「既存要件に抵触する」という表現を使わない。「要件をアップデートする」と表現する
- 迷うケース（product-request.md との整合が不明確）のみ確認を取る
