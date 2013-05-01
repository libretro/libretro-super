#!/bin/sh

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/qnx
FORMAT=_qnx
FORMAT_COMPILER_TARGET=qnx
FORMAT_COMPILER_TARGET_ALT=qnx
FORMAT_EXT=so
JOBS=7

. ./libretro-build-common-console.sh

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
#build_libretro_stella
#build_libretro_desmume
build_libretro_nestopia
build_libretro_tyrquake
