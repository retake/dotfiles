#!/bin/bash -eu

rand_no=${RANDOM}
# ↓ は$RANDOM が使用出来ない環境
[ "${rand_no}" = "" ] && rand_no=`od -vAn -N4 -tu4 < /dev/random`
echo ${rand_no}

