#!/bin/bash

export LOGDATE=`date +%Y-%m-%d`
mkdir -p /tmp/log/${LOGDATE}
export BOT=.
export TMPDIR=/tmp
export TRAVIS=1
export EXIT_ON_ERROR=1

./build-${PLATFORM}.sh
