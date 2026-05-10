# Agent Handoff: verify script (post-bootstrap health check)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — Without a verifier, "the bootstrap finished" and "the environment actually works" are not the same statement, and silent regressions (broken symlink, missing tool, expired token) are caught only at the moment they bite.

## goal
Provide a single `verify.sh` that audits a bootstrapped host against a checklist of expectations (binaries on PATH, symlinks resolving, config files valid, secrets present, MCP servers reachable) and exits non-zero on any failure.

## context
- Today the only feedback on bootstrap success is "the script didn't fail". `setup-claude.sh` even silently warns and continues when `claude/.mcp.env` is missing.
- An idempotent verifier doubles as a sanity check on subsequent days ("did anything decay?") and as the canary for `bootstrap-test-harness` CI runs.

## current state
- No verify script exists.
- Some implicit checks are scattered across `setup-claude.sh` (placeholder grep at line ~94).

## options
| option | summary | tradeoff |
|---|---|---|
| A. `verify.sh` runs a list of inline assertions, one per line, with a uniform `check name { command; }` helper. | Simple, transparent, easy to extend. | Single big script. |
| B. Use bats as the harness (matches existing `tests/`). | Reuses bats infra; output is structured. | Tests vs verifier: different audiences (CI vs daily ops). |
| C. JSON/YAML manifest of checks consumed by a small runner. | Declarative; checks become data. | Slight over-engineering at this size. |

## recommendation
Adopt option A for the user-facing daily verifier and reuse bats (option B) for the CI harness (covered in bootstrap-test-harness). The two layers share a checklist file (`docs/verify-checklist.md`) that `verify.sh` parses or that humans use to update both layers in lockstep.

## acceptance criteria
- [ ] `bash verify.sh` exits 0 on a healthy host and non-zero with a readable failure list otherwise.
- [ ] Checks include: PATH has `nvim`, `gh`, `starship`, `claude`, `codex`, `flutter` (if mobile-dev role); `~/.bashrc` symlink resolves; `~/.claude/settings.json` has no `__PLACEHOLDER__`; `.mcp.env` keys non-empty; required dotfile symlinks all resolve; `claude/memory/global/MEMORY.md` is reachable from `~/.claude/...`.
- [ ] Checks are role-aware (skip mobile-dev checks on a non-mobile host).
- [ ] Output groups failures by category and prints the fix command alongside.

## dependencies
- depends on: machine-profile (role gating), bootstrap-orchestrator (verifier is callable as a phase).
- pairs with: bootstrap-test-harness (CI uses the same checklist).

## next action
- Human: confirm option A, agree the initial check list.
- After approval: open child implementation handoff for `verify.sh`.
