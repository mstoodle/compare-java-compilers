#/bin/bash -f

if [[ $# < 3 ]]; then
	echo "Usage: $0 <#runs> <jdk8 or jdk11> <variant used in image names>"
	exit -1
fi

RUNS=$1
JDK=$2
VARIANT=$3
ROOTNAME=rest-crud-quarkus

do_run() {
    run=$1
    suffix="${JDK}-${VARIANT}"
    suffix_run="${suffix}-${run}"

    echo "    Starting server"
    OUT=runs/out.${suffix_run}
    date +"%H:%M:%S:%3N" > $OUT
    sudo docker run -e TZ=`cat /etc/timezone` --name server -t --cpuset-cpus="1" --rm -p 8080:8080 --network host ${ROOTNAME}-${suffix} >> $OUT 2>/dev/null &

    # wait for server to fully start
    sleep 15
    pid_on_host=`sudo docker top server | grep java | awk '{ print $2 }'`

    # apply load to the server
    echo "    Applying load"
    ./run-load.sh ${pid_on_host} > runs/tp.${suffix_run}

    # collect smap at end of run, extract rss
    sudo awk '/Rss/ { t+=$2+0; } END { print t; }' /proc/${pid_on_host}/smaps \
	   > runs/fp.${suffix_run}

    echo "    Stopping server"
    # when load stops, stop the container
    sudo docker stop server > /dev/null
}

for r in `seq 1 $RUNS`; do
    echo Run $JDK-$VARIANT-$r
    do_run $r
done
