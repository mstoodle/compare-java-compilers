#!/bin/bash

for USERS in 40
do
        echo "Runnning with $USERS users"
	sudo numactl --physcpubind=16-23 ./wrk --interval 1 --threads=$USERS --connections=$USERS -d180s http://127.0.0.1:8080/fruits;
done

