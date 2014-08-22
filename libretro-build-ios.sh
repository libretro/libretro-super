#!/bin/bash

set -e

BASE_DIR="$PWD"
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ios
FORMAT=_ios
FORMAT_COMPILER_TARGET=ios
FORMAT_COMPILER_TARGET_ALT=ios
FORMAT_EXT=dylib
JOBS=7
MAKE=make
CXX11="clang++ -std=c++11 -stdlib=libc++ -miphoneos-version-min=5.0"
IOS=1

IOSSDK=$(xcrun -sdk iphoneos -show-sdk-path)
IOSVER_MAJOR=$(xcrun -sdk iphoneos -show-sdk-platform-version | cut -c '1')
IOSVER_MINOR=$(xcrun -sdk iphoneos -show-sdk-platform-version | cut -c '3')
IOSVER=${IOSVER_MAJOR}${IOSVER_MINOR}
echo "iOS path: ${IOSSDK}"
echo "iOS version: ${IOSVER}"
export IOSSDK

. ./libretro-build-common.sh

if [ $1 ]; then
   $1
else
   build_libretro_2048
   build_libretro_bluemsx
   build_libretro_fmsx
   build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_psx
   #build_libretro_beetle_bsnes
   build_libretro_snes9x
   build_libretro_snes9x_next
   build_libretro_genesis_plus_gx
   build_libretro_fba_full
   build_libretro_vbam
   build_libretro_vba_next
   build_libretro_fceumm
   build_libretro_gambatte
   #build_libretro_meteor
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_mame078
   build_libretro_mame
   #build_libretro_dosbox
   build_libretro_scummvm
   build_libretro_picodrive
   build_libretro_handy
   build_libretro_desmume
   build_libretro_pcsx_rearmed
   build_libretro_pcsx_rearmed_interpreter
   build_libretro_mupen64
   build_libretro_yabause
   #build_libretro_ffmpeg
   build_libretro_3dengine
   build_libretro_vecx
   build_libretro_tgbdual
   build_libretro_prosystem
   build_libretro_dinothawr
   build_libretro_virtualjaguar
   build_libretro_o2em
fi
