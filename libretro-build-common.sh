#!/bin/bash

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
[[ "${IOS}" ]] && echo '=== iOS =='

echo "${FORMAT_COMPILER_TARGET}"
echo "${FORMAT_COMPILER_TARGET_ALT}"

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

build_libretro_pcsx_rearmed_interpreter() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-pcsx-rearmed' ]; then
      echo '=== Building PCSX ReARMed Interpreter ==='
      cd libretro-pcsx-rearmed

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean PCSX ReARMed'
      fi
      "${MAKE}" -f Makefile.libretro USE_DYNAREC=0 platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build PCSX ReARMed'
      cp "pcsx_rearmed_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/pcsx_rearmed_interpreter${FORMAT}.${FORMAT_EXT}"
   else
      echo 'PCSX ReARMed not fetched, skipping ...'
   fi
}

# $1 is corename
# $2 is subcorename
# $3 is subdir. In case there is no subdir, enter "." here
# $4 is Makefile name
# $5 is preferred platform
build_libretro_generic_makefile_subcore() {
   cd $BASE_DIR
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${2} ==="
      cd libretro-${1}/
      cd ${3}

      if [ -z "${NOCLEAN}" ]; then
         make -f ${4} platform=${5} -j$JOBS clean || die "Failed to clean ${2}"
      fi
      make -f ${4} platform=${5} -j$JOBS || die "Failed to build ${2}"
      cp ${2}_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/${2}_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_fba_cps2() {
   build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps2" "svn-current/trunk/fbacores/cps2" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fba_neogeo() {
   build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_neo" "svn-current/trunk/fbacores/neogeo" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fba_cps1() {
   build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps1" "svn-current/trunk/fbacores/cps1" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

# $1 is corename
# $2 is subdir. In case there is no subdir, enter "." here
# $3 is Makefile name
# $4 is preferred platform
build_libretro_generic_makefile() {
   cd "${BASE_DIR}"
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ==="
      cd libretro-${1}
      cd ${2}

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f ${3} platform="${4}" ${COMPILER} "-j${JOBS}" clean || die "Failed to build ${1}"
      fi
      "${MAKE}" -f ${3} platform="${4}" ${COMPILER} "-j${JOBS}" || die "Failed to build ${1}"
      cp "${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo "${1} not fetched, skipping ..."
   fi
}

build_libretro_prosystem() {
   build_libretro_generic_makefile "prosystem" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_4do() {
   build_libretro_generic_makefile "4do" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_o2em() {
   build_libretro_generic_makefile "o2em" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_virtualjaguar() {
   build_libretro_generic_makefile "virtualjaguar" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tgbdual() {
   build_libretro_generic_makefile "tgbdual" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nx() {
   build_libretro_generic_makefile "nxengine" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_picodrive() {
   build_libretro_generic_makefile "picodrive" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tyrquake() {
   build_libretro_generic_makefile "tyrquake" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_2048() {
   build_libretro_generic_makefile "2048" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vecx() {
   build_libretro_generic_makefile "vecx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_stella() {
   build_libretro_generic_makefile "stella" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_bluemsx() {
   build_libretro_generic_makefile "bluemsx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_handy() {
   build_libretro_generic_makefile "handy" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fmsx() { 
   build_libretro_generic_makefile "fmsx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vba_next() {
   build_libretro_generic_makefile "vba_next" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_vbam() {
   build_libretro_generic_makefile "vbam" "src/libretro" "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_snes9x_next() {
   build_libretro_generic_makefile "snes9x_next" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_dinothawr() {
   build_libretro_generic_makefile "dinothawr" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_genesis_plus_gx() {
   build_libretro_generic_makefile "genesis_plus_gx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_mame078() {
   build_libretro_generic_makefile "mame078" "." "makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_prboom() {
   build_libretro_generic_makefile "prboom" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_pcsx_rearmed() {
   build_libretro_generic_makefile "pcsx_rearmed" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fceumm() {
   build_libretro_generic_makefile "fceumm" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_snes() {
   build_libretro_generic_makefile "mednafen_snes" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_lynx() {
   build_libretro_generic_makefile "mednafen_lynx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_wswan() {
   build_libretro_generic_makefile "mednafen_wswan" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_gba() {
   build_libretro_generic_makefile "mednafen_gba" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_ngp() {
   build_libretro_generic_makefile "mednafen_ngp" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_pce_fast() {
   build_libretro_generic_makefile "mednafen_pce_fast" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_vb() {
   build_libretro_generic_makefile "mednafen_vb" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_pcfx() {
   build_libretro_generic_makefile "mednafen_pcfx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_psx() {
   build_libretro_generic_makefile "mednafen_psx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_supergrafx() {
   build_libretro_generic_makefile "mednafen_supergrafx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_meteor() {
   build_libretro_generic_makefile "meteor" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nestopia() {
   build_libretro_generic_makefile "nestopia" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_gambatte() {
   build_libretro_generic_makefile "gambatte" "libgambatte" "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_yabause() {
   build_libretro_generic_makefile "yabause" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_desmume() {
   build_libretro_generic_makefile "desmume" "desmume" "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_snes9x() {
   build_libretro_generic_makefile "snes9x" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_quicknes() {
   build_libretro_generic_makefile "quicknes" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_dosbox() {
   build_libretro_generic_makefile "dosbox" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fb_alpha() {
   build_libretro_generic_makefile "fb_alpha" "svn-current/trunk" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_ffmpeg() {
   check_opengl
   build_libretro_generic_makefile "ffmpeg" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_3dengine() {
   check_opengl
   build_libretro_generic_makefile "3dengine" "." "Makefile" ${FORMAT_COMPILER_TARGET}
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_scummvm() {
   build_libretro_generic_makefile "scummvm" "backends/platform/libretro/build" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_ppsspp() {
   check_opengl
   build_libretro_generic_makefile "ppsspp" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}


build_libretro_mame() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MAME ==='
      cd libretro-mame

      if [ "$IOS" ]; then
        echo '=== Building MAME (iOS) ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "NATIVE=1" buildtools "-j${JOBS}" || die 'Failed to build MAME buildtools'
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} emulator "-j${JOBS}" || die 'Failed to build MAME (iOS)'
      elif [ "$X86_64" = "true" ]; then
        echo '=== Building MAME64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building MAME32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "mame_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

build_libretro_mess() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MESS ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building MESS64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building MESS32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "mess_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

rebuild_libretro_mess() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MESS ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building MESS64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building MESS32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mess" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "mess_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

build_libretro_ume() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building UME ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building UME64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building UME32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
	fi
        "${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "ume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

rebuild_libretro_ume() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MESS ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building UME64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building UME32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=ume" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "ume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

# $1 is corename
# $2 is profile shortname.
# $3 is profile name
# $4 is compiler
build_libretro_bsnes_modern() {
   cd "${BASE_DIR}"
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ${3} ==="
      cd libretro-${1}
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${4}" ui='target-libretro' profile="${3}" "-j${JOBS}" || die "Failed to build ${1} ${3} core"
      cp -f "out/${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${1}_${3}_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo "${1} ${3} not fetched, skipping ..."
   fi
}

build_libretro_bsnes() {
   build_libretro_bsnes_modern "bsnes" "perf" "performance" ${CXX11}
   build_libretro_bsnes_modern "bsnes" "balanced" "balanced" ${CXX11}
   build_libretro_bsnes_modern "bsnes" "." "accuracy" ${CXX11}
}

build_libretro_bsnes_mercury() {
   build_libretro_bsnes_modern "bsnes_mercury" "perf" "performance" ${CXX11}
   build_libretro_bsnes_modern "bsnes_mercury" "balanced" "balanced" ${CXX11}
   build_libretro_bsnes_modern "bsnes_mercury" "." "accuracy" ${CXX11}
}

build_libretro_bsnes_cplusplus98() {
   CORENAME="bsnes_cplusplus98"
   cd "${BASE_DIR}"
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" clean || die "Failed to clean ${CORENAME}"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}"
      cp "out/libretro.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}

build_libretro_bnes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bnes' ]; then
      echo '=== Building bNES ==='
      cd libretro-bnes

      mkdir -p obj
      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile "-j${JOBS}" clean || die 'Failed to clean bNES'
      fi
      "${MAKE}" -f Makefile ${COMPILER} "-j${JOBS}" compiler="${CXX11}" || die 'Failed to build bNES'
      cp "libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bnes_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bNES not fetched, skipping ...'
   fi
}

build_libretro_mupen64() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-mupen64plus' ]; then
      cd libretro-mupen64plus

      mkdir -p obj
      if [ "${X86}" ] && [ "${X86_64}" ]; then
         echo '=== Building Mupen 64 Plus (x86_64 dynarec) ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" WITH_DYNAREC='x86_64' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86_64 dynarec)'
         fi
         "${MAKE}" WITH_DYNAREC='x86_64' platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64 (x86_64 dynarec)'
      elif [ "${X86}" ]; then
         echo '=== Building Mupen 64 Plus (x86 32bit dynarec) ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" WITH_DYNAREC='x86' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86 dynarec)'
         fi
         "${MAKE}" WITH_DYNAREC='x86' platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64 (x86 dynarec)'
      elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "${IOS}" ]; then
         echo '=== Building Mupen 64 Plus (ARM dynarec) ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" WITH_DYNAREC='arm' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (ARM dynarec)'
         fi
	 "${MAKE}" WITH_DYNAREC='arm' platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64 (ARM dynarec)'
      else
         echo '=== Building Mupen 64 Plus ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64'
         fi
	 "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64'
      fi
      cp "mupen64plus_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Mupen64 Plus not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

create_dist_dir() {
   if [ -d "${RARCH_DIST_DIR}" ]; then
      echo "Directory ${RARCH_DIST_DIR} already exists, skipping creation..."
   else
      mkdir -p "${RARCH_DIST_DIR}"
   fi
}

create_dist_dir
