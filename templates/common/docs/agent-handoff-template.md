# Agent Handoff Template

In the `Claude Code` + `Codex` workflow, handoffs serve as a **shared state document** updated each turn — not a one-off handover note.

A handoff is also the **source of truth for the Change Layer**. Implementation specifics (sp values, alpha thresholds, layout names — anything that belongs to `how`, not `what`) live here, not in `requirements.md` (Product Layer). See `docs/ideas-backlog.md` for the 3-layer overview; see `AGENT_GUIDE.md` "3-Layer Requirements" for daily judgment rules.

This template is designed as a minimal diff from the existing `Codex Review Request` / `docs/agent-handoff-*.md` flow.

## Principles

- Handoff is the source of truth, not conversation logs
- Update `Decisions`, `Open Questions`, and `Next Owner` every turn
- After 3+ rounds, compress the handoff body — don't summarize old logs
- A handoff without an explicit `Next Owner` is considered incomplete
- Subsequent handoffs for the same task reuse the same `task_id`
- If a plan spans multiple slices, persist the sequence in the handoff before delegating only slice 1
- Reviewer closes the loop after confirming fixes — the fixer does not self-archive
- `Type: design-consult` = "consult loop"; `implementation / review / bug-triage / audit / security-audit` = "fix loop"
- Either Claude Code or Codex may write responses in the handoff

## Delta from Existing Format

### Fields kept as-is

- `Goal`
- `Context`
- `Type`
- `Scope`
- `Question` or `Ask`
- `Findings`
- `Evidence`
- `Tests Run`
- `Constraints`
- `Notes`

### New required fields

- `task_id` — fixed ID per task (format: `HO-<seq>`)
- `handoff_status` — `active` / `waiting` / `blocked` / `archive_waiting` / `done` / `archived`
- `Current State`
- `Decisions`
- `Planned Follow-ups` — ordered downstream slices, optional but expected for multi-step plans
- `Acceptance Criteria` — change-layer specifics for this task (numbers, internal names, golden update conditions). Not duplicated in `requirements.md`. Optional but required for implementation tasks.
- `Open Questions`
- `Next Owner`
- `Next Action`

### Usage notes

- `Question` is fine for one-shot review requests
- For ongoing dialogue, prefer `Ask` over `Question`
- `Ask` should be written as an **explicit instruction** passable directly to Human or Claude Code
- Even without `Findings`, always fill `Current State` and `Open Questions`
- Reviewer returns `handoff_status: waiting`; reviewer closes the loop
- If Human judgment or approval is still needed, keep the handoff `active` with `Next Owner: Human` rather than marking it `done`
- If `Next Owner: Human`, write `Open Questions` / `Ask` / `Next Action` in domain language first: describe the user-facing meaning, workflow impact, or product tradeoff before implementation details
- If change-layer detail is needed for Human, keep it in a short separate supplement rather than the main decision prompt
- Consult loop usually pauses at `active` + `Next Owner: Human` once the agent-side recommendation is settled. Do not write implementation instructions in a `design-consult` `Next Action`. Open a separate `Type: implementation` handoff if needed.
- If a consult produces a long remediation plan, keep the full sequence in `Planned Follow-ups` and open a separate implementation handoff for the first executable slice
- Fix loop ends with `archive_waiting` after reviewer confirmation that the handoff is ready to move; if a human decision still remains, keep it `active`
- Avoid `done` in new handoffs unless there is explicitly no pending owner/action and the handoff is being kept open temporarily for administrative reasons
- When writing a counterargument or compromise, update `Decisions` and leave a trace in the dialogue log

## Drop-in Delta Template

Add these fields to an existing handoff to make it work for ongoing dialogue.

```md
## task_id
HO-<seq>

## handoff_status
active

## Current State
- What has been confirmed so far
- Current leading hypothesis
- Status: implementing / investigating / awaiting decision

## Decisions
- What was decided
- What was explicitly scoped out

## Planned Follow-ups
<!-- optional; use when the plan has multiple slices -->
- Slice 1: now / owner / exit condition
- Slice 2: later / owner / trigger

## Acceptance Criteria
<!-- change-layer acceptance conditions (optional; required for implementation tasks) -->
- ...

## Open Questions
- Unresolved issues
- Items requiring the other party's judgment

## Next Owner
Claude Code

## Next Action
- Specific tasks for the next owner
```

## Full Template

```md
# Agent Handoff: <topic>

## task_id
HO-<seq>

## handoff_status
active

## Goal
- What this task aims to achieve

## Context
- Background
- Related documents
- Related files

## Type
<!-- review / bug-triage / design-consult / implementation / status-update / audit / security-audit -->

## Scope
- Files:
  - `lib/...`
- Diff:
  - `git diff ...`

## Current State
- Confirmed facts
- Recent changes
- Progress status

## Decisions
- Adopted approach
- Explicitly rejected approach

## Planned Follow-ups
<!-- Optional. Use for parent consults or any multi-step plan. -->
- Slice 1: owner / scope / exit condition
- Slice 2: owner / scope / trigger

## Acceptance Criteria
<!-- Change-layer acceptance conditions. Implementation details not duplicated in requirements.md. -->
<!-- Optional; required for implementation tasks. -->
- ...

## Findings
| severity | file | issue | action |
|---|---|---|---|
| ... | ... | ... | ... |

## Evidence
- `path/to/file.dart:123`
- Reproduction conditions or test output

## Open Questions
- Unresolved issues
- Items to confirm

## Ask
- What to look at
- Expected response format
- Files to reference, exclusions, and response section headings may be specified
- Change-layer acceptance conditions go in `Acceptance Criteria`, not here

## Next Owner
<!-- Claude Code / Codex / Human -->

## Next Action
- Specific tasks for the next owner

## Tests Run
- `flutter test`
- `flutter analyze`
- Note if not yet run

## Constraints
- Invariants to preserve

## Final Outcome
<!-- Append on archive: one-line summary of result -->

## Notes
- Supplementary info
```

