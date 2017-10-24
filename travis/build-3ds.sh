#!/bin/bash

RECIPE=recipes/nintendo/3ds

sudo mkdir -p /home/buildbot/tools

sudo chmod -R 777 /home/buildbot

cd /home/buildbot/tools

wget -O 3ds.tar.xz 'https://github.com/libretro/libretro-toolchains/blob/master/3ds.tar.xz?raw=true'

tar Jkxf 3ds.tar.xz

cd ~/libretro-super

# only build the one core specified in $CORE
egrep "^$CORE " ${RECIPE} | head -1 >${RECIPE}.new && mv ${RECIPE}.new ${RECIPE}

./libretro-buildbot-recipe.sh ${RECIPE}
