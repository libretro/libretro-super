#!/bin/bash

RECIPE=recipes/apple/cores-osx-x64-generic

cd ~/libretro-super

if [ "${TRAVIS_BUILD_DIR}" ]; then
  CORE_DIRNAME=`grep ${CORE} ${RECIPE} | head -1 | awk '{print $2}'`
  rm -fr ${CORE_DIRNAME}
  mv ${TRAVIS_BUILD_DIR} ${CORE_DIRNAME}
fi

# only build the one core specified in $CORE
SINGLE_CORE=${CORE} ./libretro-buildbot-recipe.sh ${RECIPE}
