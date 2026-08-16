# Agent Handoff: handoff-loop turn timeout is too short for implementation turns and leaves partial work behind

## status
open

## type
bug / implementation

## owner
Human

## next_owner
Claude Code

## priority
high — A timed-out implementation turn leaves uncommitted edits in the working tree with no warning. The orchestrator that reads the timeout message concludes "nothing was done" and can start a second agent on the same files. This happened on 2026-08-16 and was caught only because the operator asked why the turn timed out.

## goal
Make `claude-codex-handoff-loop.sh` survive implementation turns that legitimately take longer than a consult turn, and make a timeout state unambiguous to whoever reads the log — including what was left in the working tree.

## context
- Observed 2026-08-16 on logsite HO-312 (Codex security second opinion on Cognitive Work System ST1).
- Round 1 (Codex consult turn) finished in well under the limit — 55k tokens, answers written back to the handoff file.
- Codex then set `Next Owner: Claude Code` with a next action spanning three Workers: fail-closed secret checks, DO-name digests, a TTL change and a build-script rework, "実装・テスト後" returning to the reviewer.
- Round 2 (Claude implementation turn) hit the 600s limit and was TERMed. The loop reported `ERROR: Claude turn exceeded 600s timeout` and exited.
- **The turn had in fact completed 16 files / 228 lines of correct, well-commented implementation across all three Workers.** All three test suites and all three lint runs passed on it afterwards. Only the final response was lost.
- The log file was 0 bytes, because `claude -p` emits its output at the end. From outside, a productive turn and a hung turn look identical.
- For scale: the same repository's ST1 implementation (one Worker) took an agent 826s. A three-Worker change inside 600s was never plausible.

## current state
- `bin/claude-codex-handoff-loop.sh:376` — `TURN_TIMEOUT_SEC="${HANDOFF_LOOP_TURN_TIMEOUT:-600}"`, one value shared by consult and implementation turns.
- `bin/claude-codex-handoff-loop.sh:318-321` — the Claude turn runs under `timeout --signal=TERM --kill-after=30` with `--permission-mode acceptEdits`, so edits land in the working tree as the turn proceeds.
- `bin/claude-codex-handoff-loop.sh:326-328` — on rc 124 the script calls `die` with the log path. It does not inspect or report the repository state.
- The loop already infers a `loop_mode` from the handoff's `## Type` (`build_codex_prompt` takes it as an argument), so a mode-dependent timeout has an existing hook to hang off.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Raise the single default (e.g. 600 → 1800) | One-line change. | A genuinely hung turn now wastes 30 minutes before anyone notices. Consult turns lose their fast failure signal. |
| B. Mode-dependent timeout: keep ~600s for consult, use a longer value for implementation turns | Matches the observed cost difference; `loop_mode` is already threaded through. | Two numbers to tune; a mislabelled `## Type` gets the wrong budget. |
| C. Report working-tree state on timeout (`git status --short` into the log and the error message) | Removes the "looks like nothing happened" failure mode regardless of the limit. | Does not by itself stop useful work from being killed. |
| D. Roll back the working tree on timeout | Makes timeout atomic. | Destroys correct work — in this incident it would have discarded a complete, passing implementation. |

## recommendation
Adopt **B + C together**, and reject D.

B alone still leaves the ambiguity when the longer limit is hit; C alone still kills productive turns at 600s. Together, an implementation turn gets a budget matched to its real cost, and any timeout — at either limit — reports what survived so the next reader (human or orchestrator) can decide whether to continue from it rather than redo it.

D is wrong for this workload: the incident shows a timed-out turn can hold complete, verifiable work. Discarding it automatically would have thrown away a change that passed three test suites and three lint runs. Preserving and reporting is the safer default; the operator can always `git checkout` themselves.

Suggested values: consult 600s (unchanged), implementation 2400s. Both stay overridable through `HANDOFF_LOOP_TURN_TIMEOUT` for one-off runs.

## acceptance criteria
- [ ] An implementation-mode turn gets a longer budget than a consult-mode turn, and both remain overridable by a single env var.
- [ ] On timeout, the error message and the log include `git status --short` for the repo, plus an explicit line stating that uncommitted changes may be present and were **not** rolled back.
- [ ] On timeout with a clean working tree, the message says so explicitly (so "hung with nothing done" is distinguishable from "worked and got cut off").
- [ ] The dry-run path prints whichever timeout would be applied, so the mode inference is visible without a real run.
- [ ] `bash -n bin/claude-codex-handoff-loop.sh` passes; one real bounded run is exercised end to end.

## dependencies
- related: the same file was just updated for codex CLI 0.148 (`--full-auto` → `--approve-for-me`, commit `94be47b`). Both changes touch `run_claude_turn` / `run_codex_turn`; do them in one pass if not yet started.
- related: repository principle P12 (surface swallowed failures elsewhere) — a 0-byte log plus a bare timeout message is exactly the invisible-failure shape P12 warns about.

## next action
- Claude Code: implement B + C, verify with `bash -n` and one bounded run against a small handoff.
- Human: confirm 2400s is an acceptable upper bound for a single unattended implementation turn.
