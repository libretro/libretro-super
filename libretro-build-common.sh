#!/bin/sh

die() {
   echo $1
   #exit 1
}

if [ "${CC}" ] && [ "${CXX}" ]; then
   COMPILER="CC=\"${CC}\" CXX=\"${CXX}\""
else
   COMPILER=""
fi

echo "Compiler: ${COMPILER}"

[[ "${ARM_NEON}" ]] && echo '=== ARM NEON opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
[[ "${CORTEX_A8}" ]] && echo '=== Cortex A8 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
[[ "${CORTEX_A9}" ]] && echo '=== Cortex A9 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo '=== ARM hardfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo '=== ARM softfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"
[[ "${X86}" ]] && echo '=== x86 CPU detected... ==='
[[ "${X86}" ]] && [[ "${X86_64}" ]] && echo '=== x86_64 CPU detected... ==='

export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
echo "${FORMAT_COMPILER_TARGET}"

check_opengl() {
   if [ "${BUILD_LIBRETRO_GL}" ]; then
      if [ "${ENABLE_GLES}" ]; then
         echo '=== OpenGL ES enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
         export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
      else
         echo '=== OpenGL enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
         export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
      fi
   else
      echo '=== OpenGL disabled in build ==='
   fi
}

build_libretro_ffmpeg() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-ffmpeg' ]; then
      echo '=== Checking OpenGL dependencies ==='
      echo '=== Building FFmpeg ==='
      cd libretro-ffmpeg

      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" "-j${JOBS}" clean || die 'Failed to clean FFmpeg'
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" "-j${JOBS}"
      cp "ffmpeg_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'FFmpeg not fetched, skipping ...'
   fi
}

build_libretro_fba_full() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-fba' ]; then
		echo '=== Building Final Burn Alpha (Full) ==='
      cd libretro-fba/
      cd svn-current/trunk

      "${MAKE}" -f makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Final Burn Alpha'
      "${MAKE}" -f makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Final Burn Alpha'
      cp "fb_alpha_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Final Burn Alpha not fetched, skipping ...'
   fi
}

build_libretro_pcsx_rearmed() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-pcsx-rearmed' ]; then
      echo '=== Building PCSX ReARMed ==='
      cd libretro-pcsx-rearmed

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean PCSX ReARMed'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build PCSX ReARMed'
      cp "pcsx_rearmed_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'PCSX ReARMed not fetched, skipping ...'
   fi
}

build_libretro_mednafen() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mednafen' ]; then
      echo '=== Building Mednafen ==='
      cd libretro-mednafen

      "${MAKE}" core='pce-fast' platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die "Failed to clean mednafen/${core}"
      "${MAKE}" core='pce-fast' platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die "Failed to build mednafen/${core}"
      cp "mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
      for core in wswan ngp vb; do
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die "Failed to clean mednafen/${core}"
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die "Failed to build mednafen/${core}"
         cp "mednafen_${core//-/_}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
      done
   else
      echo 'Mednafen not fetched, skipping ...'
   fi
}

build_libretro_mednafen_psx() {
   cd "${BASE_DIR}"

   if [ -d 'libretro-mednafen' ]; then
      echo '=== Building Mednafen PSX ==='
      cd libretro-mednafen

      for core in psx; do
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die "Failed to clean mednafen/${core}"
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die "Failed to build mednafen/${core}"
         cp "mednafen_${core//-/_}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
      done
   else
      echo 'Mednafen not fetched, skipping ...'
   fi
}

build_libretro_mednafen_gba() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mednafen' ]; then
      echo '=== Building Mednafen VBA ==='
      cd libretro-mednafen

      for core in gba; do
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die "Failed to clean mednafen/${core}"
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die "Failed to build mednafen/${core}"
         cp "mednafen_${core//-/_}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
      done
   else
      echo 'Mednafen not fetched, skipping ...'
   fi
}

build_libretro_mednafen_snes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mednafen' ]; then
      echo '=== Building Mednafen bSNES ==='
      cd libretro-mednafen

      for core in snes; do
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die "Failed to clean mednafen/${core}"
         "${MAKE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die "Failed to build mednafen/${core}"
         cp "mednafen_${core//-/_}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
      done
   else
      echo 'Mednafen not fetched, skipping ...'
   fi
}

build_libretro_stella() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-stella' ]; then
      echo '=== Building Stella ==='
      cd libretro-stella

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Stella'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Stella'
      cp "stella_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Stella not fetched, skipping ...'
   fi
}

build_libretro_handy() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-handy' ]; then
      echo '=== Building Handy ==='
      cd libretro-handy

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Handy'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Handy'
      cp "handy_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Handy not fetched, skipping ...'
   fi
}

build_libretro_quicknes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-quicknes' ]; then
      echo '=== Building QuickNES ==='
      cd libretro-quicknes/libretro

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean QuickNES'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build QuickNES'
      cp "quicknes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'QuickNES not fetched, skipping ...'
   fi
}

