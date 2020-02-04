#!/bin/bash
#-XX:-StackTraceInThrowable -Xverify:none
#-Dquarkus.http.host=192.168.90.176

JDK_HOME=$PWD/../../jdk/
HOTSPOT=hotspot
JDK11_DIR=jdk-11.0.6+10
export JAVA_HOME=$JDK_HOME/$HOTSPOT/$JDK11_DIR

echo Starting server
numactl --physcpubind=0-7 $JAVA_HOME/bin/java \
	-XX:+UnlockDiagnosticVMOptions -XX:+LogTouchedMethods -XX:+PrintTouchedMethodsAtExit \
	-Xmx128m -Djava.net.preferIPv4Stack=true -cp target/lib \
	-jar target/rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.jar \
	2>&1 >compile.alloutput &
PID=$!

echo Waiting 15s for server to start
sleep 15

# output doesn't matter
echo Running load
./run-load.sh > /dev/null

echo Killing server
kill -SIGTERM $PID > /dev/null

# clean up needed in compiled_methods so only list of compiled methods
awk -v STR="compileOnly " \
	"BEGIN                             { m=0; } \
	/# Method::print_touched_methods/  { m=1; next; } \
	//                                 { if (m) print STR \$0; }" compile.alloutput | \
	$JAVA_HOME/bin/java Convert > compile.aotcfg
