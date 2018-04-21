#!/bin/bash -eu

[ -p /dev/stdin ] && export relate_path=`cat -` || export relate_path=${1}
if [ -e ${relate_path} ];then
  if [ -d ${relate_path} ]; then
    echo $(cd ${relate_path};pwd)
  else
    if [ -f ${relate_path} ]; then
      dir_path=$(dirname ${relate_path})
      absolute_dir_path=$(cd ${dir_path};pwd)
      echo ${absolute_dir_path}/$(basename ${relate_path})
    else
      exit 1
    fi
  fi
fi


