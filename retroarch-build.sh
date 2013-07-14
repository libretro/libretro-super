#!/bin/sh

. ./libretro-config.sh

if [ "$platform" ]; then
   if [ "$platform" = "win" ]; then
      FORMAT_EXT="dll"
      FORMAT_COMPILER_TARGET=win
      FORMAT_COMPILER_TARGET_ALT=win
      DIST_DIR=win
   elif [ "$platform" = "osx" ]; then
      FORMAT_EXT="dylib"
      FORMAT_COMPILER_TARGET=osx
      FORMAT_COMPILER_TARGET_ALT=osx
      DIST_DIR=osx
   else
      FORMAT_EXT="so"
      FORMAT_COMPILER_TARGET=unix
      FORMAT_COMPILER_TARGET_ALT=unix
      DIST_DIR=unix
   fi
else
   UNAME=$(uname)

   if [ $(echo $UNAME | grep Linux) ]; then
      FORMAT_EXT="so"
      FORMAT_COMPILER_TARGET=unix
      FORMAT_COMPILER_TARGET_ALT=unix
      DIST_DIR=unix
   elif [ $(echo $UNAME | grep BSD) ]; then
      FORMAT_EXT="so"
      FORMAT_COMPILER_TARGET=unix
      FORMAT_COMPILER_TARGET_ALT=unix
      DIST_DIR=bsd
   elif [ $(echo $UNAME | grep Darwin) ]; then
      FORMAT_EXT="dylib"
      FORMAT_COMPILER_TARGET=osx
      FORMAT_COMPILER_TARGET_ALT=osx
      DIST_DIR=osx
   elif [ $(echo $UNAME | grep -i MINGW) ]; then
      FORMAT_EXT="dll"
      FORMAT_COMPILER_TARGET=win
      FORMAT_COMPILER_TARGET_ALT=win
      DIST_DIR=win
   else
      # assume this is UNIX-based at least
      FORMAT_EXT="so"
      FORMAT_COMPILER_TARGET=unix
      FORMAT_COMPILER_TARGET_ALT=unix
      DIST_DIR=unix
   fi
fi

# BSDs don't have readlink -f
read_link()
{
   TARGET_FILE="$1"
   cd $(dirname "$TARGET_FILE")
   TARGET_FILE=$(basename "$TARGET_FILE")

   while [ -L "$TARGET_FILE" ]
   do
      TARGET_FILE=$(readlink "$TARGET_FILE")
      cd $(dirname "$TARGET_FILE")
      TARGET_FILE=$(basename "$TARGET_FILE")
   done

   PHYS_DIR=$(pwd -P)
   RESULT="$PHYS_DIR/$TARGET_FILE"
   echo $RESULT
}

SCRIPT=$(read_link "$0")
echo "Script: $SCRIPT"
BASE_DIR=$(dirname "$SCRIPT")
if [ -z "$RARCH_DIST_DIR" ]; then
   RARCH_DIR="$BASE_DIR/dist"
   RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi

if [ -z "$JOBS" ]; then
   JOBS=4
fi

die()
{
   echo $1
   #exit 1
}

ARCH=$(uname -m)
X86=false
X86_64=false
ARM=false
ARMV5=false
ARMV6=false
ARMV7=false
if [ $ARCH = x86_64 ]; then
   echo "x86_64 CPU detected"
   X86=true
   X86_64=true
elif [ $ARCH = i686 ]; then
   echo "x86_32 CPU detected"
   X86=true
elif [ $ARCH = armv5tel ]; then
   echo "ARMv5 CPU detected"
   ARM=true
   ARMV5=true
   export FORMAT_COMPILER_TARGET=armv
   export FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET
   export RARCHCFLAGS="${RARCHCFLAGS} -marm"
elif [ $ARCH = armv6l ]; then
   echo "ARMv6 CPU detected"
   ARM=true
   ARMV6=true
   export FORMAT_COMPILER_TARGET=armv
   export FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET
   export RARCHCFLAGS="${RARCHCFLAGS} -marm"
elif [ $ARCH = armv7l ]; then
   echo "ARMv7 CPU detected"
   ARM=true
   ARMV7=true
   export FORMAT_COMPILER_TARGET=armv
   export FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET
   export RARCHCFLAGS="${RARCHCFLAGS} -marm"
fi

if [ "$HOST_CC" ]; then
   CC="${HOST_CC}-gcc"
   CXX="${HOST_CC}-g++"
   STRIP="${HOST_CC}-strip"
fi

if [ -z "$MAKE" ]; then
   if [ "$(expr substr $(uname -s) 1 7)" = "MINGW32" ]; then
      MAKE=mingw32-make
   else
      MAKE=make
   fi
fi

if [ -z "$CC" ]; then
	if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
		CC=clang
   elif [ "$(expr substr $(uname -s) 1 7)" = "MINGW32" ]; then
      CC=mingw32-gcc
   else
      CC=gcc
   fi
fi

if [ -z "$CXX" ]; then
	if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
		CXX=clang++
   elif [ "$(expr substr $(uname -s) 1 7)" = "MINGW32" ]; then
      CXX=mingw32-g++
   else
      CXX=g++
   fi
fi

echo "CC = $CC"
echo "CXX = $CXX"
echo "STRIP = $STRIP"

mkdir -p "$RARCH_DIST_DIR"

export RARCHCFLAGS=""

check_deps()
{
   if [ $ENABLE_GLES ]; then
      echo "=== Enabling OpenGL ES ==="
      export ENABLE_GLES="--enable-gles"
   fi
   if [ $ARM_NEON ]; then
      echo "=== Enabling ARM NEON support ==="
      export ENABLE_NEON="--enable-neon"
   fi

   if [ $ARM_HARDFLOAT ]; then
      echo "=== Enabling ARM Hard float ABI support ==="
      export RARCHCFLAGS="${RARCHCFLAGS} -mfloat-abi=hard"
   fi
   if [ $ARM_SOFTFLOAT ]; then
      echo "=== Enabling ARM Soft float ABI support ==="
      export RARCHCFLAGS="${RARCHCFLAGS} -mfloat-abi=softfp"
   fi
   if [ "$CORTEX_A8" ]; then
      echo "=== Enabling Cortex A8 CFLAGS ==="
      export RARCHCFLAGS="${RARCHCFLAGS} -mcpu=cortex-a8 -mtune=cortex-a8"
   fi
   if [ "$CORTEX_A9" ]; then
      echo "=== Enabling Cortex A9 CFLAGS ==="
      export RARCHCFLAGS="${RARCHCFLAGS} -mcpu=cortex-a9 -mtune=cortex-a9"
   fi

   if [ $ARM_NEON ]; then
      echo "=== Enabling ARM NEON support (CFLAGS) ==="
      export RARCHCFLAGS=="-mfpu=neon"
   fi
}

build_retroarch()
{
   cd "$BASE_DIR"
   pwd
   if [ -d "retroarch" ]; then
      echo "=== Building RetroArch ==="
      cd retroarch
      check_deps
      ./configure $ENABLE_GLES $ENABLE_NEON
      ${MAKE} -f Makefile platform=${FORMAT_COMPILER_TARGET} CC="gcc ${RARCHCFLAGS}" $COMPILER -j$JOBS clean || die "Failed to clean RetroArch"
      ${MAKE} -f Makefile platform=${FORMAT_COMPILER_TARGET} CC="gcc ${RARCHCFLAGS}" $COMPILER -j$JOBS || die "Failed to build RetroArch"
   else
      echo "RetroArch not fetched, skipping ..."
   fi
}

if [ $1 ]; then
   $1
else
   build_retroarch
fi
