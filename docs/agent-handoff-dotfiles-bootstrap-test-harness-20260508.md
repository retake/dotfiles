# Agent Handoff: bootstrap test harness (Docker + GitHub Actions)

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — The whole point of the bootstrap orchestrator is that it works on a fresh host. Without an automated test, drift is detected only on a real new-machine event, when the cost of failure is highest.

## goal
Build a CI harness that exercises `bootstrap.sh` against fresh container images (Ubuntu noble arm64+x86_64, Ubuntu LTS as a control) and a macOS GitHub-hosted runner, asserting that `verify.sh` exits 0 at the end.

## context
- The repository already vendors bats in [tests/](../tests/). It is unused beyond the legacy bash unit tests.
- A clean container is the cheapest way to detect bootstrap regressions; a Mac runner catches macOS-specific drift but costs more (and is GitHub-only).
- A test harness is the natural consumer of the verify-script handoff.

## current state
- [tests/](../tests/) — bats with a few legacy unit tests, no integration coverage of bootstrap.
- No `.github/workflows/bootstrap.yml`.
- No Dockerfile that mirrors the wsl2-arm64 minimum environment.

## options
| option | summary | tradeoff |
|---|---|---|
| A. GitHub Actions matrix: `ubuntu-22.04`, `ubuntu-24.04` (x86_64), `ubuntu-24.04-arm` if available, `macos-14`. Each runs `bootstrap.sh --profile=core,claude` then `verify.sh`. | Straightforward, free for public repos. | dotfiles is private; minutes are billed; arm64 Linux runner availability varies. |
| B. Local Docker harness only (no CI), invoked manually. | No GitHub minutes spent. | Drift is detected only when the user remembers to run it. |
| C. Combine A and B: docker harness for daily local checks, CI for PRs that touch `bootstrap.sh` or `lib/bootstrap/*`. | Best coverage with controlled cost. | Slightly more glue. |

## recommendation
Adopt option C. A `tests/bootstrap/Dockerfile` reproduces a minimal Ubuntu noble box; a `tests/bootstrap/run-docker.sh` runs the bootstrap inside it and prints `verify.sh` output. A GitHub Actions workflow runs the same on PR if changed paths match `bootstrap.sh` or `lib/bootstrap/**`. Mac coverage is opt-in (`workflow_dispatch`) to avoid burning minutes.

## acceptance criteria
- [ ] `tests/bootstrap/Dockerfile` exists and reproduces a known-fresh Ubuntu environment.
- [ ] `bash tests/bootstrap/run-docker.sh` runs `bootstrap.sh` end-to-end inside the container and exits 0.
- [ ] GitHub Actions workflow gates merges that touch bootstrap-related paths.
- [ ] Failure output includes which `verify.sh` check failed and the fix command.

## dependencies
- depends on: bootstrap-orchestrator (target under test), verify-script (assertion oracle), package-manifest (the manifest is what the harness exercises).

## next action
- Human: confirm option C; decide whether GitHub minutes budget allows an always-on workflow or `workflow_dispatch` only.
- After approval: open child implementation handoff for the Docker harness and the workflow.
