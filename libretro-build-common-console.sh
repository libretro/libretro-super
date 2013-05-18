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
      cp fb_alpha_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
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
      if [ $ARMV7 = true ]; then
         echo "=== Building PCSX ReARMed (ARMV7 NEON) ==="
         make -f Makefile.libretro platform=arm -j$JOBS clean || die "Failed to clean PCSX ReARMed"
         make -f Makefile.libretro platform=arm -j$JOBS || die "Failed to build PCSX ReARMed"
      else
         make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean PCSX ReARMed"
         make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build PCSX ReARMed"
      fi
      cp pcsx_rearmed_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
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
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
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
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
      done
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_mednafen_gba()
{
   cd $BASE_DIR

   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen VBA ==="
      cd libretro-mednafen

      for core in gba
      do
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean mednafen/${core}"
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build mednafen/${core}"
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
      done
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_mednafen_snes()
{
   cd $BASE_DIR

   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen bSNES ==="
      cd libretro-mednafen

      for core in snes
      do
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean mednafen/${core}"
         make core=${core} platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build mednafen/${core}"
         cp mednafen_$(echo ${core} | tr '[\-]' '[_]')_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
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
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} clean
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS

      cp stella_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "Stella not fetched, skipping ..."
   fi
}

build_libretro_quicknes()
{
   cd "$BASE_DIR"
   if [ -d "libretro-quicknes" ]; then
      echo "=== Building QuickNES ==="
      cd libretro-quicknes/libretro
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean QuickNES"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build QuickNES"
      cp quicknes_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "QuickNES not fetched, skipping ..."
   fi
}

build_libretro_desmume()
{
   cd $BASE_DIR
   if [ -d "libretro-desmume" ]; then
      echo "=== Building Desmume ==="
      cd libretro-desmume
      if [ $X86 = true ]; then
         echo "=== Building Desmume with x86 JIT recompiler ==="
         make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET} DESMUME_JIT=1 -j$JOBS clean || die "Failed to clean Desmume"
         make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET} DESMUME_JIT=1 -j$JOBS || die "Failed to build Desmume"
      elif [ $ARMV7 = true ]; then
         echo "=== Building Desmume with ARMv7 JIT recompiler ==="
         make -f Makefile.libretro platform=arm DESMUME_JIT=1 -j$JOBS clean || die "Failed to clean Desmume"
         make -f Makefile.libretro platform=arm DESMUME_JIT=1 -j$JOBS || die "Failed to build Desmume"
      else
         make -f Makefile.libretro clean
         make -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS
      fi

      cp desmume_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

build_libretro_s9x()
{
   cd "$BASE_DIR"
   if [ -d "libretro-s9x" ]; then
      echo "=== Building SNES9x ==="
      cd libretro-s9x/libretro
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean SNES9x"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build SNES9x"
      cp snes9x_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "SNES9x not fetched, skipping ..."
   fi
}

build_libretro_s9x_next()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x-next" ]; then
      echo "=== Building SNES9x-Next ==="
      cd libretro-s9x-next/
      make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET_ALT} -j$JOBS clean || die "Failed to build SNES9x-Next"
      make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET_ALT} -j$JOBS || die "Failed to build SNES9x-Next"
      cp snes9x_next_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
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
      cp genesis_plus_gx_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libretro_mame078()
{
   cd $BASE_DIR
   if [ -d "libretro-mame078" ]; then
      echo "=== Building MAME 0.78 ==="
      cd libretro-mame078

      make -f makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean MAME 0.78"
      make -f makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build MAME 0.78"
      cp mame078_libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "MAME 0.78 not fetched, skipping ..."
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
      cp vba_next_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libretro_fceu()
{
   cd $BASE_DIR
   if [ -d "libretro-fceu" ]; then
      echo "=== Building FCEUmm ==="
      cd libretro-fceu
      make -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean FCEUmm"
      make -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build FCEUmm"
      cp fceumm-code/fceumm_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "FCEUmm not fetched, skipping ..."
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
      cp gambatte_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
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
      cp nxengine_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
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
      make platform=${FORMAT_COMPILER_TARGET_ALT} -j$JOBS clean || die "Failed to clean PRBoom"
      make platform=${FORMAT_COMPILER_TARGET_ALT} -j$JOBS || die "Failed to build PRBoom"
      cp prboom_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}

build_libretro_meteor()
{
   cd "$BASE_DIR"
   if [ -d "libretro-meteor" ]; then
      echo "=== Building Meteor ==="
      cd libretro-meteor/libretro
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean Meteor"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build Meteor"
      cp meteor_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "Meteor not fetched, skipping ..."
   fi
}

build_libretro_nestopia()
{
   cd $BASE_DIR
   if [ -d "libretro-nestopia" ]; then
      echo "=== Building Nestopia ==="
      cd libretro-nestopia/libretro
      make platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean Nestopia"
      make platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build Nestopia"
      cp nestopia_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
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
      make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean Tyr Quake"
      make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build Tyr Quake"
      cp tyrquake_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "Tyr Quake not fetched, skipping ..."
   fi
}

build_libretro_modelviewer()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-modelviewer" ]; then
      echo "=== Building Modelviewer (GL) ==="
      cd libretro-gl-modelviewer
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean Modelviewer"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build Modelviewer"
      cp modelviewer_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "ModelViewer not fetched, skipping ..."
   fi
}

