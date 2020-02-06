#!/bin/bash 

if [[ "$1" == "--build" ]]; then
	./build.sh | tee build.sh.out
	shift
fi

do-all-runs() {
	RUNS=$1
        JITCORES=$2
        APPCORES=$3

        echo "Runs with APPCORES=$APPCORES and JITCORES=$JITCORES"
        ./run-server.sh         $RUNS $APPCORES jdk8 native
        ./run-server.sh         $RUNS $APPCORES jdk8 native-tuned
        ./run-server.sh         $RUNS $APPCORES jdk8 hs
        ./run-server.sh         $RUNS $APPCORES jdk8 j9
        ./run-server.sh         $RUNS $APPCORES jdk8 j9-sc
        ./run-server.sh         $RUNS $APPCORES jdk8 j9-scvirt
        ./run-server.sh         $RUNS $APPCORES jdk11 hs
        ./run-server.sh         $RUNS $APPCORES jdk11 hs-jaotc
        ./run-server.sh         $RUNS $APPCORES jdk11 hs-jaotc-full
        ./run-server.sh         $RUNS $APPCORES jdk11 hs-jaotc-tier
        ./run-server.sh         $RUNS $APPCORES jdk11 graal
        ./run-server.sh         $RUNS $APPCORES jdk11 j9
        ./run-server.sh         $RUNS $APPCORES jdk11 j9-sc
        ./run-server.sh         $RUNS $APPCORES jdk11 j9-scvirt

        ./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk8 j9-jitserver
        ./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk8 j9-sc-jitserver
        ./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk11 j9-jitserver
        ./run-with-jitserver.sh $RUNS $JITCORES $APPCORES jdk11 j9-sc-jitserver
}

# Give 2 chances for foolishness
rm -rf runs-old2 > /dev/null
mv -f runs-old1 runs-old2 > /dev/null
mv -f runs      runs-old1 > /dev/null
mkdir runs

./run-docker-db.sh

RUNS=5
if [[ $1 > 0 ]]; then
        RUNS=$1
fi

# Do single core runs on at least a 4-core machine
APPCORES="0"
JITCORES="1-3"
do-all-runs.sh $RUNS $JITCORES $APPCORES

# Uncomment to do 4 core runs on at least an 8-core machine
#APPCORES="4-7"
#JITCORES="0-3"
#do-all-runs.sh $RUNS $JITCORES $APPCORES

# Uncomment next 3 lines to do 24 core runs on at least a 32-core machine
#APPCORES="0-23"
#JITCORES="24-31"
#do-all-runs.sh $RUNS $JITCORES $APPCORES

./stop-docker-db.sh

for r in $RUNS; do
	./extract.su.awk runs/out.*-$r > runs/all.su.$r.txt
	./extract.fp.awk runs/fp.*-$r  > runs/all.fp.$r.txt
	./extract.tp.awk runs/tp.*-$r  > runs/all.tp.$r.txt
	./extract.cr.awk runs/tp.*-$r  > runs/all.cr.$r.txt
done
