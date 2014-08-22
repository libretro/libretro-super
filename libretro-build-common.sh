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

build_libretro_bsnes_cplusplus98() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-cplusplus98' ]; then
      echo '=== Building bSNES C++98 ==='
      cd libretro-bsnes-cplusplus98

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" clean || die 'Failed to clean bSNES C++98'
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}"
      cp "out/libretro.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_cplusplus98_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES C++98 not fetched, skipping ...'
   fi
}

build_libretro_ffmpeg() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-ffmpeg' ]; then
      echo '=== Checking OpenGL dependencies ==='
      echo '=== Building FFmpeg ==='
      cd libretro-ffmpeg
      cd libretro
      
      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean FFmpeg'
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}"
      cp "ffmpeg_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'FFmpeg not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_fba_full() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-fba' ]; then
		echo '=== Building Final Burn Alpha (Full) ==='
      cd libretro-fba/
      cd svn-current/trunk

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Final Burn Alpha'
      fi
      "${MAKE}" -f makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Final Burn Alpha'
      cp "fb_alpha_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Final Burn Alpha not fetched, skipping ...'
   fi
}

build_libretro_fba_cps1()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (CPS1) ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd fbacores/cps1

      if [ -z "${NOCLEAN}" ]; then
         make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS1"
      fi
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS1"
      cp fba_cores_cps1_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_cps1_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_fba_cps2()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (CPS2) ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd fbacores/cps2

      if [ -z "${NOCLEAN}" ]; then
         make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS2"
      fi
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS2"
      cp fba_cores_cps2_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_cps2_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_fba_neogeo()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (NeoGeo) ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd fbacores/neogeo

      if [ -z "${NOCLEAN}" ]; then
         make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores NeoGeo"
      fi
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores NeoGeo"
      cp fba_cores_neo_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_neo_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_pcsx_rearmed() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-pcsx-rearmed' ]; then
      echo '=== Building PCSX ReARMed ==='
      cd libretro-pcsx-rearmed

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean PCSX ReARMed'
      fi
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build PCSX ReARMed'
      cp "pcsx_rearmed_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'PCSX ReARMed not fetched, skipping ...'
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

build_libretro_beetle_snes()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-bsnes' ]; then
      echo '=== Building Beetle bSNES ==='
      cd libretro-beetle-bsnes
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/bsnes"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/bsnes"
      cp "mednafen_snes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle bSNES not fetched, skipping ...'
   fi
}

build_libretro_beetle_lynx()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-lynx' ]; then
      echo '=== Building Beetle Lynx ==='
      cd libretro-beetle-lynx
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/lynx"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/lynx"
      cp "mednafen_lynx_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle Lynx not fetched, skipping ...'
   fi
}

build_libretro_beetle_wswan()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-wswan' ]; then
      echo '=== Building Beetle WSwan ==='
      cd libretro-beetle-wswan
      if [ -z "${NOCLEAN}" ]; then
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/wswan"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/wswan"
      cp "mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle WSwan not fetched, skipping ...'
   fi
}

build_libretro_beetle_gba()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-gba' ]; then
      echo '=== Building Beetle GBA ==='
      cd libretro-beetle-gba
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/gba"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/gba"
      cp "mednafen_gba_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle GBA not fetched, skipping ...'
   fi
}

build_libretro_beetle_ngp()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-ngp' ]; then
      echo '=== Building Beetle NGP ==='
      cd libretro-beetle-ngp
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/ngp"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/ngp"
      cp "mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle NGP not fetched, skipping ...'
   fi
}

build_libretro_beetle_pce_fast()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-pce-fast' ]; then
      echo '=== Building Beetle PCE Fast ==='
      cd libretro-beetle-pce-fast
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/pce_fast"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/pce_fast"
      cp "mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle PCE Fast not fetched, skipping ...'
   fi
}

build_libretro_beetle_supergrafx()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-supergrafx' ]; then
      echo '=== Building Beetle SuperGrafx ==='
      cd libretro-beetle-supergrafx
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/supergrafx"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/supergrafx"
      cp "mednafen_supergrafx_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle SuperGrafx not fetched, skipping ...'
   fi
}

build_libretro_beetle_vb()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-vb' ]; then
      echo '=== Building Beetle VB ==='
      cd libretro-beetle-vb
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean beetle/vb"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build beetle/vb"
      cp "mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle VB not fetched, skipping ...'
   fi
}

build_libretro_beetle_pcfx()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-pcfx' ]; then
      echo '=== Building Beetle PCFX ==='
      cd libretro-beetle-pcfx
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean Beetle/pcfx"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build Beetle/pcfx"
      cp "mednafen_pcfx_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle PCFX not fetched, skipping ...'
   fi
}

