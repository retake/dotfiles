#!/bin/bash -x

while [ $# -gt 0 ];
do
	case ${1} in
		--test|-t)
			echo ${2}
	;;
	  --testtest|-tt)
		  echo ${2}
	;;
	esac
	shift
done
