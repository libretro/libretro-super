#!/bin/sh

set -e

CORES_DIR="$PWD/.."
ROOT_DIR=$CORES_DIR/libretro-super
RARCH_DIR=$CORES_DIR/RetroArch
RARCH_DIST_DIR=$RARCH_DIR/ios/modules

export IOSSDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/

# clone/fetch the emulator core repos
cd $CORES_DIR
"$ROOT_DIR/libretro-fetch.sh"


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



build_libretro_mednafen
build_libretro_s9x_next
build_libretro_nestopia


