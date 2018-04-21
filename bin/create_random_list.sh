#!/bin/bash -eu

# --- usage ---
usage() {
  echo "Usage: \"sh ${0} [target_path] [split_number]\""
}
# --- usage ---

# --- initialize ---
if [ "${1}" = "" ]; then
  target_path=./
else
  target_path=${1}
fi

if [ "${2}" = "" ]; then
  parallel_number=1
else
  parallel_number=${2}
fi
# --- initialize ---

# --- error check ---
if [ ! -e ${target_path} ]; then
  echo "target_path is not exist"
  usage
  exit 1
fi

if [ ${parallel_number} -eq 0 ]; then
  echo "parallel_number must be 1 or more"
  usage
  exit 1
fi
# --- error check ---

# --- functions ---
file_paths() {
  sudo find "${target_path}" -name "*.sh" -type f
}
# --- functions ---



# --- main ---
file_paths | while read file_path
do
  file_number=$((($(random_number.sh) % ${parallel_number}) + 1 ))
  echo "${file_number}: ${file_path}"
done
# --- main ---


