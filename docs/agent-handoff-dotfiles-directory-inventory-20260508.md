# Agent Handoff: directory inventory & physical-vs-symlink map

## status
open

## type
design-consult

## owner
Human

## next_owner
Human

## priority
medium — Several user-visible paths (`~/dev`, `~/consulting`, `~/retrospectives`, `~/.claude`, `~/.codex`) are produced by a mix of symlinks, generated files, and out-of-repo state. There is no single document that says where the truth lives. A new-machine restore needs that map.

## goal
Produce a canonical inventory of every path the daily environment touches, classifying each as (a) physical content in dotfiles, (b) symlink into dotfiles, (c) generated from a template, (d) decrypted from secrets, or (e) local-only / not bootstrapped.

## context
- Inspection of `~/` shows a mix:
  - Symlinks into dotfiles: `~/.bashrc`, `~/.bash_profile`, `~/.gitconfig`, `~/.cheatsheet.md`, `~/.vim`, `~/.config/starship.toml`, `~/.config/nvim`, `~/.claude/CLAUDE.md`, `~/.claude/skills/...`, `~/retrospectives` → dotfiles.
  - Generated from template: `~/.claude/settings.json`, `~/.mcp.json`.
  - Per-host, not bootstrapped: `~/.codex/auth.json`, `~/.codex/memories/`, `~/.claude/.credentials.json`, `~/dev/tools/flutter/`, `~/dev/tools/jdk-17.0.18+8/`, `~/.flutter`, `~/.pub-cache/`, `~/android-sdk/`.
  - Symlinks under `~/dev/`: `~/dev/CLAUDE.md → dotfiles/claude/dev-CLAUDE.md`, `~/dev/ai-coding-principles.md → dotfiles/claude/dev-ai-coding-principles.md`, `~/dev/ai-agent-workflow → dotfiles/claude/ai-agent-workflow`, `~/dev/environments → dotfiles/dev-environments`.
  - Symlink under `~/consulting/`: `~/consulting/CLAUDE.md → dotfiles/claude/roles/consulting/CLAUDE.md`.
  - Nested independent git repos: `dotfiles/claude/ai-agent-workflow` (separate `.git`).
- The only documents that touch this topology are [README.md](../README.md) and [SETUP.md](../SETUP.md), and they are incomplete.

## current state
- No inventory file.
- The presence of nested git repos (`ai-agent-workflow`) and out-of-tree symlinks (`~/dev/ai-agent-workflow → dotfiles/claude/ai-agent-workflow`) is captured in `.gitignore` comments but not in user-facing docs.

## options
| option | summary | tradeoff |
|---|---|---|
| A. Single `docs/layout.md` with an annotated tree and a "managed by" column per path. | Easy to read, easy to keep current. | Manual maintenance discipline. |
| B. Generated inventory from the bootstrap scripts (introspect what they create). | Always fresh. | Heavier to build; intermediate complexity. |
| C. Directory diagram in README.md only. | Lowest effort. | README gets bloated; can't link from individual handoffs. |

## recommendation
Adopt option A. A `docs/layout.md` that lists every managed path with: physical location, symlink target, owning script/template, role gate, and out-of-band restore step. README links to it. Each strengthening track in this round of handoffs adds a row when it lands. Option B can layer on later if drift becomes a problem.

## acceptance criteria
- [ ] [`docs/layout.md`](layout.md) exists and lists every dotfile symlink, every template-generated file, every secret-restored file, and every "external tool" path the daily flow assumes.
- [ ] Each row identifies the owning bootstrap phase (or "manual / not bootstrapped").
- [ ] [README.md](../README.md) and [SETUP.md](../SETUP.md) link to it from the top.
- [ ] Nested git repo and `~/dev/ai-agent-workflow` symlink are explicitly called out.

## dependencies
- pairs with: bootstrap-orchestrator (the inventory is the surface area the orchestrator manages), claude-state-sync, template-bootstrap.
- precedes: readme-setup-refresh (the refresh consumes this layout doc).

## next action
- Human: confirm option A.
- After approval: open child implementation handoff to author `docs/layout.md` by walking the existing scripts.
