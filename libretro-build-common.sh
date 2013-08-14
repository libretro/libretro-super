#!/bin/sh

die() { 
   echo "$1"
   #exit 1
}

if [ "${CC}" ] && [ "${CXX}" ]; then
   COMPILER="CC=\"${CC}\" CXX=\"${CXX}\""
else
   COMPILER=""
fi

echo "Compiler: ${COMPILER}"

[[ "$ARM_NEON" ]] && echo '=== ARM NEON opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
[[ "$CORTEX_A8" ]] && echo '=== Cortex A8 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
[[ "$CORTEX_A9" ]] && echo '=== Cortex A9 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
[[ "$ARM_HARDFLOAT" ]] && echo '=== ARM hardfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
[[ "$ARM_SOFTFLOAT" ]] && echo '=== ARM softfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"

export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
echo "${FORMAT_COMPILER_TARGET}"

check_opengl() {
   if [ "${BUILD_LIBRETRO_GL}" ]; then
      if [ "${ENABLE_GLES}" ]; then
         echo '=== OpenGL ES enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
      else
         echo '=== OpenGL enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
      fi
      export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
   else
      echo '=== OpenGL disabled in build ==='
   fi
}

basic_build() {
   echo "=== Building ${CORE_TARGET} ==="
   "${MAKE}" "${CORE_MAKEFILE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" clean || die "Failed to clean ${CORE_TARGET}"
   "${MAKE}" "${CORE_MAKEFILE}" core="${core}" platform="${FORMAT_COMPILER_TARGET}" "${COMPILER}" "-j${JOBS}" || die "Failed to make ${CORE_TARGET}"
   cp "${CORE_TARGET}${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
}

basic_build_alt() {
   echo "=== Building ${CORE_TARGET} ==="
   "${MAKE}" "${CORE_MAKEFILE}" core="${core}" platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die "Failed to clean ${CORE_TARGET}"
   "${MAKE}" "${CORE_MAKEFILE}" core="${core}" platform="${FORMAT_COMPILER_TARGET_ALT}" "${COMPILER}" "-j${JOBS}" || die "Filed to build ${CORE_TARGET}"
   cp "${CORE_TARGET}${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
}

build_libretro_ffmpeg() {
   cd "${BASE_DIR}/libretro-ffmpeg" > /dev/null 2>&1 && \
      check_opengl && CORE_TARGET='ffmpeg_libretro' basic_build || \
      echo 'FFmpeg not fetched, skipping...'
}

build_libretro_fba_full() {
   cd "${BASE_DIR}/libretro-fba/svn-current/trunk" > /dev/null 2>&1 && \
      CORE_TARGET='ffmpeg_libretro' CORE_MAKEFILE='-f makefile.libretro' basic_build || \
      echo 'Final Burn Alpha not fetched, skipping...'
}

build_libretro_pcsx_rearmed() {
   cd "${BASE_DIR}/libretro-pcsx-rearmed" > /dev/null 2>&1 && \
      CORE_TARGET='pcsx_rearmed_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'PCSX ReARMed not fetched, skipping...'
}

build_libretro_mednafen() {
   cd "${BASE_DIR}/libretro-mednafen" > /dev/null 2>&1 && \
      core='pce-fast' CORE_TARGET="mednafen_${core//-/_}_libretro" basic_build_alt && \
      for core in wswan ngp vb psx gba snes; do 
         core="${core}" CORE_TARGET="mednafen_${core//-/_}_libretro" basic_build
      done || echo 'Mednafen not fetched, skipping...'
}

build_libretro_stella() {
   cd "${BASE_DIR}/libretro-stella" > /dev/null 2>&1 && \
      CORE_TARGET='stella_libretro' basic_build || \
      echo 'Stella not fetched, skipping...'
}

build_libretro_quicknes() {
   cd "${BASE_DIR}/libretro-quicknes/libretro" > /dev/null 2>&1 && \
      CORE_TARGET='quicknes_libretro' basic_build || \
      echo 'QuickNES not fetched, skipping...'
}

