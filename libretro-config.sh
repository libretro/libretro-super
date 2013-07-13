#!/bin/sh

#USER DEFINES
#------------
#These options should be defined inside your own
#local libretro-config-user.sh file rather than here.
#The following below is just a sample.

if [ -f "libretro-config-user.sh" ]; then
. ./libretro-config-user.sh
fi

#if uncommented, will fetch repos with read+write access. Useful for committers
#export WRITERIGHTS

#if uncommented, will build libretro GL cores as well. Doesn't need to be defined for mobile platforms
#export BUILD_LIBRETRO_GL

#if uncommented, will build experimental cores as well which are not yet fit for release.
#export BUILD_EXPERIMENTAL

#ARM DEFINES
#-----------

#if uncommented, will build cores with Cortex A8 compiler optimizations
#export CORTEX_A8

#if uncommented, will build cores with Cortex A9 compiler optimizations
#export CORTEX_A9

#if uncommented, will build cores with ARM hardfloat ABI
#export ARM_HARDFLOAT

#if uncommented, will build cores with ARM softfloat ABI
#export ARM_SOFTFLOAT

#if uncommented, will build cores with ARM NEON support (ARMv7+ only)
#export ARM_NEON
