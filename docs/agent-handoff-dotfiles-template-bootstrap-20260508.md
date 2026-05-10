# Agent Handoff: project template bootstrap (AGENT_GUIDE adapter)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — `templates/` and `docs/new-project-setup.md` already exist but are read-and-copy only. Standing up a new project (Flutter or generic) is a several-step manual `cp` ritual; on a fresh host the user re-derives the steps each time.

## goal
Provide a single command that materializes the appropriate adapter (`AGENT_GUIDE.md`, `scripts/`, `git-hooks/`, `.reqcoverageignore`) into a target project directory, plus an automated check that adopter projects are still in sync with the canonical templates.

## context
- [templates/common/AGENT_GUIDE.md](../templates/common/AGENT_GUIDE.md) and [templates/common/docs/](../templates/common/docs/) are the cross-language adapter.
- [templates/flutter/](../templates/flutter/) layers Flutter-specific scripts (golden update, pre-commit) and CI.
- [docs/new-project-setup.md](new-project-setup.md) lists a chain of `cp` commands and `chmod +x` calls — currently the source of truth.
- The user's [CLAUDE.md](../claude/ai-agent-workflow/CLAUDE.md) (workflow repo) explicitly notes the adapter mechanism but does not script it.
- [scripts/check-req-coverage.sh](../scripts/check-req-coverage.sh) and [scripts/next-req.sh](../scripts/next-req.sh) live in dotfiles and are copied per project.

## current state
- No `bin/new-project.sh`, no `bin/sync-templates.sh`.
- Each adopter project may or may not be on the latest template version — drift detection is manual.

## options
| option | summary | tradeoff |
|---|---|---|
| A. `bin/new-project.sh <flutter|generic> <path>` materializes templates by copying with executable bit + git hook config. | Fits the existing `cp` ritual exactly, easy to author. | Copies, so adopter drift over time stays a problem. |
| B. Reference dotfiles via symlinks from adopter projects. | Adopters auto-update with dotfiles. | Symlink across repo boundaries is awkward; CI on adopter machines won't have the symlink target. |
| C. Hybrid: copy at bootstrap time, plus a `bin/sync-templates.sh` that diffs an adopter against the canonical template and reports drift. | Best of both; explicit drift reporting. | Two commands instead of one. |

## recommendation
Adopt option C. `bin/new-project.sh` does the initial materialization; `bin/sync-templates.sh` (run inside an adopter repo) reports stale files vs the canonical templates so the user can choose to refresh. This keeps adopters self-contained for CI while still surfacing drift quickly.

## acceptance criteria
- [ ] `bin/new-project.sh flutter <dir>` and `bin/new-project.sh generic <dir>` produce a ready-to-use project skeleton.
- [ ] `bin/sync-templates.sh` (run from an adopter) reports per-file diff vs `templates/`.
- [ ] [docs/new-project-setup.md](new-project-setup.md) becomes a thin wrapper around the new commands.
- [ ] AGENT_GUIDE.adapter.md (in the workflow repo) is referenced consistently.

## dependencies
- pairs with: directory-inventory, bootstrap-orchestrator.
- intersects with: ai-agent-workflow repo's `templates/AGENT_GUIDE.adapter.md` ownership; do not duplicate that template here.

## next action
- Human: confirm option C; decide whether `bin/new-project.sh` belongs in dotfiles `bin/` or in the workflow repo.
- After approval: open child implementation handoff for both scripts.
