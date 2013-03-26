#!/bin/sh

set -e

CORES_DIR="$PWD/.."
ROOT_DIR=$CORES_DIR/libretro-super
RARCH_DIR=$CORES_DIR/RetroArch
RARCH_DIST_DIR=$RARCH_DIR/ios/modules

if [ ! -d "$RARCH_DIST_DIR" ]
then
  echo "Can't find the RetroArch directory, quitting..."
  exit 0
fi

export IOSSDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/

if ! $SKIPFETCH ; then
  # clone/fetch the emulator core repos
  cd $CORES_DIR
  "$ROOT_DIR/libretro-fetch.sh"
fi

MEDNAFEN_DIR_NAME=libretro-mednafen
build_libretro_mednafen()
{
   cd $CORES_DIR
   if [ -d "$MEDNAFEN_DIR_NAME" ]; then
      echo "=== Building Mednafen ==="
      cd $MEDNAFEN_DIR_NAME
      make clean
      make -f Makefile platform=ios
      cp "mednafen_psx_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

S9X_NEXT_DIR_NAME=libretro-s9x-next
build_libretro_s9x_next()
{
   cd $CORES_DIR
   if [ -d "$S9X_NEXT_DIR_NAME" ]; then
      echo "=== Building SNES9x-Next ==="
      cd $S9X_NEXT_DIR_NAME
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "snes9x_next_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

GENPLUS_DIR_NAME=libretro-genplus
build_libretro_genplus()
{
   cd $CORES_DIR
   if [ -d "$GENPLUS_DIR_NAME" ]; then
      echo "=== Building Genplus GX ==="
      cd $GENPLUS_DIR_NAME
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "genesis_plus_gx_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

FBA_DIR_NAME=libretro-fba
build_libretro_fba()
{
   cd $CORES_DIR
   if [ -d "$FBA_DIR_NAME" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd $FBA_DIR_NAME/svn-current/trunk
      make -f makefile.libretro clean
      make -f makefile.libretro platform=ios

      cp "fb_alpha_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

# TODO: get ios into makefile
#
# VBA_NEXT_DIR_NAME=libretro-vba
# build_libretro_vba()
# {
#    cd $CORES_DIR
#    if [ -d "$VBA_NEXT_DIR_NAME" ]; then
#       echo "=== Building VBA-Next ==="
#       cd $VBA_NEXT_DIR_NAME
#       make -f Makefile.libretro clean
#       make -f Makefile.libretro platform=ios
#
#
#    else
#       echo "VBA-Next not fetched, skipping ..."
#    fi
# }

# TODO: get ios into makefile
#
# FCEUMM_DIR_NAME=libretro-fceu
# build_libretro_fceu()
# {
#    cd $CORES_DIR
#    if [ -d "$FCEUMM_DIR_NAME" ]; then
#       echo "=== Building FCEU ==="
#       cd $FCEUMM_DIR_NAME
#       make -f Makefile.libretro-fceux clean
#       make -f Makefile.libretro-fceux platform=ios
#
#     else
#       echo "FCEU not fetched, skipping ..."
#    fi
# }

GAMBATTE_DIR_NAME=libretro-gambatte
build_libretro_gambatte()
{
   cd $CORES_DIR
   if [ -d "$GAMBATTE_DIR_NAME" ]; then
      echo "=== Building Gambatte ==="
      cd $GAMBATTE_DIR_NAME/libgambatte
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "gambatte_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}

NXENGINE_DIR_NAME=libretro-nx
build_libretro_nx()
{
   cd $CORES_DIR
   if [ -d "$NXENGINE_DIR_NAME" ]; then
      echo "=== Building NXEngine ==="
      cd $NXENGINE_DIR_NAME
      make -f Makefile clean
      make -f Makefile platform=ios

      cp "nxengine_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "NXEngine not fetched, skipping ..."
   fi
}

PRBOOM_DIR_NAME=libretro-prboom
build_libretro_prboom()
{
   cd $CORES_DIR
   if [ -d "$PRBOOM_DIR_NAME" ]; then
      echo "=== Building PRBoom ==="
      cd $PRBOOM_DIR_NAME
      make -f Makefile clean
      make -f Makefile platform=ios

      cp "prboom_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}

STELLA_DIR_NAME=libretro-stella
build_libretro_stella()
{
   cd $CORES_DIR
   if [ -d "$STELLA_DIR_NAME" ]; then
      echo "=== Building Stella ==="
      cd $STELLA_DIR_NAME
      make -f Makefile clean
      make -f Makefile platform=ios

      cp "stella_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Stella not fetched, skipping ..."
   fi
}

DESMUME_DIR_NAME=libretro-desmume
build_libretro_desmume()
{
   cd $CORES_DIR
   if [ -d "$DESMUME_DIR_NAME" ]; then
      echo "=== Building Desmume ==="
      cd $DESMUME_DIR_NAME
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

# TODO: get ios into makefile
#
# QUICKNES_DIR_NAME=libretro-quicknes
# build_libretro_quicknes()
# {
#    cd $CORES_DIR
#    if [ -d "$QUICKNES_DIR_NAME" ]; then
#       echo "=== Building QuickNES ==="
#       cd $QUICKNES_DIR_NAME
#       make -f Makefile clean
#       make -f Makefile platform=ios
#
# #       cp "quicknes_libretro.dylib" "$RARCH_DIST_DIR"
#    else
#       echo "QuickNES not fetched, skipping ..."
#    fi
# }

NESTOPIA_DIR_NAME=libretro-nestopia/libretro
build_libretro_nestopia()
{
   cd $CORES_DIR
   if [ -d "$NESTOPIA_DIR_NAME" ]; then
      echo "=== Building Nestopia ==="
      cd $NESTOPIA_DIR_NAME
      make clean
      make -f Makefile platform=ios

      cp "nestopia_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

TYRQUAKE_DIR_NAME=libretro-tyrquake
build_libretro_tyrquake()
{
   cd $CORES_DIR
   if [ -d "$TYRQUAKE_DIR_NAME" ]; then
      echo "=== Building TyrQuake ==="
      cd $TYRQUAKE_DIR_NAME
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "tyrquake_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "TyrQuake not fetched, skipping ..."
   fi
}

build_libretro_mednafen
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
# build_libretro_vba
# build_libretro_fceu
build_libretro_gambatte
build_libretro_nx
build_libretro_prboom
build_libretro_stella
build_libretro_desmume
# build_libretro_quicknes
build_libretro_nestopia
build_libretro_tyrquake

