#!/bin/bash

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
   JOBS=7
fi

die()
{
   echo $1
   #exit 1
}

if [ "$HOST_CC" ]; then
   CC="${HOST_CC}-gcc"
   CXX="${HOST_CC}-g++"
   CXX11="${HOST_CC}-g++"
   STRIP="${HOST_CC}-strip"
fi

if [ -z "$MAKE" ]; then
   if uname -s | grep -i MINGW32 > /dev/null 2>&1; then
      MAKE=mingw32-make
   else
      if type gmake > /dev/null 2>&1; then
         MAKE=gmake
      else
         MAKE=make
      fi
   fi
fi


if [ -z "$CC" ]; then
   if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
      CC=cc
   elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
      CC=mingw32-gcc
   else
      CC=gcc
   fi
fi

if [ -z "$CXX" ]; then
   if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
      CXX=c++
      CXX11="clang++ -std=c++11 -stdlib=libc++"
   elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
      CXX=mingw32-g++
      CXX11=mingw32-g++
   else
      CXX=g++
      CXX11=g++
   fi
fi

FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET
echo "CC = $CC"
echo "CXX = $CXX"
echo "STRIP = $STRIP"

. ./libretro-build-common.sh

mkdir -p "$RARCH_DIST_DIR"

if [ $1 ]; then
   $1
else
   build_libretro_2048
   build_libretro_bluemsx
   build_libretro_fmsx
   build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   build_libretro_bsnes_mercury
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_psx
   build_libretro_beetle_snes
   build_libretro_snes9x
   build_libretro_snes9x_next
   build_libretro_genesis_plus_gx
   build_libretro_fb_alpha
   build_libretro_vbam
   build_libretro_vba_next
   build_libretro_bnes
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_meteor
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_mame078
   build_libretro_mame
   build_libretro_dosbox
   build_libretro_scummvm
   build_libretro_picodrive
   build_libretro_handy
   build_libretro_desmume
   if [ $FORMAT_COMPILER_TARGET != "win" ]; then
      build_libretro_pcsx_rearmed
   fi
   build_libretro_yabause
   build_libretro_vecx
   build_libretro_tgbdual
   build_libretro_prosystem
   build_libretro_dinothawr
   build_libretro_virtualjaguar
   build_libretro_mupen64
   build_libretro_ffmpeg
   build_libretro_3dengine
   build_libretro_ppsspp
   build_libretro_o2em
fi
