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
mv -f runs-old1 runs-old2 > /dev/null
mv -f runs      runs-old1 > /dev/null
mkdir runs

./run-docker-db.sh

APPCORES="0"
JITCORES="1-3"
echo Runs with APPCORES=$APPCORES and JITCORES=$JITCORES

./run-server.sh         $RUNS $APPCORES jdk8 native
./run-server.sh         $RUNS $APPCORES jdk8 native-tuned
./run-server.sh         $RUNS $APPCORES jdk8 hs
./run-server.sh         $RUNS $APPCORES jdk8 j9
./run-server.sh         $RUNS $APPCORES jdk8 j9-sc
./run-server.sh         $RUNS $APPCORES jdk8 j9-scvirt
./run-server.sh         $RUNS $APPCORES jdk11 hs
./run-server.sh         $RUNS $APPCORES jdk11 hs-jaotc
./run-server.sh         $RUNS $APPCORES jdk11 hs-jaotc-tier
./run-server.sh         $RUNS $APPCORES jdk11 graal
./run-server.sh         $RUNS $APPCORES jdk11 j9
./run-server.sh         $RUNS $APPCORES jdk11 j9-sc
./run-server.sh         $RUNS $APPCORES jdk11 j9-scvirt

./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk8 j9-jitserver
./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk8 j9-sc-jitserver
./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk11 j9-jitserver
./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk11 j9-sc-jitserver

./stop-docker-db.sh

./extract.su.awk runs/out.* > runs/all.su.txt
./extract.fp.awk runs/fp.*  > runs/all.fp.txt
./extract.tp.awk runs/tp.*  > runs/all.tp.txt
