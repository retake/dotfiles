#!/usr/bin/env bash
set -euo pipefail

target_dir="${HOME}/.codex/skills"
dotfiles_dir="${HOME}/dotfiles/codex/skills"
dev_dir="${HOME}/dev/.codex/skills"

mkdir -p "${target_dir}"

# Keep built-in/system skills untouched. Managed skills are symlinked in with:
# 1. dotfiles as the default source of truth
# 2. ~/dev/.codex/skills as an optional local overlay that wins on conflicts
for source_dir in "${dotfiles_dir}" "${dev_dir}"; do
  [[ -d "${source_dir}" ]] || continue

  for skill_path in "${source_dir}"/*; do
    [[ -d "${skill_path}" ]] || continue
    skill_name="$(basename "${skill_path}")"
    ln -sfn "${skill_path}" "${target_dir}/${skill_name}"
  done
done

# Remove broken symlinks left behind by renamed or deleted managed skills.
find -L "${target_dir}" -maxdepth 1 -mindepth 1 -type l -delete
