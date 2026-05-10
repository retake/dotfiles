# Agent Handoff: README / SETUP refresh (single source of truth)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
low — Documentation refresh is the natural last slice. It is low-risk in isolation but high-value because it is the entry point a future-you on a new machine will read first. Doing it before the rest of the strengthening tracks is wasted effort.

## goal
Once the bootstrap orchestrator and supporting handoffs land, replace `README.md` and `SETUP.md` with a thin top-level guide that points at scripted commands and `docs/layout.md` instead of carrying step-by-step prose.

## context
- [README.md](../README.md) is currently shaped around the symlink mental model and lists components by directory.
- [SETUP.md](../SETUP.md) carries the manual prose for Neovim, Claude, etc., much of which is being moved into scripts by other handoffs.
- After the strengthening round, the user-facing flow will be:
  1. `git clone dotfiles`
  2. `bash bootstrap.sh`
  3. `bash verify.sh`
- Everything else belongs in `docs/layout.md`, the role taxonomy doc, and per-tool documentation.

## current state
- README has a directory table and bootstrap prose; SETUP has the manual install rituals.
- Neither file references `docs/layout.md`, `docs/verify-checklist.md`, role taxonomy, or `bootstrap.sh` (none of which exist yet).

## options
| option | summary | tradeoff |
|---|---|---|
| A. Keep README and SETUP, refresh in place. | Low surprise. | Two files easy to drift out of sync. |
| B. Collapse SETUP into README, link out to docs/. | One entry point. | README grows heavier. |
| C. Demote README to a one-paragraph badge file pointing at `docs/`. | Clean, but unorthodox. | Newcomers expect README to carry weight. |

## recommendation
Adopt option B. A single README leads with: purpose, prerequisites, three-step bootstrap, verification command, link to `docs/layout.md`, link to role taxonomy. SETUP.md becomes a redirect to README. Per-tool documentation (Neovim, Claude, Codex, mobile-dev) is moved to `docs/<topic>.md` and linked.

## acceptance criteria
- [ ] [README.md](../README.md) leads with bootstrap → verify → layout.
- [ ] [SETUP.md](../SETUP.md) is either deleted or replaced with a one-line redirect.
- [ ] Every prose step that survives in README has a scripted counterpart.
- [ ] Each major component (Neovim, Claude, Codex, mobile-dev, secrets) has its own `docs/<topic>.md` linked from README.

## dependencies
- depends on: bootstrap-orchestrator, verify-script, directory-inventory (`docs/layout.md`).
- last to land in the strengthening round.

## next action
- Human: defer until the bootstrap orchestrator and supporting docs land.
- After other tracks complete: open child implementation handoff for the docs refresh.
