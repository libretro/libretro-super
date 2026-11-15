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
ln -s `pwd`/retroarch ${TRAVIS_BUILD_DIR}

# only build the one core specified in $SINGLE_CORE, use NOCLEAN so we don't reset the repo back to master/HEAD in case this is a PR
NOCLEAN=1 FORCE=YES SINGLE_CORE=retroarch METAL=1 METAL_QT=1 EXIT_ON_ERROR=1 ./libretro-buildbot-recipe.sh "${RECIPE}"
