#!/bin/bash

export LOGDATE=`date +%Y-%m-%d`
mkdir -p /tmp/log/${LOGDATE}
export BOT=.
export TMPDIR=/tmp
export TRAVIS=1
export EXIT_ON_ERROR=1

# taken from https://stackoverflow.com/questions/26082444/how-to-work-around-travis-cis-4mb-output-limit
export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
  echo Tailing the last 500 lines of output:
  tail -500 $BUILD_OUTPUT
}

# Set up a repeating loop to send some output to Travis.

bash -c "while true; do echo \$(date) - building ...; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

./build-${PLATFORM}.sh &>$BUILD_OUTPUT

RET=$?

dump_output

exit $RET
