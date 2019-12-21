#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

EXECUTABLE=${PWD##*/}
echo "Testing $EXECUTABLE output"

./target/${EXECUTABLE} > target/native-image/test-output.txt 2>&1 &
PID=$!
sleep 3

TOTALINFO=`cat target/native-image/output.txt | grep "\[total\]"`
BUILDTIME=`echo $TOTALINFO | sed 's/^.*\[total\]: \(.*\) ms.*$/\1/' | tr -d -c 0-9\.`
BUILDMEMORY=`echo $TOTALINFO | sed 's/^.*\[total\]: .* ms,\(.*\) GB$/\1/' | tr -d -c 0-9\.`
echo "Image build time: ${BUILDTIME}ms"
RSS=`ps -o rss ${PID} | tail -n1`
RSS=`bc <<< "scale=1; ${RSS}/1024"`
echo "RSS memory: ${RSS}M"
SIZE=`wc -c <"./target/${EXECUTABLE}"`/1024
SIZE=`bc <<< "scale=1; ${SIZE}/1024"`
echo "Image size: ${SIZE}M"
STARTUP=`cat target/native-image/test-output.txt | grep "JVM running for"`
REGEXP="Started .* in ([0-9\.]*) seconds \(JVM running for ([0-9\.]*)\).*$"
if [[ ${STARTUP} =~ ${REGEXP} ]]; then
  STIME=${BASH_REMATCH[1]}
  JTIME=${BASH_REMATCH[2]}
  echo "Startup time: ${STIME} (JVM running for ${JTIME})"
fi

if [[ `cat target/native-image/test-output.txt | grep "jafu running!"` ]]
then
  printf "${GREEN}SUCCESS${NC}\n"
  echo `date +%Y%m%d-%H%M`,$EXECUTABLE,$BUILDTIME,$BUILDMEMORY,${RSS},${SIZE},${STIME},${JTIME}  > target/native-image/summary.csv
  kill ${PID}
  exit 0
else
  printf "${RED}FAILURE${NC}: the output of the application does not contain the expected output\n"
  echo `date +%Y%m%d-%H%M`,$EXECUTABLE,ERROR > target/native-image/summary.csv
  kill ${PID}
  exit 1
fi
