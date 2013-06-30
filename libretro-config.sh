#!/bin/sh

if [ -f "libretro-config-user.sh" ]; then
# All your user defines (listed below) should go in this local file
. ./libretro-config-user.sh
fi

#User defines (should be defined in local libretro-config-user.sh file)

#if uncommented, will fetch repos with read+write access. Useful for committers
#export WRITERIGHTS

#if uncommented, will build libretro GL cores as well. Doesn't need to be defined for mobile platforms
#export BUILD_LIBRETRO_GL

#if uncommented, will build experimental cores as well which are not yet fit for release.
#export BUILD_EXPERIMENTAL