## Dialogue Log (optional)

Add this section when continuing discussion in the handoff.

```md
## Codex Response
- Counterarguments or concerns
- Rationale
- Compromise proposals

## Claude Code Response
- Counterarguments or concerns
- Rationale
- Compromise proposals
```

Rules:

- `Decisions` always reflects only the current agreed state
- `Planned Follow-ups` is the place for downstream slices; do not hide step 2+ only in the agent session
- Dialogue log is supplementary — it records *why*, not *what*
- Do not accumulate outdated conclusions in `Decisions`

## Role-based Writing Guide

### Codex → Claude Code

- `Current State`: facts from reading the code; flag risky areas
- `Findings`: include explicit severity
- `Ask`: "May I implement this approach?" / "Please decide between these options"
- `Ask`: specify response section headings, files to reference, excluded topics — write so it can be handed directly to Claude
- `Planned Follow-ups`: when proposing a long plan, leave the downstream slice order and triggers here before handing off slice 1
- `Next Action`: handoff updates and review requests; implementation changes go to Claude

### Claude Code → Codex

- `Current State`: what was changed; what remains uncertain
- `Findings`: side effects or spec differences found during implementation
- `Ask`: narrow down the review focus
- `Next Action`: audit, diff review, alternative proposals

## Minimal Template

For quick iterations.

```md
# Handoff

## task_id
HO-<seq>

## handoff_status
active

## Goal
- ...

## Current State
- ...

## Decisions
- ...

## Planned Follow-ups
- ...

## Open Questions
- ...

## Ask
- ...

## Next Owner
Codex

## Next Action
- ...
```

## Requirement Packet（新規 REQ 作成チェックリスト）

新しい REQ を `requirements.md` に追加する前に、以下を確認する。
未確認項目がある場合は `Type: design-consult` の handoff で解消してから追加する。

1. **product-layer か?** — 外から観測できる振る舞いで、特定改修に閉じていないか
2. **user story link** — Story 1–5 のどれを支援するか（`docs/ideas-backlog.md` 参照）
3. **pillar link** — 回復性・即時再現・予測可能性のどれに主として寄与するか
4. **non-goal check** — `requirements.md` の「解決しないこと」や `ideas-backlog.md` の non-goals と矛盾しないか
5. **既存 REQ との関係** — 先行 REQ を制約・置換・上書きする場合、cross-reference ルール（`AGENT_GUIDE.md`）を適用しているか
6. **製品決定の完了確認** — 競合する REQ との未解決な製品決定が残っていないか（残っている場合は実装 handoff を開かない）
7. **traceability hookup** — REQ 追加直後に `traceability.md` に行を追加できるか

## When to Use What

- One-shot review request: use `docs/codex-request-template.md` as the entry point
- Ongoing dialogue: use a handoff with `Current State` and beyond as the source of truth
- Completion report: use `completion-summary` as the primary doc; keep the handoff open only if issues remain

## Relay Flow to Claude

In this repo, Codex relays to Claude Code by **writing explicit instructions in the handoff**.

Flow:

1. Codex creates or updates the handoff
2. `Ask` specifies: files to reference, exclusions, and expected response section headings
3. The handoff is handed to Human or Claude Code
4. Claude's response is recorded in `Claude Code Response`
5. Codex updates `Decisions` / `Open Questions` / `Next Owner` / `Next Action` / `handoff_status`

Notes:

- `claude -p` headless execution is not standard procedure
- `claude-codex-handoff-loop.sh` is not used in standard operation
- `Ask` should be written so Claude can respond to it directly without further context
- Do not write section headings like `## Next Owner` inside `Ask` code blocks
- To specify response format, use prose (e.g., "append Next Owner and Next Action at the end of your response")

## Loop Termination Conditions

- Consult loop (`Type: design-consult`):
  Once the agent-side recommendation is settled, keep the handoff `active` if Human judgment or adoption is still pending. Open a separate implementation handoff for executable work.
- Fix loop (`Type: implementation / review / bug-triage / audit / security-audit`):
  Reviewer confirms and closes. Typically `archive_waiting` or `archived`; if a human approval step remains, keep the handoff `active`.

## Review Response State Transitions

- Reviewer issues findings:
  `handoff_status: active`
- Fixer returns with fixes:
  `handoff_status: waiting`
  `Next Owner: reviewer`
  `Next Action: Verify fix diff`
- Reviewer confirms resolution:
  `handoff_status: archive_waiting`（アーカイブ可と判断した場合）or `active`（Human 判断や次の owner/action が残る場合）
- Reviewer requests further fixes:
  `handoff_status: active`
  `Next Owner: fixer`
