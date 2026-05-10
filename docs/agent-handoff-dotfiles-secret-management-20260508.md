# Agent Handoff: secret management strategy

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
high — Secrets currently live as cleartext files outside the repository, so a "one-batch new-machine restore" is impossible by construction, and any accidental commit of `.credentials` or `claude/.mcp.env` would leak live tokens.

## goal
Choose a portable mechanism for storing and restoring personal secrets (shell exports, MCP API keys, OAuth client secrets, GitHub PAT) so that a new host can be brought up to working state with the same one-batch flow that drives the rest of dotfiles, without committing secrets to the repository.

## context
- Today's secrets live in two cleartext files: [`~/.credentials`](../.credentials) (sourced by `.bash_profile`) and [`claude/.mcp.env`](../claude/.mcp.env) (consumed by `setup-claude.sh`).
- Both are correctly excluded by [.gitignore](../.gitignore), but they are unstructured, unencrypted, and have no documented restore path on a new machine — the user would have to copy them by hand.
- `setup-claude.sh` only prints a warning when `claude/.mcp.env` is missing; the resulting `~/.claude/settings.json` ships unfilled `__TOKEN__` placeholders.
- Tokens currently in scope: `OPENAI_API_KEY`, `TODOIST_API_TOKEN`, `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GITHUB_TOKEN` / GitHub PAT, plus future additions.
- Mac and Linux must both work; WSL2 typically does not have GUI keychain access easily available.

## current state
- [`.credentials`](../.credentials) — cleartext, contains live `GITHUB_TOKEN` PAT and Todoist token.
- [`claude/.mcp.env`](../claude/.mcp.env) — cleartext, contains live Todoist token + Google OAuth secrets.
- No rotation policy. No checksum or schema for required keys. No "what to do on a fresh machine" doc beyond `vim ~/.credentials`.

## options
| option | summary | restore UX | tradeoff |
|---|---|---|---|
| A. `pass` (gpg-backed) + GPG key on YubiKey or backup | Standard Unix tool. Encrypted store can live in a separate private git repo. | `pass show` per key, scripted into a `secrets-restore.sh` phase. | Requires GPG bootstrap on every new host; YubiKey raises the bar. |
| B. `age` + key file synced via private channel | Modern, simpler than GPG, key file is a single Ed25519 secret. | `age --decrypt` once to expand `secrets.env.age` into `~/.credentials`. | Still needs the age key delivered out-of-band. |
| C. 1Password CLI (`op`) with personal account | Centralized secret vault across machines, no local crypto state. | `op inject` template files into `~/.credentials` and `~/.mcp.env`. | Vendor lock-in; subscription dependency; offline restore is awkward. |
| D. Encrypted file in private git repo (`dotfiles-secrets`) submoduled in via SSH | Symmetric: one private repo carries `secrets.env.age` or similar. | `git clone` the private repo, decrypt, link. | Conflates secret storage with git; commit hygiene risk. |
| E. Status quo + documented manual restore | Cheapest. | Hand-edit on every new host. | Defeats the "one-batch" goal. |

## recommendation
Adopt option B (`age`) as the primary mechanism, with the encrypted blob stored either in a sibling private repo (option D) or in a non-git location synced through the user's existing private channel (Drive/iCloud). Reasons: minimal dependencies, single-file Ed25519 key trivial to ship to a new host, works identically on Linux/macOS/WSL2, no vendor lock-in. Layer 1Password (option C) on top later only if the secret count grows past trivial.

## acceptance criteria
- [ ] No cleartext secret files remain in `~/dotfiles/` working tree (other than examples with placeholder values).
- [ ] A documented `bash bootstrap.sh --phase secrets` step decrypts a single source-of-truth blob and produces both `~/.credentials` and `~/.claude/.mcp.env` (or equivalent target paths).
- [ ] Schema is captured: a `secrets.schema.env` (committable, value-less) lists every required key, and `bootstrap.sh --phase verify` fails loudly when keys are missing instead of silently warning.
- [ ] Restore from a new machine is exercised at least once and documented in [`SETUP.md`](../SETUP.md).
- [ ] Token rotation playbook is captured (one paragraph per provider).

## dependencies
- blocks: bootstrap-orchestrator (the secrets phase is part of the orchestrator).
- depends on: package-manifest (age must be in the install list).
- related: existing live tokens in `.credentials` / `.mcp.env` should be rotated as part of the migration to the new mechanism (separate operational task, not a handoff).

## next action
- Human: confirm the recommendation (option B), decide where the encrypted blob lives (sibling private repo vs synced file).
- Human: rotate any tokens that have been sitting in cleartext if doing so is cheap.
- After approval: open child implementation handoff for `lib/bootstrap/secrets.sh` and the schema file.
