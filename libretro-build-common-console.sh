#!/bin/sh

die()
{
   echo $1
   #exit 1
}

build_libretro_fba_full()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
		echo "=== Building Final Burn Alpha (Full) ==="
      cd libretro-fba/
      cd svn-current/trunk
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha"
      cp fb_alpha_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

build_libretro_pcsx_rearmed()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-pcsx-rearmed" ]; then
      echo "=== Building PCSX ReARMed ==="
      cd libretro-pcsx-rearmed
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean PCSX ReARMed"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build PCSX ReARMed"
      cp pcsx_rearmed_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
   else
      echo "PCSX ReARMed not fetched, skipping ..."
   fi
}

build_libretro_mednafen()
{
   cd $BASE_DIR

   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen ==="
      cd libretro-mednafen

      make core=pce-fast platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean mednafen/${core}"
      make core=pce-fast platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build mednafen/${core}"
      cp mednafen_pce_fast_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
      for core in wswan ngp vb
      do
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean mednafen/${core}"
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build mednafen/${core}"
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
      done
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_mednafen_psx()
{
   cd $BASE_DIR

   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen PSX ==="
      cd libretro-mednafen

      for core in psx
      do
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean mednafen/${core}"
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build mednafen/${core}"
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
      done
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_mednafen_gba()
{
   cd $BASE_DIR

   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen PSX ==="
      cd libretro-mednafen

      for core in psx
      do
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean mednafen/${core}"
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build mednafen/${core}"
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
      done
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_stella()
{
   cd $BASE_DIR
   if [ -d "libretro-stella" ]; then
      echo "=== Building Stella ==="
      cd libretro-stella
      make -f Makefile clean
      make -f Makefile platform=$FORMAT_COMPILER_TARGET -j$JOBS

      cp stella_libretro.dylib $RARCH_DIST_DIR
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
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS

      cp desmume_libretro.dylib $RARCH_DIST_DIR
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

build_libretro_s9x_next()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x-next" ]; then
      echo "=== Building SNES9x-Next ==="
      cd libretro-s9x-next/
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to build SNES9x-Next"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build SNES9x-Next"
      cp snes9x_next_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
      cd ..
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
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Genplus GX"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Genplus GX"
      cp genesis_plus_gx_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}


build_libretro_vba()
{
   cd $BASE_DIR
   if [ -d "libretro-vba" ]; then
      echo "=== Building VBA-Next ==="
      cd libretro-vba/
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean VBA-Next"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build VBA-Next"
      cp vba_next_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
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
      make -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean FCEUmm"
      make -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build FCEUmm"
      cp fceumm-code/fceumm_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
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
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean Gambatte"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build Gambatte"
      cp gambatte_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
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
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean NXEngine"
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build NXEngine"
      cp nxengine_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
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
      make platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS clean || die "Failed to clean PRBoom"
      make platform=$FORMAT_COMPILER_TARGET_ALT -j$JOBS || die "Failed to build PRBoom"
      cp prboom_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}

build_libretro_nestopia()
{
   cd $BASE_DIR
   if [ -d "libretro-nestopia" ]; then
      echo "=== Building Nestopia ==="
      cd libretro-nestopia/libretro
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Nestopia"
      make platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Nestopia"
      cp nestopia_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

build_libretro_tyrquake()
{
   cd $BASE_DIR
   if [ -d "libretro-tyrquake" ]; then
      echo "=== Building Tyr Quake ==="
      cd libretro-tyrquake
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Tyr Quake"
      make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Tyr Quake"
      cp tyrquake_libretro$FORMAT.$FORMAT_EXT $RARCH_DIST_DIR
   else
      echo "Tyr Quake not fetched, skipping ..."
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