build_libretro_scenewalker()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-scenewalker" ]; then
      echo "=== Building SceneWalker (GL) ==="
      cd libretro-gl-scenewalker
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean SceneWalker"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build SceneWalker"
      cp scenewalker_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "SceneWalker not fetched, skipping ..."
   fi
}

build_libretro_scummvm()
{
   cd $BASE_DIR
   if [ -d "libretro-scummvm" ]; then
      echo "=== Building ScummVM ==="
      cd libretro-scummvm/backends/platform/libretro/build
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean ScummVM"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build ScummVM"
      cp scummvm_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "ScummVM not fetched, skipping ..."
   fi
}

build_libretro_dosbox()
{
   cd $BASE_DIR
   if [ -d "libretro-dosbox" ]; then
      echo "=== Building DOSbox ==="
      cd libretro-dosbox
      make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET} -j$JOBS clean || die "Failed to clean DOSbox"
      make -f Makefile.libretro platform=${FORMAT_COMPILER_TARGET} -j$JOBS || die "Failed to build DOSbox"
      cp dosbox_libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"
   else
      echo "DOSbox not fetched, skipping ..."
   fi
}

build_libretro_bsnes()
{
   cd "$BASE_DIR"
   if [ -d "libretro-bsnes/perf" ]; then
      echo "=== Building bSNES performance ==="
      cd libretro-bsnes/perf/higan
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} compiler="$CC" ui=target-libretro profile=performance -j$JOBS clean || die "Failed to clean bSNES performance core"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} compiler="$CC" ui=target-libretro profile=performance -j$JOBS || die "Failed to build bSNES performance core"
      cp -f out/libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"/bsnes_libretro_performance.${FORMAT_EXT}
   else
      echo "bSNES performance not fetched, skipping ..."
   fi

   cd "$BASE_DIR"
   if [ -d "libretro-bsnes/balanced" ]; then
      echo "=== Building bSNES balanced ==="
      cd libretro-bsnes/balanced/higan
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} compiler="$CC" ui=target-libretro profile=balanced -j$JOBS clean || die "Failed to clean bSNES balanced core"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} compiler="$CC" ui=target-libretro profile=balanced -j$JOBS || die "Failed to build bSNES balanced core"
      cp -f out/libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"/bsnes_libretro_balanced.${FORMAT_EXT}
   else
      echo "bSNES compat not fetched, skipping ..."
   fi

   cd "$BASE_DIR"
   if [ -d "libretro-bsnes" ]; then
      echo "=== Building bSNES accuracy ==="
      cd libretro-bsnes/higan
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} compiler="$CC" ui=target-libretro profile=accuracy -j$JOBS clean || die "Failed to clean bSNES accuracy core"
      make -f Makefile platform=${FORMAT_COMPILER_TARGET} compiler="$CC" ui=target-libretro profile=accuracy -j$JOBS || die "Failed to build bSNES accuracy core"
      cp -f out/libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"/bsnes_libretro_accuracy.${FORMAT_EXT}
   fi
}

build_libretro_bnes()
{
   cd "$BASE_DIR"
   if [ -d "libretro-bnes" ]; then
      echo "=== Building bNES ==="
      cd libretro-bnes
      mkdir -p obj
      make -j$JOBS clean || die "Failed to clean bNES"
      make -j$JOBS || die "Failed to build bNES"
      cp libretro${FORMAT}.${FORMAT_EXT} "$RARCH_DIST_DIR"/bnes_libretro.${FORMAT_EXT}
   else
      echo "bNES not fetched, skipping ..."
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
