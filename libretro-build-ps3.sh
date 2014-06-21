#!/bin/bash

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ps3
FORMAT=_ps3
FORMAT_COMPILER_TARGET=ps3
FORMAT_COMPILER_TARGET_ALT=sncps3
FORMAT_EXT=a
JOBS=7
MAKE=make

. ./libretro-build-common.sh

if [ $1 ]; then
   $1
else
   build_libretro_mednafen
   build_libretro_mednafen_ngp
   build_libretro_mednafen_pce_fast
   build_libretro_mednafen_vb
   build_libretro_mednafen_psx
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba_full
   build_libretro_vba_next
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_mame078
   build_libretro_handy
fi
