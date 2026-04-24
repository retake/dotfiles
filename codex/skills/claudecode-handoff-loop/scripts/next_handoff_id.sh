#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"

if [[ -d "$root/docs" ]]; then
  search_root="$root/docs"
else
  search_root="$root"
fi

max_id=0

while IFS= read -r raw_id; do
  [[ -z "$raw_id" ]] && continue
  num="${raw_id#HO-}"
  num=$((10#$num))
  if (( num > max_id )); then
    max_id="$num"
  fi
done < <(rg -o --no-filename 'HO-[0-9]+' "$search_root" 2>/dev/null || true)

printf 'HO-%03d\n' "$((max_id + 1))"