build_libretro_desmume() {
   cd "${BASE_DIR}/libretro-desmume" > /dev/null 2>&1 && \
      CORE_TARGET='desmume_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'Desmume not fetched, skipping...'
}

build_libretro_s9x() {
   cd "${BASE_DIR}/libretro-s9x/libretro" > /dev/null 2>&1 && \
      CORE_TARGET='snes9x_libretro' basic_build || \
      echo 'SNES9x not fetched, skipping...'
}

build_libretro_s9x_next() {
   cd "${BASE_DIR}/libretro-s9x-next" > /dev/null 2>&1 && \
      CORE_TARGET='snes9x_next_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build_alt || \
      echo 'SNES9x-Next not fetched, skipping...'
}

build_libretro_genplus() {
   cd "${BASE_DIR}/libretro-genplus" > /dev/null 2>&1 && \
      CORE_TARGET='genesis_plus_gx_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'Genplus GX not fetched, skipping...'
}

build_libretro_mame078() {
   cd "${BASE_DIR}/libretro/mame078" > /dev/null 2>&1 && \
      CORE_TARGET='mame078_libretro' CORE_MAKEFILE='-f makefile' basic_build
      echo 'MAME 0.78 not fetched, skipping...'
}

build_libretro_vba() {
   cd "${BASE_DIR}/libretro-vba" > /dev/null 2>&1 && \
      CORE_TARGET='vba_next_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build_alt || \
      echo "VBA-Next not fetched, skipping ..."
}

build_libretro_fceu() {
   cd "${BASE_DIR}/libretro-fceu/fceumm-code" > /dev/null 2>&1 && \
      #${MAKE} -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET $COMPILER -j$JOBS clean || die "Failed to clean FCEUmm"
      #${MAKE} -C fceumm-code -f Makefile.libretro platform=$FORMAT_COMPILER_TARGET $COMPILER -j$JOBS || die "Failed to build FCEUmm"
      #cp fceumm-code/fceumm_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
      CORE_TARGET='fceumm_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'FCEUmm not fetched, skipping...'
}

build_libretro_gambatte() {
   cd "${BASE_DIR}/libretro-gambatte/libgambatte" > /dev/null 2>&1 && \
      CORE_TARGET='gambatte_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build_alt || \
      echo 'Gambatte not fetched, skipping...'
   fi
}

build_libretro_nx() {
   cd "${BASE_DIR}/libretro-nx" > /dev/null 2>&1 && \
      CORE_TARGET='nxengine_libretro' basic_build || \
      echo 'NXEngine not fetched, skipping'
}

build_libretro_prboom() {
   cd "${BASE_DIR}/libretro-prboom" > /dev/null 2>&1 && \
      CORE_TARGET='prboom_libretro' basic_build_alt || \
      echo 'PRBoom not fetched, skipping...'
}

build_libretro_meteor() {
   cd "${BASE_DIR}/libretro-meteor/libretro" > /dev/null 2>&1 && \
      CORE_TARGET='meteor_libretro' basic_build || \
      echo 'Meteor not fetched, skipping...'
}

build_libretro_nestopia() {
   cd "${BASE_DIR}/libretro-nestopia/libretro" > /dev/null 2>&1 && \
      CORE_TARGET='nestopia_libretro' basic_build || \
      echo 'Nestopia not fetched, skipping...'
}

build_libretro_tyrquake() {
   cd "${BASE_DIR}/libretro-tyrquake" > /dev/null 2>&1 && \
      CORE_TARGET='tryquake_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'Tyr Quake not fetched, skipping...'
}

build_libretro_modelviewer() {
   cd "${BASE_DIR}/libretro-gl-modelviewer" > /dev/null 2>&1 && \
      check_opengl && CORE_TARGET='modelviewer_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'ModelViewer not fetched, skipping...'
}

