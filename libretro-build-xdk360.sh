#!/bin/bash

BASE_DIR=$(pwd)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/xdk360
FORMAT=_xdk360
FORMAT_EXT=lib
MSVC_NAME=msvc-2010-360
RELEASE_LTCG=Release_LTCG
RELEASE=Release

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
      cp $RELEASE_LTCG/fb_alpha_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

source $BASE_DIR/libretro-build-common-xdk.sh

if [ $1 ]; then
   $1
else
   build_libretro_mednafen
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba
   build_libretro_vba_next
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_nx
   build_libretro_prboom
   #build_libretro_stella
   #build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_mame078
fi
