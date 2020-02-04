#!/bin/bash
if [[ $# < 1 ]]; then
	echo "Usage: $0 <logged output from build.sh>"
	exit -1
fi
grep 'Successfully tagged' $1
NUMSUCCESS=`grep -c 'Successfully tagged' $1`
if [[ $NUMSUCCESS == 19 ]]; then
	echo All images sucessfully built!
else
	echo Should be 19 images, only got $NUMSUCCESS
fi
