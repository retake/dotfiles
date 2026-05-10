# Agent Handoff: package manifest (apt + brew + system deps)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
high — Without a declared package list, "one-batch bootstrap" cannot install the prerequisites that the rest of dotfiles assumes are present (git, gh, curl, jq, starship, etc.).

## goal
Capture every system-level package the daily environment depends on in a single declarative manifest, with separate sections per OS/arch, so that the bootstrap orchestrator can install them idempotently on a fresh host.

## context
- Today the prerequisites are scattered across [SETUP.md](../SETUP.md) (`git`, `curl`, `gh`), [.bash_profile](../.bash_profile) (assumes `starship` is installed), [docs/new-project-setup.md](new-project-setup.md), and [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md) (`qemu-user-static`, `binfmt-support`, `openjdk-17-jdk`, `adb`, `fastboot`, `libc6:amd64`, etc.).
- No file enumerates the union of those packages; on a new machine the user discovers missing ones reactively.
- macOS Homebrew formula equivalents are unwritten.
- Some packages are tools (jq, gh), others are runtime libraries (libpulse, libasound), others are arch-bridges (qemu-user-static). Mixing them in one Brewfile/apt list is fine if commented.

## current state
- No `Brewfile`, no `packages.apt.txt`, no manifest.
- Closest thing: ad-hoc `apt install` snippets inside [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md).

## options
| option | summary | tradeoff |
|---|---|---|
| A. Plain text lists (`packages/apt.txt`, `packages/brew.txt`) consumed by `xargs apt install` / `brew bundle`. | Trivial to author and review. | No metadata, no per-package rationale. |
| B. YAML / TOML manifest with role tags (e.g. `core`, `mobile`, `claude`) so subsets can be installed. | Lets `bootstrap.sh --phase packages --role core` skip mobile-only deps on a server. | Requires a small parser. |
| C. `Brewfile` + `apt.list` plus a hand-written installer script that knows about the role split. | Familiar tooling per OS. | Duplicates the role logic. |

## recommendation
Adopt option B with the simplest possible YAML/TOML schema (or even a flat shell file using `# role: core` comments). Roles map onto the machine-profile handoff (e.g. `core`, `mobile-dev`, `web-dev`, `claude`, `desktop-only`). The installer is a thin script that parses the manifest, filters by active roles, and dispatches to `apt`/`brew`. Each entry carries a one-line "why" comment to prevent drift.

## acceptance criteria
- [ ] A single manifest enumerates every package the daily flow depends on.
- [ ] Manifest is split per OS (apt vs brew) and per role.
- [ ] `bootstrap.sh --phase packages` installs the active roles idempotently and exits non-zero on partial failure.
- [ ] [SETUP.md](../SETUP.md) and [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md) defer to the manifest as the single source of truth.
- [ ] At least the following are explicitly captured: git, curl, gh, jq, build-essential, starship, fzf, ripgrep, openjdk-17, qemu-user-static, age, the AHK/usbipd notes (cross-ref to windows handoff).

## dependencies
- blocks: bootstrap-orchestrator (packages phase), neovim-install-automation, dev-tools-bootstrap, secret-management (`age`), macos-support.
- pairs with: machine-profile (role tags), legacy-cleanup (drop `.rbenv`/Ruby packages if no longer wanted).

## next action
- Human: confirm option B and the role taxonomy.
- After approval: open child implementation handoff to draft the initial manifest by walking the existing scripts and docs.
