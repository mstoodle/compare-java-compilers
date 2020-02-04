#!/bin/bash

JDK_HOME=$PWD/../../jdk
if [ "$1" == "--download" ] || [ ! -d $JDK_HOME ]; then
	pushd ..
	./download.sh
	popd
fi

# kill any errant servers sometimes left behind if one stops this script mid-way
# all containers have "rest-crud-quarkus" in their name (see ROOTNAME below)
echo Killing any errant servers left around, always prints a \"No such process\" error
ps -efal |awk '/rest-crud-quarkus/{print $4;}' | xargs kill -9

./run-docker-db.sh

OPENJ9=openj9
HOTSPOT=hotspot
GRAAL=graalvm-ce

JDK8_DIR=jdk8u242-b08/jre
JDK11_DIR=jdk-11.0.6+10
GRAAL11_DIR=graalvm-ce-19.2.1

# jitserver jdk8 and jdk11
JITSERVER_HOST=`hostname`
JITSERVER_PORT=38400

sudo docker build -f Dockerfile-jdk8-jitserver -t jitserver-jdk8 \
	--build-arg SERVER="$JITSERVER_HOST" --build-arg PORT="$JITSERVER_PORT" .
sudo docker build -f Dockerfile-jdk11-jitserver -t jitserver-jdk11 \
	--build-arg SERVER="$JITSERVER_HOST" --build-arg PORT="$JITSERVER_PORT" .

# Compile Convert.java
export JAVA_HOME=$JDK_HOME/$HOTSPOT/$JDK8_DIR
$JAVA_HOME/bin/javac Convert.java

# force this name to consistently be in every server container name
ROOTNAME=rest-crud-quarkus

# jdk8 Native
export JAVA_HOME=$JDK_HOME/$GRAAL/$GRAAL11_DIR
mvn clean package
sudo docker build -f Dockerfile-jdk8-native -t ${ROOTNAME}-jdk8-native .

# jdk8 Native tuned
export JAVA_HOME=$JDK_HOME/$GRAAL/$GRAAL11_DIR
sudo docker build -f Dockerfile-jdk8-native-tuned -t ${ROOTNAME}-jdk8-native-tuned .

# jdk8
export JAVA_HOME=$JDK_HOME/$HOTSPOT/$JDK8_DIR
mvn clean package -Dno-native

# jdk8 HS
sudo docker build -f Dockerfile-jdk8-hs -t ${ROOTNAME}-jdk8-hs .

# jdk8 OpenJ9
sudo docker build -f Dockerfile-jdk8-j9 -t ${ROOTNAME}-jdk8-j9 .

# jdk8 OpenJ9 with jitserver
sudo docker build -f Dockerfile-jdk8-j9-jitserver -t ${ROOTNAME}-jdk8-j9-jitserver \
	--build-arg SERVER="$JITSERVER_HOST" --build-arg PORT="$JITSERVER_PORT" .

# jdk8 OpenJ9 shared cache
export JAVA_HOME=$JDK_HOME/$OPENJ9/$JDK8_DIR
$JAVA_HOME/bin/java -Xshareclasses:name=sc,destroy
echo "Starting server to populate shared classes cache"
numactl --physcpubind=1 $JAVA_HOME/bin/java \
	-Xshareclasses:name=sc,cacheDir=classCache,cacheDirPerm=1000 -XX:ShareClassesEnableBCI \
	-Xscmx80m \
	-Xmx128m -Djava.net.preferIPv4Stack=true \
	-jar target/rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.jar 2>&1 > /dev/null &
PID=$!
sleep 15
echo "    Done!"
kill -9 $PID
sudo docker build -f Dockerfile-jdk8-j9-sc -t ${ROOTNAME}-jdk8-j9-sc \
	--build-arg CLASS_CACHE=classCache/C290M4F1A64P_sc_G41L00 .

# jdk8 OpenJ9 shared cache with jitserver relies on cache just built
sudo docker build -f Dockerfile-jdk8-j9-sc-jitserver -t ${ROOTNAME}-jdk8-j9-sc-jitserver \
	--build-arg CLASS_CACHE=classCache/C290M4F1A64P_sc_G41L00 .

# jdk8 OpenJ9 shared cache virtualized
export JAVA_HOME=$JDK_HOME/$OPENJ9/$JDK8_DIR
$JAVA_HOME/bin/java -Xshareclasses:name=scvirt,destroy
echo "Starting server to populate shared classes cache"
numactl --physcpubind=1 $JAVA_HOME/bin/java \
	-Xshareclasses:name=scvirt,cacheDir=classCache,cacheDirPerm=1000 \
	-XX:ShareClassesEnableBCI -Xscmx160m \
	-Xtune:virtualized \
	-Xmx128m -Djava.net.preferIPv4Stack=true \
	-jar target/rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.jar 2>&1 > /dev/null &
