#!/bin/bash
#-XX:-StackTraceInThrowable -Xverify:none

CMD=java
if [[ "$1" == "--jitserver" ]]; then
	SERVER=$2
	PORT=$3
	EXTRA_OPTIONS="-XX:+UseJITServer -XX:JITServerPort=$PORT -XX::JITServerAddress=$SERVER"
	shift; # --jitserver
       	shift; # SERVER
       	shift; # PORT
fi

if [[ "$1" == "--jaotc" ]]; then
	EXTRA_OPTIONS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:AOTLibrary=/work/application.so"
elif [[ "$1" == "--sc" ]]; then
	# might be added to --jitserver options so use +=
	EXTRA_OPTIONS="$EXTRA_OPTIONS -Xshareclasses:name=sc,cacheDir=.classCache,cacheDirPerm=1000,readOnly \
			-XX:ShareClassesEnableBCI -Xscmx80m"
elif [[ "$1" == "--scvirt" ]]; then
	# might be added to --jitserver options so use +=
	EXTRA_OPTIONS="$EXTRA_OPTIONS -Xshareclasses:name=scvirt,cacheDir=.classCache,cacheDirPerm=1000,readOnly \
			-XX:ShareClassesEnableBCI -Xscmx160m \
			-Xtune:virtualized"
elif [[ "$1" == "--graal" ]]; then
	EXTRA_OPTIONS="-XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI -XX:+UseJVMCICompiler"
elif [[ "$1" == "--native-tuned" ]]; then
	CMD=./rest-http-crud-quarkus-runner
	EXTRA_OPTIONS="-Xmn110m -Xms100m"
elif [[ "$1" == "--native" ]]; then
	CMD=./rest-http-crud-quarkus-runner
fi

date +"%H:%M:%S:%3N" && $CMD \
	$EXTRA_OPTIONS \
	-Xmx128m -Djava.net.preferIPv4Stack=true -cp /work/application -jar /work/application.jar
