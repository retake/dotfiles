#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  claude-codex-handoff-loop.sh [--repo DIR] [--handoff PATH] [--task-id HO-001] [--max-rounds N] [--dry-run]

Examples:
  claude-codex-handoff-loop.sh --repo ~/dev/alarm --handoff docs/agent-handoff-claudecode-foo-20260416.md
  claude-codex-handoff-loop.sh --repo ~/dev/alarm --task-id HO-001

Behavior:
  - Finds the active handoff for the task
  - Infers loop mode from `## Type`
  - Runs the next owner agent headlessly for one turn
  - When the next owner is Codex, Codex may edit handoff files under `docs/` only
  - Claude remains the only agent that may edit implementation files
  - Re-reads handoff state and repeats until one of these happens:
    * the task is archived
    * the task is done
    * the next owner becomes Human
    * no task file changed
    * the same agent remains owner after its own turn
    * max rounds is reached

Notes:
  - This is intentionally bounded. It is not an unbounded self-confirming loop.
  - Review-response rules still apply. A responder should normally return `waiting`
    to the reviewer instead of self-archiving.
  - In auto-loop mode, Codex may update handoff files only; implementation edits remain Claude-only.
EOF
}

log() {
  printf '[handoff-loop] %s\n' "$*" >&2
}

die() {
  log "ERROR: $*"
  exit 1
}

trim() {
  local value="${1:-}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

extract_heading_value() {
  local file="$1"
  local heading="$2"

  awk -v heading="$heading" '
    $0 == heading { in_section=1; next }
    in_section {
      if ($0 ~ /^## /) exit
      if ($0 ~ /^[[:space:]]*$/) next
      print
      exit
    }
  ' "$file"
}

extract_task_id() {
  trim "$(extract_heading_value "$1" "## task_id")"
}

extract_status() {
  trim "$(extract_heading_value "$1" "## handoff_status")"
}

extract_next_owner() {
  trim "$(extract_heading_value "$1" "## Next Owner")"
}

extract_type() {
  trim "$(extract_heading_value "$1" "## Type")"
}

infer_loop_mode() {
  local handoff="$1"
  local handoff_type
  handoff_type="$(extract_type "$handoff")"

  case "$handoff_type" in
    design-consult|status-update)
      printf 'consult\n'
      ;;
    implementation|review|bug-triage|audit|security-audit|"")
      printf 'implementation\n'
      ;;
    *)
      printf 'implementation\n'
      ;;
  esac
}

find_handoff_files() {
  local repo="$1"
  find "$repo/docs" -type f -name 'agent-handoff-*.md' 2>/dev/null | sort
}

find_matching_files_for_task() {
  local repo="$1"
  local task_id="$2"

  while IFS= read -r file; do
    [[ "$(extract_task_id "$file")" == "$task_id" ]] && printf '%s\n' "$file"
  done < <(find_handoff_files "$repo")
}

