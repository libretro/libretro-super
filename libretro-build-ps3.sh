#!/bin/sh

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ps3
FORMAT=_ps3
FORMAT_COMPILER_TARGET=ps3
FORMAT_COMPILER_TARGET_ALT=sncps3
JOBS=7
MY_DIR=$(dirname $(readlink -f $0))

. $MY_DIR/libretro-build-common-console.sh

build_libretro_fba()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba/
      cd svn-current/trunk
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha"
      cp fb_alpha_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

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
