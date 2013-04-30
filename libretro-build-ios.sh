#!/bin/sh

set -e

BASE_DIR="$PWD"
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ios
JOBS=4

export IOSSDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/

build_libretro_mednafen()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen ==="
      cd libretro-mednafen

      for core in psx pce-fast wswan ngp gba vb
      do
			make -f Makefile platform=ios core=${core} clean
         make -f Makefile platform=ios core=${core} -j${JOBS} || die "Failed to build mednafen/${core}"
         cp "mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro.dylib" "$RARCH_DIST_DIR"
      done
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_s9x_next()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x-next" ]; then
      echo "=== Building SNES9x-Next ==="
      cd libretro-s9x-next/
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "snes9x_next_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

build_libretro_genplus()
{
   cd $BASE_DIR
   if [ -d "libretro-genplus" ]; then
      echo "=== Building Genplus GX ==="
      cd libretro-genplus/
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "genesis_plus_gx_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libretro_fba()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba
      cd svn-current/trunk
      make -f makefile.libretro clean
      make -f makefile.libretro platform=ios

      cp "fb_alpha_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

build_libretro_vba()
{
   cd $BASE_DIR
   if [ -d "libretro-vba" ]; then
      echo "=== Building VBA-Next ==="
      cd libretro-vba/
		make -f Makefile.libretro platform=ios clean
      make -f Makefile.libretro platform=ios -j4 || die "Failed to build VBA-Next"
      cp "vba_next_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libretro_fceu()
{
   cd $BASE_DIR
   if [ -d "libretro-fceu" ]; then
      echo "=== Building FCEU ==="
      cd libretro-fceu
		make -C fceumm-code -f Makefile.libretro clean
      make -C fceumm-code -f Makefile.libretro platform=ios -j4 || die "Failed to build FCEU"
      cp "fceumm-code/fceumm_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "FCEU not fetched, skipping ..."
   fi
}

build_libretro_gambatte()
{
   cd $BASE_DIR
   if [ -d "libretro-gambatte" ]; then
      echo "=== Building Gambatte ==="
      cd libretro-gambatte/libgambatte
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "gambatte_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}

build_libretro_nx()
{
   cd $BASE_DIR
   if [ -d "libretro-nx" ]; then
      echo "=== Building NXEngine ==="
      cd libretro-nx
      make -f Makefile clean
      make -f Makefile platform=ios

      cp "nxengine_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "NXEngine not fetched, skipping ..."
   fi
}

build_libretro_prboom()
{
   cd $BASE_DIR
   if [ -d "libretro-prboom" ]; then
      echo "=== Building PRBoom ==="
      cd libretro-prboom
      make -f Makefile clean
      make -f Makefile platform=ios

      cp "prboom_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}

build_libretro_stella()
{
   cd $BASE_DIR
   if [ -d "libretro-stella" ]; then
      echo "=== Building Stella ==="
      cd libretro-stella
      make -f Makefile clean
      make -f Makefile platform=ios

      cp "stella_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Stella not fetched, skipping ..."
   fi
}

build_libretro_desmume()
{
   cd $BASE_DIR
   if [ -d "libretro-desmume" ]; then
      echo "=== Building Desmume ==="
      cd libretro-desmume
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "desmume_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

build_libretro_nestopia()
{
   cd $BASE_DIR
   if [ -d "libretro-nestopia" ]; then
      echo "=== Building Nestopia ==="
      cd libretro-nestopia/libretro
      make clean
      make -f Makefile platform=ios

      cp "nestopia_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

build_libretro_tyrquake()
{
   cd $BASE_DIR
   if [ -d "libretro-tyrquake" ]; then
      echo "=== Building TyrQuake ==="
      cd libretro-tyrquake
      make -f Makefile.libretro clean
      make -f Makefile.libretro platform=ios

      cp "tyrquake_libretro.dylib" "$RARCH_DIST_DIR"
   else
      echo "TyrQuake not fetched, skipping ..."
   fi
}

create_dist_dir()
{
   if [ -d $RARCH_DIR ]; then
      echo "Directory $RARCH_DIR already exists, skipping creation..."
   else
      mkdir $RARCH_DIR
   fi

   if [ -d $RARCH_DIST_DIR ]; then
      echo "Directory $RARCH_DIST_DIR already exists, skipping creation..."
   else
      mkdir $RARCH_DIST_DIR
   fi
}

create_dist_dir

build_libretro_mednafen
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_fceu
build_libretro_gambatte
build_libretro_nx
build_libretro_prboom
build_libretro_stella
build_libretro_desmume
build_libretro_nestopia
build_libretro_tyrquake

