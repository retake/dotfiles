---
name: memory スコープの選択基準
description: global / work / life / consulting どの MEMORY.md に書くかの判定フロー。claude/memory/ 以下は 4 スコープあるが、現状ほぼ global のみが使われている状態を意識的に振り分けるための基準。
type: user
originSessionId: 2a310792-8f8b-4063-a167-2b191b30b89a
---
# Memory スコープ選択フロー

claude/memory/ は 4 階層（global / work / life / consulting）に分かれている。迷ったら以下の順で判定する:

1. **コンサル案件固有か？**（Box 運用、顧客別フロー等） → `consulting/`
2. **仕事系（社内業務）固有か？**（KPI 管理、会議体、勤怠系） → `work/`
3. **生活系固有か？**（家計、Gmail の個人用アカウント、カレンダー運用） → `life/`
4. **全プロジェクト共通・どのスコープでも再現する** → `global/`

**境界ケース:**

- **Gmail アカウント一覧**（`user_email_accounts.md`）は 4 アカウント横断情報なので `global/` に置いているが、`life/`（個人系）と `work/`（コンサル系）に分割する余地あり
- **技術スタック固有の地雷集**（`reference_flutter_dart_pitfalls.md` 等）は、案件に依存せず再現する → `global/`
- **orchestrate / handoff / retro 等のワークフロー feedback** → `global/`（ワークフロー自体は全プロジェクトで使う）

**優先原則:**

- 迷ったら `global/` で start し、後から分離する（逆より安全）
- 同じ内容を複数スコープに書かない（重複メモリは保守負荷）
- 書き出した後、対応する `MEMORY.md` に1行索引を追加する