build_libretro_beetle_psx()
{
   cd "${BASE_DIR}"
   if [ -d 'libretro-beetle-psx' ]; then
      echo '=== Building Beetle PSX ==='
      cd libretro-beetle-psx
      if [ -z "${NOCLEAN}" ]; then
      	"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die "Failed to clean Beetle/psx"
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die "Failed to build Beetle/psx"
      cp "mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Beetle PSX not fetched, skipping ...'
   fi
}

build_libretro_quicknes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-quicknes' ]; then
      echo '=== Building QuickNES ==='
      cd libretro-quicknes/libretro

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean QuickNES'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build QuickNES'
      cp "quicknes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'QuickNES not fetched, skipping ...'
   fi
}

build_libretro_desmume() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-desmume' ]; then
      echo '=== Building Desmume ==='
      cd libretro-desmume/desmume

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "-j${JOBS}" clean || die 'Failed to clean Desmume'
      fi
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" "-j${JOBS}" || die 'Failed to build Desmume'
      cp "desmume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Desmume not fetched, skipping ...'
   fi
}

build_libretro_snes9x() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-snes9x' ]; then
      echo '=== Building SNES9x ==='
      cd libretro-snes9x/libretro

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean SNES9x'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build SNES9x'
      cp "snes9x_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'SNES9x not fetched, skipping ...'
   fi
}




# $1 is corename
# $2 is Makefile name
# $3 is preferred platform
build_libretro_generic_makefile_rootdir() {
   cd "${BASE_DIR}"
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ==="
      cd libretro-${1}/

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f ${2} platform="${3}" ${COMPILER} "-j${JOBS}" clean || die "Failed to build ${1}"
      fi
      "${MAKE}" -f ${2} platform="${3}" ${COMPILER} "-j${JOBS}" || die "Failed to build ${1}"
      cp "${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo "${1} not fetched, skipping ..."
   fi
}

