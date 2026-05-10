# Agent Handoff: Neovim install automation

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — Neovim is the user's primary editor (`EDITOR=nvim`, `alias vim=nvim`). On a fresh host it is the largest single manual install step in `SETUP.md`.

## goal
Automate Neovim acquisition (correct architecture, recent version) and the lazy.nvim plugin sync so that a fresh host needs no manual `nvim --version` follow-up.

## context
- [SETUP.md](../SETUP.md) lines 49-83 currently document a manual Neovim install: `uname -m`, choose the right tarball, extract under `~/.local/`, then run `:Lazy sync` interactively.
- The reason given is that apt's Neovim is too old.
- macOS is not addressed at all; on Mac `brew install neovim` is the canonical path.
- [nvim/](../nvim/) holds the lazy.nvim configuration; on a fresh host the very first `nvim` invocation auto-installs lazy.nvim, but the user must remember to run `:Lazy sync` afterwards.

## current state
- [nvim/init.lua](../nvim/init.lua), [nvim/lua/](../nvim/lua/) — config tree present and symlinked into `~/.config/nvim` by `setup.sh`.
- [nvim/lazy-lock.json](../nvim/lazy-lock.json) — present; lockfile is honored if `:Lazy restore` is run.
- No script automates the Linux tarball install or the Mac brew install or the headless plugin sync.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Shell installer that detects OS+arch, chooses tarball/brew, and runs `nvim --headless "+Lazy! restore" +qa` for plugin sync. | Single canonical entry, no manual `:Lazy sync`. | Tarball URL has to track upstream releases; pin a known-good version with override. |
| B. Use `mise` / `asdf` to manage Neovim version | Reuse if user adopts asdf/mise globally | Adds a runtime dependency; not yet in dotfiles. |
| C. Document only, do not automate | Cheapest. | Defeats one-batch goal. |

## recommendation
Adopt option A. Keep the script tiny: detect OS, on Linux pick `nvim-linux-{arm64,x86_64}.tar.gz` from the latest release (or a pinned version), extract under `~/.local/`; on macOS prefer `brew install neovim`. After install, run `nvim --headless "+Lazy! restore" +qa` to materialize plugins from the lockfile. Rerun is idempotent.

## acceptance criteria
- [ ] `bash bootstrap.sh --phase neovim` installs Neovim on Linux (aarch64+x86_64) and macOS without prompts.
- [ ] Lockfile-pinned plugins are installed in the same step.
- [ ] Reruns are idempotent and skip work when the target version is already present.
- [ ] [SETUP.md](../SETUP.md) Neovim section becomes a one-liner pointing at the script.

## dependencies
- depends on: package-manifest (`brew install neovim` on Mac handled there or here, decide).
- pairs with: bootstrap-orchestrator.

## next action
- Human: confirm option A; decide whether to pin a Neovim version or always pull latest.
- After approval: open child implementation handoff for `lib/bootstrap/neovim.sh`.
