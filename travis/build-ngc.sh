#!/bin/bash

RECIPE=recipes/nintendo/gamecube

sudo mkdir -p /home/buildbot/tools

sudo chmod -R 777 /home/buildbot

cd /home/buildbot/tools

# wiiu tools work for ngc also
wget -O wiiu.tar.xz 'https://github.com/libretro/libretro-toolchains/blob/master/wiiu.tar.xz?raw=true'

tar Jkxf wiiu.tar.xz

cd ~/libretro-super

# only build the one core specified in $CORE
egrep "^$CORE " ${RECIPE} | head -1 >${RECIPE}.new && mv ${RECIPE}.new ${RECIPE}

./libretro-buildbot-recipe.sh ${RECIPE}
