# Agent Handoff: dev/tools bootstrap (Flutter / JDK / Android SDK)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — Flutter + Android tooling is the user's largest non-shell setup and currently entirely manual. Without it, mobile development on a new host stalls until the entire `wsl2-arm64.md` checklist is replayed.

## goal
Promote the WSL2-arm64 manual procedure for installing Flutter, JDK 17, Android SDK, and the qemu-user-static cross-arch shim into a scripted bootstrap phase that can be opted in via the machine-profile (`mobile-dev` role).

## context
- [`~/dev/tools/flutter`](../../dev/tools/flutter) and [`~/dev/tools/jdk-17.0.18+8`](../../dev/tools/jdk-17.0.18+8) live outside the dotfiles repo today and are produced by hand-following [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md).
- The wsl2-arm64 doc is intricate (qemu-user-static for x86_64 build-tools, amd64 multilib apt sources, `flutter doctor --android-licenses`, USB passthrough via usbipd-win). That intricacy is exactly the reason it deserves a script: every step is a known failure point on retry.
- On macOS the Flutter install is `brew install --cask flutter` (or tarball); Android Studio + sdkmanager from the cask. The arm64 cross-arch problem does not exist on Apple Silicon for non-Android components.
- Currently there is nothing in dotfiles that owns this — the wisdom is captured prose-only.

## current state
- [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md) — the reference doc, manually executed.
- No installer, no version pins, no detection of "already installed" states.
- `~/.bashrc` already exports `JAVA_HOME`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, and prepends Flutter to PATH unconditionally; on a fresh host these point at non-existent paths until the user manually installs the binaries.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Bash installer per platform under `lib/bootstrap/devtools/{flutter,android,jdk}.sh`, gated on `mobile-dev` role. | Complete control, encodes the wsl2 cross-arch shim verbatim. | Bash for Android SDK install is finicky; needs careful idempotency. |
| B. Adopt `mise` (or asdf) for Flutter+JDK, write only the Android SDK installer. | Less code, version pinning becomes declarative. | Adds `mise` as a dependency for the user. |
| C. Document only, no automation. | Cheapest. | Defeats one-batch goal; wsl2 doc is the single most fragile setup. |

## recommendation
Adopt option A. The wsl2-arm64 procedure is too OS- and arch-specific for a generic version manager to replace cleanly, and option B would still leave the qemu/multilib half manual. The installer is split per concern — `jdk.sh`, `flutter.sh`, `android-sdk.sh`, `wsl2-cross-arch.sh` — each idempotent. OS/arch detection defers to the shared `lib/bootstrap/os-detect.sh` helper (bootstrap-orchestrator track) rather than per-script `uname` calls. Scope boundary: these installers place binaries only — the `JAVA_HOME`/`ANDROID_HOME`/Flutter PATH export lines live in `shell/common.sh`, owned by the macos-support rc refactor (OS guard) with role gating from machine-profile, not by these scripts. The `dev-environments/wsl2-arm64.md` doc is rewritten to reference the scripts as the source of truth and only narrates the *why* and the known pitfalls.

## acceptance criteria
- [ ] `bash bootstrap.sh --phase devtools --role mobile-dev` installs Flutter, JDK 17, Android SDK, and (on WSL2 arm64) the qemu-user-static + amd64 multilib shim.
- [ ] Reruns are idempotent and report what is skipped vs installed.
- [ ] Versions are pinned (Flutter channel + version, JDK 17 minor, build-tools major).
- [ ] [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md) keeps only narrative + pitfalls; commands defer to scripts.
- [ ] On non-WSL Linux and macOS the cross-arch shim is correctly skipped.

## dependencies
- depends on: package-manifest (apt deps for cross-arch, brew formulae for Mac), machine-profile (role gate).
- blocks: any new project that assumes Flutter is on PATH.

## next action
- Human: confirm option A and the version pins (Flutter stable channel? specific x.y?).
- After approval: open child implementation handoff for the `devtools` script split.