build_libretro_desmume() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-desmume' ]; then
      echo '=== Building Desmume ==='
      cd libretro-desmume

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "-j${JOBS}" clean || die 'Failed to clean Desmume'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "-j${JOBS}" || die 'Failed to build Desmume'
      cp "desmume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Desmume not fetched, skipping ...'
   fi
}

build_libretro_s9x() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-s9x' ]; then
      echo '=== Building SNES9x ==='
      cd libretro-s9x/libretro

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean SNES9x'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build SNES9x'
      cp "snes9x_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'SNES9x not fetched, skipping ...'
   fi
}

build_libretro_s9x_next() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-s9x-next' ]; then
      echo '=== Building SNES9x-Next ==='
      cd libretro-s9x-next/

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to build SNES9x-Next'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build SNES9x-Next'
      cp "snes9x_next_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'SNES9x-Next not fetched, skipping ...'
   fi
}

build_libretro_genplus() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-genplus' ]; then
      echo '=== Building Genplus GX ==='
      cd libretro-genplus/

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Genplus GX'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Genplus GX'
      cp "genesis_plus_gx_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Genplus GX not fetched, skipping ...'
   fi
}

build_libretro_mame078() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame078' ]; then
      echo '=== Building MAME 0.78 ==='
      cd libretro-mame078

      "${MAKE}" -f makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean MAME 0.78'
      "${MAKE}" -f makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build MAME 0.78'
      cp "mame078_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME 0.78 not fetched, skipping ...'
   fi
}

build_libretro_mame() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo '=== Building MAME ==='
      cd libretro-mame/0150

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean MAME'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build MAME'
      cp "mame_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

build_libretro_vbam() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-vbam' ]; then
      echo '=== Building VBA-M ==='
      cd libretro-vbam/src/libretro

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean VBA-M'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build VBA-M'
      cp "vbam_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'VBA-M not fetched, skipping ...'
   fi
}

build_libretro_vba_next() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-vba-next' ]; then
      echo '=== Building VBA-Next ==='
      cd libretro-vba-next/

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean VBA-Next'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build VBA-Next'
      cp "vba_next_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'VBA-Next not fetched, skipping ...'
   fi
}

build_libretro_fceu() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-fceu' ]; then
      echo '=== Building FCEUmm ==='
      cd libretro-fceu

      "${MAKE}" -C fceumm-code -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean FCEUmm'
      "${MAKE}" -C fceumm-code -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build FCEUmm'
      cp "fceumm-code/fceumm_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'FCEUmm not fetched, skipping ...'
   fi
}

build_libretro_gambatte() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-gambatte' ]; then
      echo '=== Building Gambatte ==='
      cd libretro-gambatte/libgambatte

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Gambatte'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Gambatte'
      cp "gambatte_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Gambatte not fetched, skipping ...'
   fi
}

build_libretro_nx() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-nx' ]; then
      echo '=== Building NXEngine ==='
      cd libretro-nx

      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean NXEngine'
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build NXEngine'
      cp "nxengine_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'NXEngine not fetched, skipping ...'
   fi
}

build_libretro_prboom() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-prboom' ]; then
      echo '=== Building PRBoom ==='
      cd libretro-prboom

      "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean PRBoom'
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build PRBoom'
      cp "prboom_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'PRBoom not fetched, skipping ...'
   fi
}

build_libretro_dinothawr() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-dinothawr' ]; then
      echo '=== Building Dinothawr ==='
      cd libretro-dinothawr

      "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Dinothawr'
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Dinothawr'
      cp "dinothawr_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Dinothawr not fetched, skipping ...'
   fi
}

build_libretro_meteor() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-meteor' ]; then
      echo '=== Building Meteor ==='
      cd libretro-meteor/libretro

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Meteor'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Meteor'
      cp "meteor_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Meteor not fetched, skipping ...'
   fi
}

build_libretro_nestopia() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-nestopia' ]; then
      echo '=== Building Nestopia ==='
      cd libretro-nestopia/libretro

      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Nestopia'
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Nestopia'
      cp "nestopia_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Nestopia not fetched, skipping ...'
   fi
}

build_libretro_tyrquake() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-tyrquake' ]; then
      echo '=== Building Tyr Quake ==='
      cd libretro-tyrquake

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Tyr Quake'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Tyr Quake'
      cp "tyrquake_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Tyr Quake not fetched, skipping ...'
   fi
}

build_libretro_modelviewer() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-modelviewer' ]; then
      echo '=== Building Modelviewer (GL) ==='
      cd libretro-gl-modelviewer

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Modelviewer'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Modelviewer'
      cp "modelviewer_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'ModelViewer not fetched, skipping ...'
   fi
}

