#!/bin/bash

RECIPE=recipes/linux/cores-linux-x64-generic

cd ~/libretro-super

# only build the one core specified in $CORE
egrep "^$CORE " ${RECIPE} | head -1 >${RECIPE}.new && mv ${RECIPE}.new ${RECIPE}

./libretro-buildbot-recipe.sh ${RECIPE}
