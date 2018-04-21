#!/bin/bash -eu

if [ -p /dev/stdin ]; then
  echo "after_pipe!"
  cat -
fi

if [ -p /dev/stdout ]; then
  echo "before_pipe!"
fi

