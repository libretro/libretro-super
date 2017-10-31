#!/bin/bash

RECIPE=recipes/apple/cores-osx-x64-generic

cd ~/libretro-super

# only build the one core specified in $CORE
SINGLE_CORE=${CORE} ./libretro-buildbot-recipe.sh ${RECIPE}
