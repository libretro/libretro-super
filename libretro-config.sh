#!/bin/sh

# Architecture Assignment
ARCH="$(uname -m)"
case "$ARCH" in
   x86_64) X86=true && X86_64=true;;
   i686)   X86=true;;
   armv*)
      ARM=true && export FORMAT_COMPILER_TARGET=armv
      export RARCHCFLAGS="${RARCHCFLAGS} -marm"
      case "$ARCH" in
         armv5tel) ARMV5=true;;
         armv6l)   ARMV6=true;;
         armv7l)   ARMV7=true;;
      esac;;
esac
echo "$ARCH CPU detected"

# Platform Assignment
[ -z "$platform" ] && platform="$(uname)"
case "$platform" in
   *BSD*)
      FORMAT_EXT='so'
      FORMAT_COMPILER_TARGET=unix
      DIST_DIR=bsd;;
   osx|*Darwin*)
      FORMAT_EXT='dylib'
      FORMAT_COMPILER_TARGET=osx
      DIST_DIR=osx;;
   win|*mingw*|*MINGW*)
      FORMAT_EXT='dll'
      FORMAT_COMPILER_TARGET=win
      DIST_DIR=win;;
   *)
      FORMAT_EXT='so'
      FORMAT_COMPILER_TARGET=unix
      DIST_DIR=unix;;
esac

export FORMAT_COMPILER_TARGET_ALT="$FORMAT_COMPILER_TARGET"

#USER DEFINES
#------------
#These options should be defined inside your own
#local libretro-config-user.sh file rather than here.
#The following below is just a sample.

if [ -f "libretro-config-user.sh" ]; then
. ./libretro-config-user.sh
else
# Sane defaults
export BUILD_LIBRETRO_GL=1
fi

#if uncommented, will fetch repos with read+write access. Useful for committers
#export WRITERIGHTS=1


#if uncommented, will build experimental cores as well which are not yet fit for release.
#export BUILD_EXPERIMENTAL=1

#ARM DEFINES
#-----------
#if uncommented, will build cores with Cortex A8 compiler optimizations
#export CORTEX_A8=1

#if uncommented, will build cores with Cortex A9 compiler optimizations
#export CORTEX_A9=1

#if uncommented, will build cores with ARM hardfloat ABI
#export ARM_HARDFLOAT=1

#if uncommented, will build cores with ARM softfloat ABI
#export ARM_SOFTFLOAT=1

#if uncommented, will build cores with ARM NEON support (ARMv7+ only)
#export ARM_NEON=1

#OPENGL DEFINES
#--------------

#if uncommented, will build libretro GL cores. Ignored for mobile platforms - GL cores will always be built there.
#export BUILD_LIBRETRO_GL=1

#if uncommented, will build cores with OpenGL ES 2 support. Not needed
#for platform-specific cores - only for generic core builds (ie. libretro-build.sh)
#export ENABLE_GLES=1
