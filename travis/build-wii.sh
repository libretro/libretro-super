#!/bin/bash

RECIPE=recipes/nintendo/wii

sudo mkdir -p /home/buildbot/tools

sudo chmod -R 777 /home/buildbot

cd /home/buildbot/tools

# wiiu tools work for wii also
wget -O wiiu.tar.xz 'https://github.com/libretro/libretro-toolchains/blob/master/wiiu.tar.xz?raw=true'

tar Jkxf wiiu.tar.xz

cd ~/libretro-super

if [ "${TRAVIS_BUILD_DIR}" ]; then
  CORE_DIRNAME=`grep ${CORE} ${RECIPE} | head -1 | awk '{print $2}'`
  mv ${TRAVIS_BUILD_DIR} ${CORE_DIRNAME}
fi

# only build the one core specified in $CORE
SINGLE_CORE=${CORE} ./libretro-buildbot-recipe.sh ${RECIPE}
