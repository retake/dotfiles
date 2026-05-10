# Agent Handoff: legacy cleanup (Ruby/rbenv, vim plugin residues, stale docs)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
low — Legacy cruft does not block bootstrap, but it inflates the surface area every other strengthening track has to reason about (especially package-manifest and bootstrap-test-harness).

## goal
Identify and delete dotfiles content that is no longer in active use, so the bootstrap phases do not have to gate or carry-along dead code.

## context
- [requirements.md](requirements.md) explicitly states one of dotfiles' goals is "removing the legacy of past Ruby/Rails work environment".
- [.bashrc](../.bashrc) still has `if "${HOME}/.rbenv/bin/rbenv" --version > /dev/null 2>&1; then ... eval "$(rbenv init -)"; fi`. The `~/.rbenv` directory is also tracked at dotfiles root.
- [bin/rspec_parser.sh](../bin/rspec_parser.sh) is Rails-era.
- [.cheatsheet.md](../.cheatsheet.md) references coc.nvim/copilot.vim residues; current setup uses lazy.nvim.
- [docs/orchestrate-split-proposal.md](orchestrate-split-proposal.md) and several handoffs in `docs/` may be archive-worthy.

## current state
- Tracked: `.rbenv/`, `bin/rspec_parser.sh`, Ruby-specific aliases in `.bashrc` (none today, just rbenv init).
- Cheatsheet and old docs not yet pruned.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Delete in one PR after confirming with user (per file). | Clean cut. | Slightly tense; need user buy-in per item. |
| B. Quarantine to `legacy/` directory, keep tracked, bootstrap ignores. | Reversible. | Just kicks the can. |
| C. Status quo. | No work. | Carries dead code forever. |

## recommendation
Adopt option A. The user has already declared in requirements.md that legacy removal is a goal; this handoff just inventories the candidates and lets the user nod through the list before deletion.

## acceptance criteria
- [ ] Inventory list reviewed: `.rbenv/`, `bin/rspec_parser.sh`, `.cheatsheet.md` ruby/coc references, archive-eligible handoffs, any stale `docs/*` design summaries that have already shipped.
- [ ] Each item is deleted, archived, or explicitly retained with a one-line "why kept".
- [ ] `bash bootstrap.sh` after the cleanup still works.
- [ ] [requirements.md](requirements.md) marks the legacy-removal goal as achieved or carries the residual list.

## dependencies
- pairs with: package-manifest (do not list `rbenv`/`ruby` if removed), readme-setup-refresh (cheatsheet update).

## next action
- Human: walk the inventory list, mark each delete/keep/archive.
- After approval: open child implementation handoff for the deletions.