PID=$!
sleep 15
echo "Applying load to populate shared classes cache"
./run-load.sh
echo "    Done!"
kill -9 $PID
sudo docker build -f Dockerfile-jdk8-j9-scvirt -t ${ROOTNAME}-jdk8-j9-scvirt \
	--build-arg CLASS_CACHE=classCache/C290M4F1A64P_scvirt_G41L00 .


# jdk11 HS
sudo docker build -f Dockerfile-jdk11-hs -t ${ROOTNAME}-jdk11-hs .

# jdk11 HS jaotc
export JAVA_HOME=$JDK_HOME/$HOTSPOT/$JDK11_DIR/

# generate list of methods to compile
./prep-for-jaotc.sh

# AOT compile those methods
cd target
$JAVA_HOME/bin/jaotc --output rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.so \
	--compile-commands ../compile.aotcfg --module java.base --info
cd ..
sudo docker build -f Dockerfile-jdk11-hs-jaotc -t ${ROOTNAME}-jdk11-hs-jaotc \
	--build-arg AOTLIB="rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.so" .

# jdk11 HS jaotc tiered
export JAVA_HOME=$JDK_HOME/$HOTSPOT/$JDK11_DIR/
cd target
$JAVA_HOME/bin/jaotc --output rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner-tiered.so \
	--compile-for-tiered --compile-commands ../compile.aotcfg --module java.base --info
cd ..
sudo docker build -f Dockerfile-jdk11-hs-jaotc -t ${ROOTNAME}-jdk11-hs-jaotc-tier \
	--build-arg AOTLIB="rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner-tiered.so" .

# jdk11 Graal
sudo docker build -f Dockerfile-jdk11-graal -t ${ROOTNAME}-jdk11-graal .

# jdk11 OpenJ9
sudo docker build -f Dockerfile-jdk11-j9 -t ${ROOTNAME}-jdk11-j9 .

# jdk11 OpenJ9 with jitserver
sudo docker build -f Dockerfile-jdk11-j9-jitserver -t ${ROOTNAME}-jdk11-j9-jitserver \
	--build-arg SERVER="$JITSERVER_HOST" --build-arg PORT="$JITSERVER_PORT" .

# jdk11 OpenJ9 shared cache
export JAVA_HOME=$JDK_HOME/$OPENJ9/$JDK11_DIR/
$JAVA_HOME/bin/java -Xshareclasses:name=sc,destroy
echo "Starting server to populate shared classes cache"
numactl --physcpubind=1 $JAVA_HOME/bin/java \
	-Xshareclasses:name=sc,cacheDir=classCache,cacheDirPerm=1000 -XX:ShareClassesEnableBCI \
	-Xscmx80m \
	-Xmx128m -Djava.net.preferIPv4Stack=true \
	-jar target/rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.jar 2>&1 > /dev/null &
PID=$!
sleep 15
echo "    Done!"
kill -9 $PID
sudo docker build -f Dockerfile-jdk11-j9-sc -t ${ROOTNAME}-jdk11-j9-sc \
	--build-arg CLASS_CACHE=classCache/C290M11F1A64P_sc_G41L00 .

# jdk11 OpenJ9 shared cache with jitserver relies on cache just built
sudo docker build -f Dockerfile-jdk11-j9-sc-jitserver -t ${ROOTNAME}-jdk11-j9-sc-jitserver \
	--build-arg CLASS_CACHE=classCache/C290M11F1A64P_sc_G41L00 .

# jdk11 OpenJ9 shared cache virtualized
export JAVA_HOME=$JDK_HOME/$OPENJ9/$JDK11_DIR/
$JAVA_HOME/bin/java -Xshareclasses:name=scvirt,destroy
echo "Starting server to populate shared classes cache"
numactl --physcpubind=1 $JAVA_HOME/bin/java \
	-Xshareclasses:name=scvirt,cacheDir=classCache,cacheDirPerm=1000 \
	-XX:ShareClassesEnableBCI -Xscmx160m \
	-Xtune:virtualized \
	-Xmx128m -Djava.net.preferIPv4Stack=true \
	-jar target/rest-http-crud-quarkus-1.0.0.Alpha1-SNAPSHOT-runner.jar 2>&1 > /dev/null &
PID=$!
sleep 15
echo "Applying load to populate shared classes cache"
./run-load.sh
echo "    Done!"
kill -9 $PID
sudo docker build -f Dockerfile-jdk11-j9-scvirt -t ${ROOTNAME}-jdk11-j9-scvirt \
	--build-arg CLASS_CACHE=classCache/C290M11F1A64P_scvirt_G41L00 .
