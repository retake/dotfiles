# Agent Handoff: macOS support

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — The user has explicitly listed macOS as a target host but no scripted path exists. Without this, a fresh Mac requires recreating the bootstrap by hand.

## goal
Bring macOS to feature parity with the Linux/WSL2 bootstrap: package installation via Homebrew, shell choice (zsh default), OS-specific paths, and per-OS conditionals throughout dotfiles.

## context
- [docs/requirements.md](requirements.md) lists "Mac対応" as a wishlist item; [`os/`](../os/) only contains a `windows/` subtree.
- macOS ships with zsh as the default login shell since Catalina; current `.bashrc`/`.bash_profile` are bash-only.
- `setup.sh` symlinks `${HOME}/.bashrc` etc. unconditionally; on macOS the equivalent rc files for zsh (`.zshrc`, `.zprofile`) do not exist in this repo.
- Several Linux-specific paths leak into [`.bashrc`](../.bashrc): `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64`, `BROWSER=wslview`, `usbipd-win` workflow.
- Homebrew vs apt is the largest packaging divergence; package-manifest handoff covers the manifest itself, this handoff covers macOS shell + path layering.

## current state
- [`.bashrc`](../.bashrc) and [`.bash_profile`](../.bash_profile) are bash-specific and leak Linux paths.
- [`setup.sh`](../setup.sh) does no OS detection.
- [`os/`](../os/) has no `mac/` subdirectory.
- Toolchain assumptions (Flutter under `~/dev/tools/flutter`, Android SDK under `~/android-sdk`, JDK from apt) are Linux-only.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Add `os/mac/` + parallel `.zshrc`/`.zprofile`, share aliases via a sourced `aliases.sh` | Shell-native on each OS; aliases live once. | Two rc files to keep in sync. |
| B. Use bash on macOS (force-install via brew, set as login shell) | Single rc tree. | Fights the Mac default; `brew install bash` is heavyweight; `chsh` requires `/etc/shells` edit. |
| C. Adopt a unified shell (e.g. `fish` or `nu`) on both OSes | Cleanest portable layer. | Migration cost on the user, breaks the existing aliases/functions. |

## recommendation
Adopt option A: keep bash on Linux/WSL2, target zsh on macOS. Refactor shared content (aliases, `cc-new` family, PATH composition) into `shell/common.sh`, then have `.bashrc` and a new `.zshrc` source it. OS-specific blocks (`JAVA_HOME`, `BROWSER`, Android paths) move under guards using OS detection — bootstrap scripts source the shared `lib/bootstrap/os-detect.sh` helper (owned by bootstrap-orchestrator); rc files use one guard function defined inside `shell/common.sh` itself, since they run before any bootstrap. Ownership split: **this track owns creating `shell/common.sh` and the env-export lines inside it**; machine-profile supplies the role-gate helper layered inside it; dev-tools-bootstrap installs binaries only and writes no exports. OS guard and role gate are orthogonal layers — the OS guard decides whether a block is considered at all, the role gate decides whether it activates. This is the smallest disruption, leaves both shells idiomatic on their host OS, and keeps muscle memory intact.

## acceptance criteria
- [ ] `os/mac/` directory exists with macOS-specific scripts (Homebrew bootstrap delegation, Mac-only PATH/env, Mac-only AHK-equivalent if any).
- [ ] `shell/common.sh` exists; both `.bashrc` and `.zshrc` source it.
- [ ] OS-specific environment variables (`JAVA_HOME`, `BROWSER`, Android SDK path) are wrapped in detection guards.
- [ ] `bootstrap.sh` runs end-to-end on a clean macOS host at least once — the GitHub Actions `macos` runner is the default verification path (no physical Mac is available today); a manual run replaces this once a Mac exists.
- [ ] `dev-environments/_index.md` gains at least one Mac entry.

## dependencies
- pairs with: package-manifest (brew formula list), bootstrap-orchestrator, machine-profile (uses OS as one of the profile axes).
- blocks: bootstrap-test-harness for a Mac runner.

## next action
- Human: confirm option A and the rc-split layout.
- After approval: open child implementation handoff for the rc refactor.