build_libretro_scenewalker() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-scenewalker' ]; then
      echo '=== Building SceneWalker (GL) ==='
      cd libretro-gl-scenewalker

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean SceneWalker'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build SceneWalker'
      cp "scenewalker_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'SceneWalker not fetched, skipping ...'
   fi
}

build_libretro_instancingviewer() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-instancingviewer' ]; then
      echo '=== Building Instancing Viewer (GL) ==='
      cd libretro-gl-instancingviewer

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean InstancingViewer'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build InstancingViewer'
      cp "instancingviewer_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'InstancingViewer not fetched, skipping ...'
   fi
}

build_libretro_scummvm() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-scummvm' ]; then
      echo '=== Building ScummVM ==='
      cd libretro-scummvm/backends/platform/libretro/build

      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean ScummVM'
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build ScummVM'
      cp "scummvm_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'ScummVM not fetched, skipping ...'
   fi
}

build_libretro_dosbox() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-dosbox' ]; then
      echo '=== Building DOSbox ==='
      cd libretro-dosbox

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean DOSbox'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build DOSbox'
      cp "dosbox_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'DOSbox not fetched, skipping ...'
   fi
}

build_libretro_bsnes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes/perf' ]; then
      echo '=== Building bSNES performance ==='
      cd libretro-bsnes/perf

      rm -f obj/*.{o,"${FORMAT_EXT}"}
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX}" ui='target-libretro' profile='performance' "-j${JOBS}" || die 'Failed to build bSNES performance core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_performance_libretro.${FORMAT_EXT}"
   else
      echo 'bSNES performance not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes/balanced' ]; then
      echo '=== Building bSNES balanced ==='
      cd libretro-bsnes/balanced

      rm -f obj/*.{o,"${FORMAT_EXT}"}
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX}" ui='target-libretro' profile='balanced' "-j${JOBS}" || die 'Failed to build bSNES balanced core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_balanced_libretro.${FORMAT_EXT}"
   else
      echo 'bSNES compat not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes' ]; then
      echo '=== Building bSNES accuracy ==='
      cd libretro-bsnes

      rm -f obj/*.{o,"${FORMAT_EXT}"}
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX}" ui='target-libretro' profile='accuracy' "-j${JOBS}" || die 'Failed to build bSNES accuracy core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_accuracy_libretro.${FORMAT_EXT}"
   fi
}

build_libretro_bnes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bnes' ]; then
      echo '=== Building bNES ==='
      cd libretro-bnes

      mkdir -p obj
      "${MAKE}" "-j${JOBS}" clean || die 'Failed to clean bNES'
      "${MAKE}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build bNES'
      cp "libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bnes_libretro.${FORMAT_EXT}"
   else
      echo 'bNES not fetched, skipping ...'
   fi
}

build_libretro_mupen64() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mupen64plus' ]; then
      cd libretro-mupen64plus

      mkdir -p obj
      if [ "${X86}" ] && [ "${X86_64}" ]; then
         echo '=== Building Mupen 64 Plus (x86_64 dynarec) ==='
         "${MAKE}" WITH_DYNAREC='x86_64' "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86_64 dynarec)'
         "${MAKE}" WITH_DYNAREC='x86_64' "${COMPILER}" "-j${JOBS}" || die 'Failed to build Mupen 64 (x86_64 dynarec)'
      elif [ "${X86}" ]; then
         echo '=== Building Mupen 64 Plus (x86 32bit dynarec) ==='
         "${MAKE}" WITH_DYNAREC='x86' "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86 dynarec)'
         "${MAKE}" WITH_DYNAREC='x86' "${COMPILER}" "-j${JOBS}" || die 'Failed to build Mupen 64 (x86 dynarec)'
      elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ]; then
         echo '=== Building Mupen 64 Plus (ARM dynarec) ==='
         "${MAKE}" WITH_DYNAREC='arm' "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (ARM dynarec)'
         "${MAKE}" WITH_DYNAREC='arm' "${COMPILER}" "-j${JOBS}" || die 'Failed to build Mupen 64 (ARM dynarec)'
      else
         echo '=== Building Mupen 64 Plus ==='
         "${MAKE}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64'
         "${MAKE}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Mupen 64'
      fi
      cp "mupen64plus_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Mupen64 Plus not fetched, skipping ...'
   fi
}

build_libretro_picodrive() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-picodrive' ]; then
      echo '=== Building Picodrive ==='
      cd libretro-picodrive

      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die 'Failed to clean Picodrive'
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build PCSX Picodrive'
      cp "picodrive_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Picodrive not fetched, skipping ...'
   fi
}

create_dist_dir() {
   if [ -d "${RARCH_DIST_DIR}" ]; then
      echo "Directory ${RARCH_DIST_DIR} already exists, skipping creation..."
   else
      mkdir -p "${RARCH_DIST_DIR}"
   fi
}

create_dist_dir
