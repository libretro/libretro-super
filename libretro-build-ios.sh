#!/bin/sh

set -e

BASE_DIR="$PWD"
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ios
FORMAT=_ios
FORMAT_COMPILER_TARGET=ios
FORMAT_COMPILER_TARGET_ALT=ios
FORMAT_EXT=dylib
JOBS=7

export IOSSDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/

. ./libretro-build-common-console.sh

if [ $1 ]; then
   $1
else
   build_libretro_pcsx_rearmed
   build_libretro_mednafen
   build_libretro_mednafen_psx
   build_libretro_mednafen_gba
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba_full
   build_libretro_vba
   build_libretro_fceu
   build_libretro_gambatte
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_desmume
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_modelviewer
   build_libretro_scenewalker
fi