build_libretro_prosystem() {
   build_libretro_generic_makefile_rootdir "prosystem" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_o2em() {
   build_libretro_generic_makefile_rootdir "o2em" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_virtualjaguar() {
   build_libretro_generic_makefile_rootdir "virtualjaguar" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tgbdual() {
   build_libretro_generic_makefile_rootdir "tgbdual" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nx() {
   build_libretro_generic_makefile_rootdir "nxengine" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_picodrive() {
   build_libretro_generic_makefile_rootdir "picodrive" "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tyrquake() {
   build_libretro_generic_makefile_rootdir "tyrquake" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_2048() {
   build_libretro_generic_makefile_rootdir "2048" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vecx() {
   build_libretro_generic_makefile_rootdir "vecx" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_stella() {
   build_libretro_generic_makefile_rootdir "stella" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_bluemsx() {
   build_libretro_generic_makefile_rootdir "bluemsx" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_handy() {
   build_libretro_generic_makefile_rootdir "handy" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fmsx() { 
   build_libretro_generic_makefile_rootdir "fmsx" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vba_next() {
   build_libretro_generic_makefile_rootdir "vba_next" "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_snes9x_next() {
   build_libretro_generic_makefile_rootdir "snes9x_next" "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_dinothawr() {
   build_libretro_generic_makefile_rootdir "dinothawr" "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_genplus() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-genplus' ]; then
      echo '=== Building Genplus GX ==='
      cd libretro-genplus/

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Genplus GX'
      fi
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Genplus GX'
      cp "genesis_plus_gx_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Genplus GX not fetched, skipping ...'
   fi
}

build_libretro_mame078() {
   build_libretro_generic_makefile_rootdir "mame078" "makefile"
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
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="osx" ${COMPILER} "NATIVE=1" buildtools "-j${JOBS}" || die 'Failed to build MAME buildtools'
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

build_libretro_vbam() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-vbam' ]; then
      echo '=== Building VBA-M ==='
      cd libretro-vbam/src/libretro

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean VBA-M'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build VBA-M'
      cp "vbam_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'VBA-M not fetched, skipping ...'
   fi
}


build_libretro_fceumm() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-fceumm' ]; then
      echo '=== Building FCEUmm ==='
      cd libretro-fceumm

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean FCEUmm'
      fi
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build FCEUmm'
      cp "fceumm_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'FCEUmm not fetched, skipping ...'
   fi
}

build_libretro_gambatte() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-gambatte' ]; then
      echo '=== Building Gambatte ==='
      cd libretro-gambatte/libgambatte

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Gambatte'
      fi
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Gambatte'
      cp "gambatte_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Gambatte not fetched, skipping ...'
   fi
}


build_libretro_prboom() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-prboom' ]; then
      echo '=== Building PRBoom ==='
      cd libretro-prboom

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean PRBoom'
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build PRBoom'
      cp "prboom_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'PRBoom not fetched, skipping ...'
   fi
}


build_libretro_meteor() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-meteor' ]; then
      echo '=== Building Meteor ==='
      cd libretro-meteor/libretro

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Meteor'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Meteor'
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

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Nestopia'
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Nestopia'
      cp "nestopia_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Nestopia not fetched, skipping ...'
   fi
}


build_libretro_modelviewer() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-modelviewer' ]; then
      echo '=== Building Modelviewer (GL) ==='
      cd libretro-gl-modelviewer

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Modelviewer'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Modelviewer'
      cp "modelviewer_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'ModelViewer not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_modelviewer_location() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-modelviewer-location' ]; then
      echo '=== Building Modelviewer Location (GL) ==='
      cd libretro-gl-modelviewer-location

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Modelviewer Location'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Modelviewer Location'
      cp "modelviewer_location_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'ModelViewer Location not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_3dengine() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-3dengine' ]; then
      echo '=== Building 3DEngine (GL) ==='
      cd libretro-3dengine

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean SceneWalker'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build SceneWalker'
      cp "3dengine_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo '3DEngine not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_scenewalker() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-scenewalker' ]; then
      echo '=== Building SceneWalker (GL) ==='
      cd libretro-gl-scenewalker

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean SceneWalker'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build SceneWalker'
      cp "scenewalker_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'SceneWalker not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_instancingviewer() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-instancingviewer' ]; then
      echo '=== Building Instancing Viewer (GL) ==='
      cd libretro-gl-instancingviewer

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean InstancingViewer'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build InstancingViewer'
      cp "instancingviewer_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'InstancingViewer not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_instancingviewer_camera() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-gl-instancingviewer-camera' ]; then
      echo '=== Building Instancing Viewer Camera (GL) ==='
      cd libretro-gl-instancingviewer-camera

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean InstancingViewer-Camera'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build InstancingViewer-Camera'
      cp "instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'InstancingViewer Camera not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_scummvm() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-scummvm' ]; then
      echo '=== Building ScummVM ==='
      cd libretro-scummvm/backends/platform/libretro/build

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean ScummVM'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build ScummVM'
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
      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean DOSbox'
      fi
      "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build DOSbox'
      cp "dosbox_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'DOSbox not fetched, skipping ...'
   fi
}

build_libretro_bsnes_mercury() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-mercury/perf' ]; then
      echo '=== Building bSNES Mercury performance ==='
      cd libretro-bsnes-mercury/perf
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='performance' "-j${JOBS}" || die 'Failed to build bSNES Mercury performance core'
      cp -f "out/bsnes_mercury_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_mercury_performance_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES Mercury performance not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-mercury/balanced' ]; then
      echo '=== Building bSNES Mercury balanced ==='
      cd libretro-bsnes-mercury/balanced
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='balanced' "-j${JOBS}" || die 'Failed to build bSNES Mercury balanced core'
      cp -f "out/bsnes_mercury_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_mercury_balanced_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES Mercury compat not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-mercury' ]; then
      echo '=== Building bSNES Mercury accuracy ==='
      cd libretro-bsnes-mercury
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='accuracy' "-j${JOBS}" || die 'Failed to build bSNES Mercury accuracy core'
      cp -f "out/bsnes_mercury_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_mercury_accuracy_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES Mercury accuracy not fetched, skipping ...'
   fi
}

build_libretro_bsnes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes/perf' ]; then
      echo '=== Building bSNES performance ==='
      cd libretro-bsnes/perf
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='performance' "-j${JOBS}" || die 'Failed to build bSNES performance core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_performance_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES performance not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes/balanced' ]; then
      echo '=== Building bSNES balanced ==='
      cd libretro-bsnes/balanced
      
      if [ -z "${NOCLEAN}" ]; then
      	rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='balanced' "-j${JOBS}" || die 'Failed to build bSNES balanced core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_balanced_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES compat not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes' ]; then
      echo '=== Building bSNES accuracy ==='
      cd libretro-bsnes
      if [ -z "${NOCLEAN}" ]; then
      	rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='accuracy' "-j${JOBS}" || die 'Failed to build bSNES accuracy core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_accuracy_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES accuracy not fetched, skipping ...'
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


build_libretro_ppsspp() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-ppsspp' ]; then
      echo '=== Building PPSSPP ==='
      cd libretro-ppsspp/libretro

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean PPSSPP'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build PPSSPP'
      cp "ppsspp_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'PPSSPP not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_yabause() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-yabause' ]; then
      echo '=== Building Yabause ==='
      cd libretro-yabause/libretro

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Yabause'
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Yabause'
      cp "yabause_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Yabause not fetched, skipping ...'
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
