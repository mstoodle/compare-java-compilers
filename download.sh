#!/bin/sh

echo "Pulling docker images"
sudo docker pull adoptopenjdk:8-jdk-hotspot
sudo docker pull adoptopenjdk:8u242-b08-jdk-openj9-0.18.1
sudo docker pull adoptopenjdk:11-jdk-hotspot
sudo docker pull adoptopenjdk:11.0.6_10-jdk-openj9-0.18.1

echo "Downloading and expanding JDKs and graalvm-ce"
mkdir -p jdk
cd jdk
 mkdir -p hotspot
 cd hotspot

  wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u242b08.tar.gz
  tar zxvf OpenJDK8U-jdk_x64_linux_hotspot_8u242b08.tar.gz

  wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz
  tar zxvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz

  cd ..
 mkdir -p openj9
  cd openj9

  wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08_openj9-0.18.1/OpenJDK8U-jdk_x64_linux_openj9_8u242b08_openj9-0.18.1.tar.gz
  tar zxvf OpenJDK8U-jdk_x64_linux_openj9_8u242b08_openj9-0.18.1.tar.gz

  wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10_openj9-0.18.1/OpenJDK11U-jdk_x64_linux_openj9_11.0.6_10_openj9-0.18.1.tar.gz
  tar zxvf OpenJDK11U-jdk_x64_linux_openj9_11.0.6_10_openj9-0.18.1.tar.gz

  cd ..

 mkdir -p graalvm-ce
 cd graalvm-ce

  wget https://github.com/oracle/graal/releases/download/vm-19.2.1/graalvm-ce-linux-amd64-19.2.1.tar.gz
  tar zxvf graalvm-ce-linux-amd64-19.2.1.tar.gz
  cd graalvm-ce-19.2.1
   bin/gu install native-image
  cd ..

 cd ..
