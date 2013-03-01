#!/bin/sh

CORES_DIR=~/local-repos
ROOT_DIR=$CORES_DIR/libretro-super
RARCH_DIR=$CORES_DIR/RetroArch
RARCH_DIST_DIR=$RARCH_DIR/dist-scripts
FORMAT=_ps3
FORMAT_COMPILER_TARGET=ps3
FORMAT_COMPILER_TARGET_ALT=sncps3
JOBS=7

die()
{
   echo $1
   #exit 1
}

MEDNAFEN_DIR_NAME=mednafen-libretro

build_libretro_mednafen()
{
   cd $CORES_DIR
   if [ -d "$MEDNAFEN_DIR_NAME" ]; then
      echo "=== Building Mednafen ==="
      cd $MEDNAFEN_DIR_NAME

      make core=pce-fast platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean mednafen/${core}"
      make core=pce-fast platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build mednafen/${core}"
      cp mednafen_pce_fast_libretro$FORMAT.a $RARCH_DIST_DIR
      for core in wswan ngp vb
      do
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean mednafen/${core}"
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build mednafen/${core}"
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.a $RARCH_DIST_DIR
      done
      cd ..
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

#build_libretro_s9x()
#{
   #if [ -d "libretro-s9x" ]; then
      #echo "=== Building SNES9x ==="
      #cd libretro-s9x/libretro
      #make -j4 || die "Failed to build SNES9x"
      #cp libretro.so ../libretro-snes9x.so
      #cd ../..
   #else
      #echo "SNES9x not fetched, skipping ..."
   #fi
#}

S9X_NEXT_DIR_NAME=snes9x-next

build_libretro_s9x_next()
{
   cd $CORES_DIR
   if [ -d "$S9X_NEXT_DIR_NAME" ]; then
      echo "=== Building SNES9x-Next ==="
      cd $S9X_NEXT_DIR_NAME
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to build SNES9x-Next"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build SNES9x-Next"
      cp snes9x_next_libretro$FORMAT.a $RARCH_DIST_DIR
      cd ..
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

GENPLUS_DIR_NAME=Genesis-Plus-GX

build_libretro_genplus()
{
   cd $CORES_DIR
   if [ -d "$GENPLUS_DIR_NAME" ]; then
      echo "=== Building Genplus GX ==="
      cd $GENPLUS_DIR_NAME
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Genplus GX"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Genplus GX"
      cp genesis_plus_gx_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

FBA_DIR_NAME=fba-libretro

build_libretro_fba()
{
   cd $CORES_DIR
   if [ -d "$FBA_DIR_NAME" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd $FBA_DIR_NAME/svn-current/trunk
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha"
      cp fb_alpha_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

VBA_NEXT_DIR_NAME=vba-next

build_libretro_vba()
{
   cd $CORES_DIR
   if [ -d "$VBA_NEXT_DIR_NAME" ]; then
      echo "=== Building VBA-Next ==="
      cd $VBA_NEXT_DIR_NAME
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean VBA-Next"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build VBA-Next"
      cp vba_next_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

FCEUMM_DIR_NAME=fceu-next

build_libretro_fceu()
{
   cd $CORES_DIR
   if [ -d "$FCEUMM_DIR_NAME" ]; then
      echo "=== Building FCEU ==="
      cd $FCEUMM_DIR_NAME
      make -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean FCEUmm"
      make -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build FCEUmm"
      cp fceumm-code/fceumm_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "FCEU not fetched, skipping ..."
   fi
}

GAMBATTE_DIR_NAME=gambatte-libretro

build_libretro_gambatte()
{
   cd $CORES_DIR
   if [ -d "$GAMBATTE_DIR_NAME" ]; then
      echo "=== Building Gambatte ==="
      cd $GAMBATTE_DIR_NAME/libgambatte
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean Gambatte"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build Gambatte"
      cp gambatte_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}

NXENGINE_DIR_NAME=nxengine-libretro

build_libretro_nx()
{
   cd $CORES_DIR
   if [ -d "$NXENGINE_DIR_NAME" ]; then
      echo "=== Building NXEngine ==="
      cd $NXENGINE_DIR_NAME
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean NXEngine"
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build NXEngine"
      cp nxengine_libretro$FORMAT.a $RARCH_DIST_DIR
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
      make platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean PRBoom"
      make platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build PRBoom"
      cp prboom_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}


#build_libretro_stella()
#{
   #if [ -d "libretro-stella" ]; then
      #echo "=== Building Stella ==="
      #cd libretro-stella
      #make -j4 || die "Failed to build Stella"
      #cp libretro.so libretro-stella.so
      #cd ../
   #else
      #echo "Stella not fetched, skipping ..."
   #fi
#}

#build_libretro_desmume()
#{
   #if [ -d "libretro-desmume" ]; then
      #echo "=== Building Desmume ==="
      #cd libretro-desmume
      #make -f Makefile.libretro -j4 || die "Failed to build Desmume"
      #cp libretro.so libretro-desmume.so
      #cd ../
   #else
      #echo "Desmume not fetched, skipping ..."
   #fi
#}

#build_libretro_quicknes()
#{
   #if [ -d "libretro-quicknes" ]; then
      #echo "=== Building QuickNES ==="
      #cd libretro-quicknes/libretro
      #make -j4 || die "Failed to build QuickNES"
      #cp libretro.so ../libretro-quicknes.so
      #cd ../..
   #else
      #echo "QuickNES not fetched, skipping ..."
   #fi
#}

NESTOPIA_DIR_NAME=nestopia

build_libretro_nestopia()
{
   cd $CORES_DIR
   if [ -d "$NESTOPIA_DIR_NAME" ]; then
      echo "=== Building Nestopia ==="
      cd $NESTOPIA_DIR_NAME/libretro
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Nestopia"
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Nestopia"
      cp nestopia_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

TYRQUAKE_DIR_NAME=tyrquake

build_libretro_tyrquake()
{
   cd $CORES_DIR
   if [ -d "$TYRQUAKE_DIR_NAME" ]; then
      echo "=== Building Tyr Quake ==="
      cd $TYRQUAKE_DIR_NAME
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Tyr Quake"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Tyr Quake"
      cp tyrquake_libretro$FORMAT.a $RARCH_DIST_DIR
   else
      echo "Tyr Quake not fetched, skipping ..."
   fi
}

build_libretro_mednafen
#build_libretro_s9x
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_fceu
build_libretro_gambatte
build_libretro_nx
build_libretro_prboom
#build_libretro_stella
#build_libretro_desmume
#build_libretro_quicknes
build_libretro_nestopia
build_libretro_tyrquake