newest_file() {
  if [[ $# -eq 0 ]]; then
    return 1
  fi

  local newest=""
  local newest_mtime=0
  local file mtime
  for file in "$@"; do
    [[ -f "$file" ]] || continue
    mtime="$(stat -c '%Y' "$file")"
    if (( mtime >= newest_mtime )); then
      newest_mtime="$mtime"
      newest="$file"
    fi
  done

  [[ -n "$newest" ]] && printf '%s\n' "$newest"
}

find_active_handoff() {
  local repo="$1"
  local task_id="$2"
  local -a matches=()
  local file

  while IFS= read -r file; do
    [[ "$file" == "$repo/docs/"* ]] || continue
    [[ "$file" == "$repo/docs/archive/"* ]] && continue
    matches+=("$file")
  done < <(find_matching_files_for_task "$repo" "$task_id")

  if (( ${#matches[@]} == 0 )); then
    return 1
  fi

  if (( ${#matches[@]} > 1 )); then
    die "multiple active handoffs for $task_id: ${matches[*]}"
  fi

  printf '%s\n' "${matches[0]}"
}

has_archived_handoff() {
  local repo="$1"
  local task_id="$2"
  local file

  while IFS= read -r file; do
    [[ "$file" == "$repo/docs/archive/"* ]] || continue
    return 0
  done < <(find_matching_files_for_task "$repo" "$task_id")

  return 1
}

snapshot_task_state() {
  local repo="$1"
  local task_id="$2"
  local -a files=()
  local file

  while IFS= read -r file; do
    files+=("$file")
  done < <(find_matching_files_for_task "$repo" "$task_id")

  if (( ${#files[@]} == 0 )); then
    printf 'no-files\n'
    return 0
  fi

  {
    for file in "${files[@]}"; do
      printf '=== %s ===\n' "$file"
      cat "$file"
      printf '\n'
    done
  } | sha256sum | awk '{print $1}'
}

resolve_codex_bin() {
  if command -v codex >/dev/null 2>&1; then
    command -v codex
    return 0
  fi

  local fallback
  fallback="$(ls -d "$HOME"/.vscode-server/extensions/openai.chatgpt-*/bin/linux-aarch64/codex 2>/dev/null | sort -V | tail -1)"
  [[ -n "$fallback" && -x "$fallback" ]] || die "codex binary not found"
  printf '%s\n' "$fallback"
}

build_claude_prompt() {
  local repo="$1"
  local task_id="$2"
  local handoff="$3"
  local loop_mode="$4"

  cat <<EOF
You are operating a bounded handoff loop for repository: $repo

Read:
- AGENT_GUIDE.md
- docs/agent-handoff-template.md

Target task:
- task_id: $task_id
- active handoff: $handoff
- loop_mode: $loop_mode

Goal:
- Take exactly one Claude-side turn for this task.
- Use the repository's existing handoff process.
- If useful, use the audit-handoffs workflow or equivalent review process.

Rules:
- Follow review-response rules in AGENT_GUIDE.md.
- Do not self-archive a review response unless the reviewer explicitly allowed it.
- Keep the task bounded to this task_id only.
- Update or create only the minimal handoff file(s) needed for the next step.
- Leave a clear Next Owner and Next Action.
- If loop_mode=consult, prefer concluding with handoff_status=done and Next Owner=Human once the recommendation or decision is clear. Do not archive consult-only conclusions unless the repo rules or the user explicitly ask for it.
- If loop_mode=implementation, prefer reviewer confirmation and archived closure. Use done only when a human sign-off is still required.

Stop after the handoff state is advanced by one turn.
Final response: one short line summarizing what changed and which files were touched.
EOF
}

build_codex_prompt() {
  local repo="$1"
  local task_id="$2"
  local handoff="$3"
  local loop_mode="$4"

  cat <<EOF
Use the claudecode-handoff-loop skill.

Repository: $repo
Read:
- AGENT_GUIDE.md
- docs/agent-handoff-template.md

Target task:
- task_id: $task_id
- active handoff: $handoff
- loop_mode: $loop_mode

Do exactly one Codex-side turn for this task.
Review the current active handoff and update handoff files only.

Rules:
- Stay within this task_id.
- Respect review-response rules.
- You may edit only handoff files under docs/ (including docs/archive/ when archive rules allow it).
- Do not edit implementation files such as lib/, test/, src/, app/, package manifests, CI config, or non-handoff docs.
- If you disagree with Claude, write the disagreement and the proposed compromise into the handoff.
- Leave a clear Next Owner and Next Action unless the task is genuinely archived or done.
- If loop_mode=consult, prefer done + Human over archive once the recommendation or decision is clear.
- If loop_mode=implementation, prefer archived after reviewer confirmation. Use done only when a human sign-off is still required.

Final response: a short summary of what handoff files you updated.
EOF
}

run_claude_turn() {
  local repo="$1"
  local task_id="$2"
  local handoff="$3"
  local loop_mode="$4"
  local run_dir="$5"
  local round="$6"

  local claude_bin
  claude_bin="$(command -v claude || true)"
  [[ -n "$claude_bin" ]] || die "claude binary not found"

  local prompt_file="$run_dir/claude-round-${round}.prompt.txt"
  local log_file="$run_dir/claude-round-${round}.log.txt"

  build_claude_prompt "$repo" "$task_id" "$handoff" "$loop_mode" >"$prompt_file"

  log "round $round: Claude turn for $task_id ($handoff)"

  if (( DRY_RUN )); then
    log "dry-run: claude -p --permission-mode acceptEdits < $prompt_file"
    return 0
  fi

  (
    cd "$repo"
    "$claude_bin" \
      -p \
      --permission-mode acceptEdits \
      <"$prompt_file" >"$log_file"
  )
}

run_codex_turn() {
  local repo="$1"
  local task_id="$2"
  local handoff="$3"
  local loop_mode="$4"
  local run_dir="$5"
  local round="$6"

  local codex_bin
  codex_bin="$(resolve_codex_bin)"

  local prompt_file="$run_dir/codex-round-${round}.prompt.txt"
  local log_file="$run_dir/codex-round-${round}.log.txt"
  local last_message_file="$run_dir/codex-round-${round}.last.txt"

  build_codex_prompt "$repo" "$task_id" "$handoff" "$loop_mode" >"$prompt_file"

  log "round $round: Codex turn for $task_id ($handoff)"

  if (( DRY_RUN )); then
    log "dry-run: codex exec --full-auto -C $repo/docs -o $last_message_file - < $prompt_file"
    return 0
  fi

  "$codex_bin" exec \
    --full-auto \
    -C "$repo/docs" \
    -o "$last_message_file" \
    - <"$prompt_file" >"$log_file"
}

REPO="$(pwd)"
HANDOFF=""
TASK_ID=""
MAX_ROUNDS=6
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --handoff)
      HANDOFF="$2"
      shift 2
      ;;
    --task-id)
      TASK_ID="$2"
      shift 2
      ;;
    --max-rounds)
      MAX_ROUNDS="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

REPO="$(realpath "$REPO")"
[[ -d "$REPO" ]] || die "repo not found: $REPO"
[[ -f "$REPO/AGENT_GUIDE.md" ]] || die "AGENT_GUIDE.md not found in $REPO"
[[ -f "$REPO/docs/agent-handoff-template.md" ]] || die "docs/agent-handoff-template.md not found in $REPO"

if [[ -n "$HANDOFF" ]]; then
  if [[ "$HANDOFF" != /* ]]; then
    HANDOFF="$REPO/$HANDOFF"
  fi
  HANDOFF="$(realpath "$HANDOFF")"
  [[ -f "$HANDOFF" ]] || die "handoff not found: $HANDOFF"
fi

if [[ -z "$TASK_ID" && -n "$HANDOFF" ]]; then
  TASK_ID="$(extract_task_id "$HANDOFF")"
fi

if [[ -z "$TASK_ID" ]]; then
  latest_active="$(find "$REPO/docs" -maxdepth 1 -type f -name 'agent-handoff-*.md' | sort | tail -n 1 || true)"
  [[ -n "$latest_active" ]] || die "could not infer task_id and no active handoff exists"
  TASK_ID="$(extract_task_id "$latest_active")"
  HANDOFF="$latest_active"
fi

[[ -n "$TASK_ID" ]] || die "task_id is empty"

if [[ -z "$HANDOFF" ]]; then
  HANDOFF="$(find_active_handoff "$REPO" "$TASK_ID" || true)"
fi

state_root="${HANDOFF_LOOP_STATE_DIR:-${XDG_CACHE_HOME:-/tmp}/claude-codex-handoff-loop}"
run_dir="$state_root/$(basename "$REPO")/$TASK_ID/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$run_dir"

log "repo=$REPO"
log "task_id=$TASK_ID"
log "run_dir=$run_dir"

for (( round=1; round<=MAX_ROUNDS; round++ )); do
  active_handoff="$(find_active_handoff "$REPO" "$TASK_ID" || true)"

  if [[ -z "$active_handoff" ]]; then
    if has_archived_handoff "$REPO" "$TASK_ID"; then
      log "task $TASK_ID archived; loop finished"
      exit 0
    fi
    die "no active handoff found for $TASK_ID"
  fi

  current_owner="$(extract_next_owner "$active_handoff")"
  current_status="$(extract_status "$active_handoff")"
  loop_mode="$(infer_loop_mode "$active_handoff")"
  before_snapshot="$(snapshot_task_state "$REPO" "$TASK_ID")"

  log "round=$round active=$active_handoff mode=${loop_mode} status=${current_status:-unknown} next_owner=${current_owner:-unknown}"

  if [[ "$current_status" == "done" ]]; then
    log "task $TASK_ID is done; loop finished"
    exit 0
  fi

  case "$current_owner" in
    "Claude Code"|ClaudeCode|Claude)
      run_claude_turn "$REPO" "$TASK_ID" "$active_handoff" "$loop_mode" "$run_dir" "$round"
      ran_agent="Claude Code"
      ;;
    Codex)
      run_codex_turn "$REPO" "$TASK_ID" "$active_handoff" "$loop_mode" "$run_dir" "$round"
      ran_agent="Codex"
      ;;
    Human|"")
      log "next owner is Human or empty; stopping for manual intervention"
      exit 0
      ;;
    *)
      die "unsupported Next Owner '$current_owner' in $active_handoff"
      ;;
  esac

  after_snapshot="$(snapshot_task_state "$REPO" "$TASK_ID")"
  if [[ "$before_snapshot" == "$after_snapshot" ]]; then
    log "no task file change after $ran_agent turn; stopping"
    exit 0
  fi

  active_handoff="$(find_active_handoff "$REPO" "$TASK_ID" || true)"
  if [[ -z "$active_handoff" ]]; then
    if has_archived_handoff "$REPO" "$TASK_ID"; then
      log "task $TASK_ID archived after $ran_agent turn; loop finished"
      exit 0
    fi
    log "no active handoff remains after $ran_agent turn; stopping"
    exit 0
  fi

  current_status="$(extract_status "$active_handoff")"
  if [[ "$current_status" == "done" ]]; then
    log "task $TASK_ID reached done after $ran_agent turn; loop finished"
    exit 0
  fi

  next_owner="$(extract_next_owner "$active_handoff")"
  if [[ "$next_owner" == "$ran_agent" ]]; then
    log "next owner still $ran_agent after its own turn; stopping to avoid self-loop"
    exit 0
  fi
done

log "max rounds reached ($MAX_ROUNDS); stopping"
