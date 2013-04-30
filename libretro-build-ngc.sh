#!/bin/sh

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ngc
FORMAT=_ngc
FORMAT_COMPILER_TARGET=ngc
FORMAT_COMPILER_TARGET_ALT=ngc
FORMAT_EXT=a
JOBS=7
MY_DIR=$(dirname $(readlink -f $0))

. $MY_DIR/libretro-build-common-gx.sh
. $MY_DIR/libretro-build-common-console.sh

build_libretro_mednafen
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_fceu
build_libretro_gambatte
build_libretro_nx
build_libretro_prboom
build_libretro_nestopia
build_libretro_tyrquake
