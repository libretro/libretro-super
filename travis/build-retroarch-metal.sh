#!/bin/bash

export LOGDATE=`date +%Y-%m-%d`
mkdir -p /tmp/log/${LOGDATE}
export BOT=.
export TMPDIR=/tmp
export TRAVIS=1
export EXIT_ON_ERROR=1

RECIPE=recipes/apple/retroarch-osx-x64

cd ~/libretro-super

rm -fr retroarch
mv ${TRAVIS_BUILD_DIR} retroarch

FORCE=YES SINGLE_CORE=retroarch METAL=1 ./libretro-buildbot-recipe.sh "${RECIPE}"
