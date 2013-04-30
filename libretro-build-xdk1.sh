#!/bin/sh

CORES_DIR=C:/local-repos
BASE_DIR=$CORES_DIR/libretro-super
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/xdk1
FORMAT=_xdk
LIB_EXT=lib
MSVC_NAME=msvc-2003-xbox1

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
      cd projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/fb_alpha_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR

      echo "=== Building Final Burn Alpha Cores (CPS1) ==="
      cd ../../fbacores/cps1/projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/fb_alpha_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR/fba_cores_cps1_libretro$FORMAT.$LIB_EXT
      cd ../../../../

      echo "=== Building Final Burn Alpha Cores (CPS2) ==="
      cd fbacores/cps2/projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR/fba_cores_cps2_libretro$FORMAT.$LIB_EXT
      cd ../../../../

      echo "=== Building Final Burn Alpha Cores (NeoGeo) ==="
      cd fbacores/neogeo/projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR/fba_cores_neo_libretro$FORMAT.$LIB_EXT
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

source $BASE_DIR/libretro-build-common-xdk.sh

build_libretro_mednafen
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_fceu
build_libretro_gambatte
#build_libretro_nx
build_libretro_prboom
build_libretro_nestopia
build_libretro_tyrquake

