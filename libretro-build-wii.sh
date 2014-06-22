#!/bin/bash

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/wii
FORMAT=_wii
FORMAT_COMPILER_TARGET=wii
FORMAT_COMPILER_TARGET_ALT=wii
FORMAT_EXT=a
JOBS=7
MAKE=make

. ./libretro-build-common-gx.sh
. ./libretro-build-common.sh

if [ $1 ]; then
   $1
else
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_psx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_bsnes
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba
   build_libretro_vba_next
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_nx
   build_libretro_prboom
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
fi
