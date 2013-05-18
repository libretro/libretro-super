#!/bin/sh

BASE_DIR=$(pwd)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/xdk360
FORMAT=_xdk360
FORMAT_EXT=lib
MSVC_NAME=msvc-2010-360

die()
{
   echo $1
   #exit 1
}

build_libretro_fba()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd projectfiles/visualstudio-2010-libretro-360
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/fb_alpha_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

source $BASE_DIR/libretro-build-common-xdk.sh

if [ $1 ]; then
   $1
else
   build_libretro_mednafen
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba
   build_libretro_vba
   build_libretro_fceu
   build_libretro_gambatte
   build_libretro_prboom
   build_libretro_nestopia
   build_libretro_tyrquake
fi
