#!/bin/bash

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/psp1
FORMAT=_psp1
FORMAT_COMPILER_TARGET=psp1
FORMAT_COMPILER_TARGET_ALT=psp1
FORMAT_EXT=a
JOBS=7
MAKE=make

. ./libretro-build-common.sh

if [ $1 ]; then
   $1
else
   build_libretro_2048
   build_libretro_bluemsx
   build_libretro_fmsx
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_bsnes
   build_libretro_mednafen
   build_libretro_s9x_next
   build_libretro_genplus
   #build_libretro_fba_full
   build_libretro_fba_cps2
   build_libretro_vba_next
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   #build_libretro_mame078
   build_libretro_picodrive
   build_libretro_handy
   build_libretro_vecx
fi
