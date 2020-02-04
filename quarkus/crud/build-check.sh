#!/bin/bash
if [[ $# < 1 ]]; then
	echo "Usage: $0 <logged output from build.sh>"
	exit -1
fi
grep 'Successfully tagged' $1
