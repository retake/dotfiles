# Agent Handoff: Codex CLI bootstrap

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — `claude-codex-handoff-loop.sh` and the `/handoff-loop` skill assume the Codex CLI is installed and authenticated. On a fresh host this prerequisite is undocumented and unscripted, so the Claude/Codex pairing simply does not work after one-batch bootstrap.

## goal
Capture and script everything required to make Codex CLI usable on a new host: install the CLI binary, restore the auth token, ensure `~/.codex/` has the dotfiles-managed skills symlinked, and verify the handoff loop script can dispatch to it.

## context
- The repository has [bin/claude-codex-handoff-loop.sh](../bin/claude-codex-handoff-loop.sh), [bin/sync-codex-skills.sh](../bin/sync-codex-skills.sh), [codex/skills/](../codex/skills/), and [claude/commands/handoff-loop.md](../claude/commands/handoff-loop.md). All assume Codex CLI is present.
- `~/.codex/auth.json`, `config.toml`, and `memories/` exist on the current host but are not in dotfiles. Their bootstrap mechanism is not described anywhere.
- Codex install path on Linux/macOS, version pinning, and update story are absent from `SETUP.md`.
- `sync-codex-skills.sh` only links skills; it does not check that the `codex` binary itself is on PATH.

## current state
- [SETUP.md](../SETUP.md) does not mention Codex.
- [setup.sh](../setup.sh) calls `bin/sync-codex-skills.sh` but does not install Codex itself.
- `~/.codex/` content (auth, config, memories) is local-only with no archived restore plan.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Install via npm (`npm i -g @openai/codex` or whatever the canonical channel is), version-pin in `bootstrap.sh --phase codex`. | Cross-platform; reuses the Node.js prerequisite that Claude Code already needs. | Requires Node first; binary path varies. |
| B. Package the install in the role-based manifest (brew on Mac, npm on Linux) | Consistent with package-manifest. | Slightly diffuse logic. |
| C. Document only. | Cheap. | Defeats one-batch. |

## recommendation
Adopt option A as a dedicated `bash bootstrap.sh --phase codex` that (1) ensures Node is present (delegate to the toolchain phase), (2) installs the Codex CLI at a pinned version, (3) reuses the existing `bin/sync-codex-skills.sh` for skill symlinks, and (4) captures any minimum subset of `~/.codex/config.toml` (sans secrets) into dotfiles as a versioned template. Auth (`auth.json`) is restored through the secret-management phase; treat it as a sealed blob.

## acceptance criteria
- [ ] `bash bootstrap.sh --phase codex` installs Codex CLI, links skills, and renders the config template.
- [ ] `~/.codex/auth.json` is restored through the secrets phase, not committed in plaintext.
- [ ] [SETUP.md](../SETUP.md) gains a Codex section that defers to the scripted phase.
- [ ] After bootstrap, `bash bin/claude-codex-handoff-loop.sh --help` exits 0 on a fresh host.

## dependencies
- depends on: secret-management (auth.json restore), package-manifest (Node presence), bootstrap-orchestrator.
- pairs with: claude-state-sync (for memories layout).

## next action
- Human: confirm option A and decide which Codex CLI version to pin.
- After approval: open child implementation handoff for `lib/bootstrap/codex.sh` and the `~/.codex/config.toml` template.
