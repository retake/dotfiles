# Agent Handoff: machine profile / role gating

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — Without a machine-profile axis, the bootstrap orchestrator either does too much on minimal hosts (e.g. installing Android SDK on a writing-only laptop) or too little. Several other handoffs (package-manifest, dev-tools, windows-portability) reference roles that this handoff is responsible for defining.

## goal
Define a small, stable set of "machine profiles" or "roles" that the bootstrap orchestrator can use to gate which phases run on which host, and pick how the active profile is selected.

## context
- The user's hosts already differ: WSL2 mobile dev, Mac (future), potential lightweight Linux. Some need mobile toolchain, some only need Claude+Codex+editor.
- Today, dotfiles bundles all assumptions in `.bashrc` (which leaks `JAVA_HOME`, `ANDROID_HOME`, Flutter PATH) and `setup.sh` (which always tries to sync codex skills). There is no notion of "minimal" vs "full".
- A stable role taxonomy stops every other strengthening track from inventing its own gate.

## current state
- No profile/role mechanism exists.
- [.bashrc](../.bashrc) hard-codes Linux + mobile-dev assumptions globally.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Single env var (`DOTFILES_PROFILE=core,mobile-dev,claude`) consumed by every phase. | Simple, scriptable, default value lives in `~/.dotfiles.env` (gitignored). | User has to maintain the env var per host. |
| B. Hostname-based auto-detection (mapping `hostname → roles` in a checked-in YAML) | Zero config on known hosts. | Doesn't help on fresh hosts before they're added to the map. |
| C. OS+arch-only inference (no explicit roles, infer everything) | Minimal user-facing state. | Cannot distinguish mobile-dev WSL2 from a writing-only WSL2. |

## recommendation
Adopt option A as the primary mechanism, with option B as an opt-in convenience layer on top: `~/.config/dotfiles/profile` holds a single line `DOTFILES_PROFILE=core,mobile-dev,claude` (comma-separated, no spaces, gitignored), and a `hosts.yaml` checked into the repo can seed it on first run for known hostnames. Roles to start with: `core` (always), `mobile-dev`, `claude`, `codex`, `desktop-only`. The bootstrap orchestrator reads the active set and skips phases whose role is not active. A helper `dotfiles_has_role <role>` (defined in `lib/bootstrap/profile.sh`, owned by this track) is the only sanctioned query path — consumers (verify-script checks, secret filtering, `shell/common.sh` gating) source it instead of parsing the file themselves, so the format can evolve in one place.

## acceptance criteria
- [ ] Role taxonomy is documented in [`docs/`](.).
- [ ] `bootstrap.sh` reads the active profile from `~/.config/dotfiles/profile` (override with `--profile=...`).
- [ ] Every phase declares the role it belongs to and is skipped when the role is inactive.
- [ ] `shell/common.sh` (created by the macos-support rc refactor, which owns that file) gates mobile-dev env exports on the role being active via `dotfiles_has_role`.
- [ ] Adding a new role does not require touching every phase.

## dependencies
- referenced by: package-manifest, dev-tools-bootstrap, windows-portability, codex-cli-bootstrap, macos-support.
- pairs with: bootstrap-orchestrator (it consumes the profile); macos-support (owns creating `shell/common.sh` — this track only adds the role gate inside it).

## next action
- Human: confirm option A, agree the initial role list.
- After approval: open child implementation handoff for the profile loader and a documentation page.
