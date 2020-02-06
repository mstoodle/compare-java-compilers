#!/bin/bash

# Uncomment to run wrk load on particular cores and update core description for your machine
#BIND="sudo numactl --physcpubind=64-71"
# You can also run the script as BIND="sudo numactl --physcpubind=64-71" ./run-load.sh

# By default, look at 40 concurrent users
if [[ "$USERS" == "" ]]; then
	USERS=40
fi

echo "Runnning with $USERS users"
$BIND ./wrk --interval 1 --threads=$USERS --connections=$USERS -d180s http://127.0.0.1:8080/fruits;
