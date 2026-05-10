# Agent Handoff: Windows / WSL2 portability boundary

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
low — Windows-specific assets (.wslconfig, AHK, task scheduler) already exist under `os/windows/`, and they are not what blocks one-batch bootstrap. But they need explicit OS gating once macOS ships, otherwise the bootstrap will try to run them on the wrong host.

## goal
Make `os/windows/` strictly OS-gated, document what is required on the Windows host (outside dotfiles) versus what runs on WSL2 (inside dotfiles), and ensure Mac runs do not even consider these paths.

## context
- [os/windows/.wslconfig](../os/windows/.wslconfig) is meant to live under `C:\Users\<user>\` on the Windows host, not in WSL2.
- [os/windows/ahk/](../os/windows/ahk/) is AutoHotkey scripts that the Windows host runs at logon.
- [os/windows/task_scheduler/](../os/windows/task_scheduler/) covers the AHK auto-launch.
- USB passthrough (usbipd-win) is documented in [dev-environments/wsl2-arm64.md](../dev-environments/wsl2-arm64.md) but lives on the Windows side.
- None of these are deployed by `setup.sh`.

## current state
- Windows assets are tracked but unowned by any installer.
- Manual deployment instructions are scattered (README, dev-environments).

## options
| option | summary | tradeoff |
|---|---|---|
| A. `os/windows/install.ps1` that the user runs once on the Windows host, plus a "WSL2-only" gate in `bootstrap.sh`. | Symmetric with `os/mac/`; single Windows command. | PowerShell required; user has to remember. |
| B. Document only, no script. | Cheapest. | Defeats one-batch goal for Windows. |
| C. Drop Windows assets entirely from dotfiles, treat them as out-of-repo personal config. | Smaller repo. | Loses the existing AHK / wsl-config; user has to remember elsewhere. |

## recommendation
Adopt option A. PowerShell installer is small (copy `.wslconfig`, register AHK with task scheduler), the user runs it once per Windows host. `bootstrap.sh` adds a guard "if running on WSL2, skip Windows-host install" so phases never accidentally try to invoke PowerShell from inside WSL.

## acceptance criteria
- [ ] `os/windows/install.ps1` deploys `.wslconfig`, AHK, and task scheduler entries.
- [ ] `bootstrap.sh` detects WSL2 vs native Linux vs macOS and skips Windows-host paths automatically.
- [ ] [README.md](../README.md) gains a "Windows host setup" section with the one PowerShell command.
- [ ] Mac runs do not reference `os/windows/` at all.

## dependencies
- pairs with: macos-support, machine-profile (`wsl2` as a profile axis), package-manifest (usbipd-win install hint).

## next action
- Human: confirm option A.
- After approval: open child implementation handoff for the PowerShell installer.
