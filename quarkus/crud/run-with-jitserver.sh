#/bin/bash -f

if [[ $# < 5 ]]; then
	echo "Usage: $0 <#runs> <JIT cores> <appserver cores> <jdk8 or jdk11> <variant used in image names>"
	exit -1
fi

RUNS=$1
JIT_CORES=$2
APPSERVER_CORES=$3
JDK=$4
VARIANT=$5

sudo docker run -d --name jitserv-${JDK} -t --cpuset-cpus=$JIT_CORES --rm -p 38400:38400 --network host jitserver-${JDK}

./run-server.sh ${RUNS} ${APPSERVER_CORES} ${JDK} ${VARIANT}

sudo docker stop jitserv-${JDK}
