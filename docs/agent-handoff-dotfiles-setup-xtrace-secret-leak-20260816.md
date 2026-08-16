# Agent Handoff: setup-claude.sh leaks live tokens through xtrace

## status
open

## type
bug / implementation

## owner
Human

## next_owner
Claude Code

## priority
high — Every run of `setup-claude.sh` prints live `TODOIST_API_TOKEN`, `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` in cleartext to stderr. The script is run whenever the Claude permission allowlist changes, so the values land in terminal scrollback, any redirected setup log, and the transcript of whatever agent invoked it.

## goal
Make `setup-claude.sh` produce `~/.claude/settings.json` without ever writing secret values to stdout or stderr, and keep that property from silently regressing when new secrets are added to the template.

## context
- Observed 2026-08-16 ~19:35 during an orchestrate session: the assistant ran `bash setup-claude.sh` to apply a new permission rule, and the xtrace output of the `sed` invocation exposed both the Todoist token and the Google OAuth client secret **with values already expanded**.
- This is not a leak of the file contents (`.mcp.env` is correctly gitignored) but of the *expansion step*: `set -x` echoes the fully-substituted command line before executing it.
- `claude/scripts/setup-mcp.sh` handles the same secrets and uses `set -euo pipefail` (no `x`). It does not leak. That script is the correct precedent already present in the repo.
- Related but distinct from the `secret-management` handoff (storage/restore strategy). This one is a concrete defect in the current script and can be fixed independently of the age/1Password decision.

## current state
- `setup-claude.sh:2` — `set -euxo pipefail`. The `x` is the defect.
- `setup-claude.sh:84-90` — `sed -e "s|__TODOIST_API_TOKEN__|${TODOIST_API_TOKEN:-}|g" ...` expands four secrets on the command line, so xtrace prints all of them.
- `setup-claude.sh:70-79` — sources `claude/.mcp.env` under `set -a`. Sourcing itself is not traced line-by-line, so the leak is confined to the `sed` step.
- `setup.sh:2` — also `set -euxo pipefail`, but it only skips `.credentials` (`setup.sh:24`) and never expands secret values, so it does not leak today. It would start leaking the moment someone adds a substitution step there.
- `claude/scripts/setup-mcp.sh:11` — `set -euo pipefail`, no xtrace. Correct behaviour, same secrets.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Wrap only the `sed` block in `set +x` / `set -x` | Minimal diff, keeps trace for everything else. | The guard must be remembered for every future secret-expanding step; a new step added outside the guard leaks again. Fails open. |
| B. Drop `x` from `setup-claude.sh` (match `setup-mcp.sh`), add explicit `echo` for the steps worth seeing | Removes the whole class of leak rather than one instance. Fails closed. | Loses automatic step-by-step visibility; progress output must be written deliberately. |
| C. Replace `sed` substitution with a file-based renderer (envsubst / python reading the template) | Secrets never appear on a command line at all, so even `x` is harmless. | Larger change; adds a dependency or a helper script for what is currently one `sed`. |
| D. Status quo + rotate tokens after each accidental exposure | No code change. | The leak recurs on every run; rotation cost is unbounded. |

## recommendation
Adopt **option B**, and apply the same reasoning to `setup.sh` for consistency.

Reasons: (1) `setup-mcp.sh` already proves the repo can handle these secrets without xtrace, so B aligns the three scripts rather than inventing a new pattern; (2) A leaves a landmine — the next secret added outside the guarded block leaks silently, which is exactly the "swallowed failure surfaces nowhere" shape that principle P12 warns about; (3) C is the strongest guarantee but is disproportionate for a single `sed`, and can be revisited if the template grows more secrets.

Keep visibility by echoing the meaningful steps explicitly (symlink creation, generated file paths) — the script already does this at `setup-claude.sh:91`.

## acceptance criteria
- [ ] `bash setup-claude.sh 2>&1 | grep -F "$TODOIST_API_TOKEN"` returns no match (repeat for `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_CLIENT_ID`, `GITHUB_TOKEN`).
- [ ] `~/.claude/settings.json` is still generated correctly with all placeholders substituted (the existing `__[A-Z_]*__` warning at `setup-claude.sh:94-97` still fires when `.mcp.env` is absent).
- [ ] `setup.sh` no longer runs under xtrace either, or a comment states explicitly why it is safe there.
- [ ] A regression guard exists: either a comment at the `sed` block stating "no xtrace — this line expands secrets", or a test under `tests/` asserting the grep condition above.
- [ ] Decision recorded on whether the already-exposed tokens are rotated (see below).

## rotation decision (Human)
The Todoist token and Google OAuth client secret have been printed into at least one agent transcript and one terminal session on 2026-08-16. Rotating them is cheap for Todoist (regenerate in settings) and moderate for Google (client secret rotation requires updating `.mcp.env` and re-authorizing). Decide whether to rotate now or accept the exposure given the transcript is local.

## dependencies
- related: `agent-handoff-dotfiles-secret-management-20260508.md` — that handoff chooses *where secrets live*; this one fixes *how the current script consumes them*. Fixing this does not block or depend on that decision.
- related: if option C is ever chosen, it should be folded into the `bootstrap.sh` secrets phase rather than done twice.

## next action
- Claude Code: implement option B on `setup-claude.sh` and `setup.sh`, add the regression guard, verify the acceptance criteria by running the grep checks against a real run.
- Human: decide the rotation question above.
