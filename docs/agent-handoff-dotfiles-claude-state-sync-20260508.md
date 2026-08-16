# Agent Handoff: Claude memory / state cross-host sync

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — Auto-memory, retrospectives, and `.claude-state` carry the user's accumulated context. Without an explicit cross-host sync strategy, a new machine starts with empty memory and the user loses all the "Claude knows me" benefit.

## goal
Decide what under `claude/memory/`, `~/retrospectives/`, and `~/.claude-state/` (and equivalents) is dotfiles-managed, what is per-host, what is private, and how each piece is restored on a new machine.

## context
- [`.gitignore`](../.gitignore) currently excludes:
  - `claude/memory/**/MEMORY.md` (the index)
  - `claude/memory/global/MEMORY_old.md`
  - `claude/memory/global/user_email_accounts.md`
  - `claude/roles/life/`
  - `claude/memory/life/`
  - `.claude-state/`
- Individual memory files under `claude/memory/global/*.md` are tracked but the index file (`MEMORY.md`) that ties them together is not — meaning new memories can be added on one host and the index is regenerated locally. This is fragile: a partial restore loses cross-references.
- [`~/retrospectives/`](../retrospectives/) is symlinked to dotfiles and partially tracked: `_index.md` is committed, individual retro files are not.
- `.claude-state/` is per-session ephemeral (audit results, sync results, patches) — appropriate to keep gitignored.
- `~/.codex/memories/` is currently fully out-of-tree.

## current state
- Three classes of state co-exist with inconsistent rules: tracked (most memory `.md` files), gitignored-on-purpose (life/private), gitignored-by-accident (the `MEMORY.md` index).
- No per-host divergence story (what if two hosts learn different things and need to merge?).

## options
| option | summary | tradeoff |
|---|---|---|
| A. Track everything except the explicit private buckets (life, work-with-NDA), include `MEMORY.md` index, accept merge conflicts. | Strong cross-host continuity. | Memory edits become commits; chatty git history. |
| B. Move private memory to a sibling private repo, keep `claude/memory/` repo-tracked but generic. | Clean separation. | Adds another repo to bootstrap. |
| C. Status quo: tracked individual files, gitignored index, no merge story. | No work. | New machines lose the index; chatty if life-bucket leaks. |

## recommendation
Adopt option A with a small carve-out: `MEMORY.md` becomes tracked (it is just a list of pointers), `life/` and `consulting/` private notes stay gitignored as today, and a future "private memory" sibling repo (option B) is the answer if the privacy axis grows. Retrospectives stay as today (`_index.md` tracked, episodic files local) — but the `_index.md` index gets the same MEMORY.md treatment: never gitignored.

## acceptance criteria
- [ ] `.gitignore` no longer excludes `claude/memory/**/MEMORY.md`; existing `MEMORY.md` is committed.
- [ ] A documented mapping (in `docs/layout.md`) declares for each state directory: tracked / private / ephemeral.
- [ ] `bash bootstrap.sh --phase claude` (the canonical phase name per bootstrap-orchestrator; the memory/state sync runs as a step inside that phase) symlinks all dotfiles-tracked memory and retrospective state into `~/.claude/...` and `~/retrospectives/...` on a fresh host.
- [ ] Private buckets (life, consulting) are restored only via the secret-management flow, not by default.
- [ ] Retrospective `_principles.md` (if present) is treated like `_index.md` — committed.

## dependencies
- depends on: directory-inventory, secret-management.
- pairs with: bootstrap-orchestrator (the memory/state sync is a step inside its `claude` phase — there is no separate `claude-state` phase).

## next action
- Human: confirm option A, especially the decision to commit `MEMORY.md`.
- After approval: open child implementation handoff to amend `.gitignore`, commit the index, and add the state-sync step to the orchestrator's `claude` phase.