build_libretro_scenewalker() {
   cd "${BASE_DIR}/libretro-gl-scenewalker" > /dev/null 2>&1 && \
      CORE_TARGET='scenewalker_libretro' basic_build || \
      echo 'SceneWalker not fetched, skipping...'
}

build_libretro_instancingviewer() {
   cd "${BASE_DIR}/libretro-gl-instancingviewer" > /dev/null 2>&1 && \
      CORE_TARGET='instancingviewer_libretro' basic_build || \
      echo 'InstancingViewer not fetched, skipping...'
}

build_libretro_scummvm() {
   cd "${BASE_DIR}/libretro-scummvm/backends/platform/libretro/build" > /dev/null 2>&1 && \
      CORE_TARGET='scummvm_libretro' basic_build || \
      echo 'ScummVM not fetched, skipping...'
}

build_libretro_dosbox() {
   cd "${BASE_DIR}/libretro-dosbox" > /dev/null 2>&1 && \
      CORE_TARGET='dosbox_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'DOSbox not fetched, skipping...'
}

build_libretro_bsnes() {
   cd "${BASE_DIR}/libretro-bsnes/perf/higan" > /dev/null 2>&1 && \
      echo '=== Building bSNES: performance ===' && rm -f obj/*.{o,"${FORMAT_EXT}"} && \
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" compiler="$CC" ui='target-libretro' profile='performance' "-j${JOBS}" || die 'Failed to build bSNES performance core' && \
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_libretro_performance.${FORMAT_EXT}" || echo 'bSNES performance not fetched, skipping...'

   cd "${BASE_DIR}/libretro-bsnes/balanced" > /dev/null 2>&1 && \
      echo '=== Building bSNES: balanced ===' && rm -f obj/*.{o,"${FORMAT_EXT}"} && \
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" compiler="$CC" ui='target-libretro' profile='balanced' "-j${JOBS}" || die 'Failed to build bSNES balanced core' && \
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_libretro_balanced.${FORMAT_EXT}" || echo 'bSNES compat not fetched, skipping...'

   cd "${BASE_DIR}/libretro-bsnes/higan" > /dev/null 2>&1 && \
      echo '=== Building bSNES: accuracy ===' && rm -f obj/*.{o,"${FORMAT_EXT}"}
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" compiler="$CC" ui='target-libretro' profile='accuracy' "-j${JOBS}" || die 'Failed to build bSNES accuracy core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_libretro_accuracy.${FORMAT_EXT}" || echo 'bSNES not fetched, skipping...'
}

build_libretro_bnes() {
   cd "${BASE_DIR}/libretro-bnes" > /dev/null 2>&1 && \
      echo "=== Building bNES ===" && mkdir -p obj && \
      "${MAKE}" "-j${JOBS}" clean || die 'Failed to clean bNES' && \
      "${MAKE}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build bNES' && \
      cp "libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bnes_libretro.${FORMAT_EXT}" || \
      echo 'bNES not fetched, skipping...'
}

build_libretro_mupen64() {
   cd "${BASE_DIR}/libretro-mupen64plus" > /dev/null 2>&1 && \
      echo "=== Building Mupen64Plus ===" && check_opengl && mkdir -p obj && \
      "${MAKE}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64' && \
      "${MAKE}" "${COMPILER}" "-j${JOBS}" || die 'Failed to build Mupen 64' && \
      cp "mupen64plus_libretro${FORMAT}.${FORMAT_EXT}" "$RARCH_DIST_DIR" || \
      echo 'Mupen64 Plus not fetched, skipping...'
}

build_libretro_picodrive() {
   cd "${BASE_DIR}/libretro-picodrive" > /dev/null 2>&1 && \
      CORE_TARGET='picodrive_libretro' CORE_MAKEFILE='-f Makefile.libretro' basic_build || \
      echo 'Picodrive not fetched, skipping...'
}

[[ ! -d "${RARCH_DIST_DIR}" ]] && mkdir -p "${RARCH_DIST_DIR}" || echo "Specified '${RARCH_DIST_DIR}' already exists..."
