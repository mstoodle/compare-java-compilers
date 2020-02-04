#!/bin/bash 

if [[ "$1" == "--build" ]]; then
	./build.sh | tee build.sh.out
	shift
fi

RUNS=5
if [[ $1 > 0 ]]; then
        RUNS=$1
fi

# Give 2 chances for foolishness
rm -rf runs-old2 > /dev/null
mv runs-old1 runs-old2 > /dev/null
mv runs      runs-old1 > /dev/null
mkdir runs

./run-docker-db.sh

./run-server.sh         $RUNS 0 jdk8 native
./run-server.sh         $RUNS 0 jdk8 native-tuned
./run-server.sh         $RUNS 0 jdk8 hs
./run-server.sh         $RUNS 0 jdk8 j9
./run-server.sh         $RUNS 0 jdk8 j9-sc
./run-server.sh         $RUNS 0 jdk8 j9-scvirt
./run-server.sh         $RUNS 0 jdk11 hs
./run-server.sh         $RUNS 0 jdk11 hs-jaotc
./run-server.sh         $RUNS 0 jdk11 hs-jaotc-tier
./run-server.sh         $RUNS 0 jdk11 graal
./run-server.sh         $RUNS 0 jdk11 j9
./run-server.sh         $RUNS 0 jdk11 j9-sc
./run-server.sh         $RUNS 0 jdk11 j9-scvirt

./run-with-jitserver.sh $RUNS 1-3 0 jdk8 j9-jitserver
./run-with-jitserver.sh $RUNS 1-3 0 jdk8 j9-sc-jitserver
./run-with-jitserver.sh $RUNS 1-3 0 jdk11 j9-jitserver
./run-with-jitserver.sh $RUNS 1-3 0 jdk11 j9-sc-jitserver

./extract-su.awk runs/out.* > runs/all.su.txt
./extract-fp.awk runs/fp.* > runs/all.fp.txt
./extract-tp.awk runs/tp.* > runs/all.tp.txt
