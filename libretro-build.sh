#!/bin/sh

. ./libretro-config.sh

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

. ./libretro-build-common.sh

mkdir -p "$RARCH_DIST_DIR"

if [ $1 ]; then
   $1
else
if [ -z $BUILD_LIBRETRO_GL ]; then
   build_libretro_modelviewer
   build_libretro_scenewalker
   build_libretro_instancingviewer
if [ -z $BUILD_EXPERIMENTAL ]; then
   build_libretro_mupen64
   build_libretro_ffmpeg
fi
fi
   build_libretro_bsnes
   build_libretro_mednafen
   build_libretro_mednafen_gba
   build_libretro_mednafen_snes
   build_libretro_mednafen_psx
   build_libretro_s9x
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba_full
   build_libretro_vba
   build_libretro_bnes
   build_libretro_fceu
   build_libretro_gambatte
   build_libretro_meteor
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_mame078
   build_libretro_dosbox
   build_libretro_scummvm
   build_libretro_picodrive
if [ $FORMAT_COMPILER_TARGET != "win" ]; then
   build_libretro_desmume
   build_libretro_pcsx_rearmed
fi
fi
