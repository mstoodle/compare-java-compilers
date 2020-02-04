#/bin/bash -f

if [[ $# < 3 ]]; then
	echo "Usage: $0 <#runs> <jdk8 or jdk11> <variant used in image names>"
	exit -1
fi

RUNS=$1
JDK=$2
VARIANT=$3

sudo docker run -d --name jitserv-${JDK} -t --cpuset-cpus="16-23" --rm -p 38400:38400 --network host jitserver-${JDK}

./run-server.sh ${RUNS} ${JDK} ${VARIANT}

sudo docker stop jitserv-${JDK}
