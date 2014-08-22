#!/bin/bash

. ./libretro-config.sh

#split TARGET_ABI string into an array we can iterate over
IFS=' ' read -ra ABIS <<< "$TARGET_ABIS"

# BSDs don't have readlink -f
read_link()
{
   TARGET_FILE="$1"
   cd $(dirname "$TARGET_FILE")
   TARGET_FILE=$(basename "$TARGET_FILE")

   while [ -L "$TARGET_FILE" ]
   do
      TARGET_FILE=$(readlink "$TARGET_FILE")
      cd $(dirname "$TARGET_FILE")
      TARGET_FILE=$(basename "$TARGET_FILE")
   done

   PHYS_DIR=$(pwd -P)
   RESULT="$PHYS_DIR/$TARGET_FILE"
   echo $RESULT
}

SCRIPT=$(read_link "$0")
echo "Script: $SCRIPT"
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/android
FORMAT=_android
FORMAT_EXT=so

die()
{
   echo $1
   #exit 1
}

build_libretro_fba_full()
{
   CORENAME="fba"
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}
      cd svn-current/trunk
      cd projectfiles/libretro-android/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${CORENAME}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/fb_alpha_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}

build_libretro_vbam()
{
   CORENAME="vbam"
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}/
      cd src/libretro/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${CORENAME}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}

# $1 is core name
build_libretro_generic_makefile_libretrodir()
{
   cd $BASE_DIR
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ==="
      cd libretro-${1}/
      cd libretro/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${1}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${1}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${1} not fetched, skipping ..."
   fi
}

# $1 is core name
build_libretro_generic_makefile_rootdir()
{
   cd $BASE_DIR
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ==="
      cd libretro-${1}
      cd jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${1}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${1}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${1} not fetched, skipping ..."
   fi
}

build_libretro_2048() {
   build_libretro_generic_makefile_rootdir "2048"
}

build_libretro_stella() {
   build_libretro_generic_makefile_rootdir "stella"
}

build_libretro_genesis_plus_gx() {
   build_libretro_generic_makefile_libretrodir "genesis_plus_gx"
}

build_libretro_vba_next() {
   build_libretro_generic_makefile_libretrodir "vba_next"
}

build_libretro_snes9x() {
   build_libretro_generic_makefile_libretrodir "snes9x"
}

build_libretro_snes9x_next() {
   build_libretro_generic_makefile_libretrodir "snes9x_next"
}

build_libretro_beetle_bsnes() {
   build_libretro_generic_makefile_rootdir "mednafen_snes"
}

build_libretro_beetle_lynx() {
   build_libretro_generic_makefile_rootdir "mednafen_lynx"
}

build_libretro_beetle_gba() {
   build_libretro_generic_makefile_rootdir "mednafen_gba"
}

build_libretro_beetle_ngp() {
   build_libretro_generic_makefile_rootdir "mednafen_ngp"
}

build_libretro_beetle_wswan() {
   build_libretro_generic_makefile_rootdir "mednafen_wswan"
}

build_libretro_beetle_psx() {
   build_libretro_generic_makefile_rootdir "mednafen_psx"
}

build_libretro_beetle_pcfx() {
   build_libretro_generic_makefile_rootdir "mednafen_pcfx"
}

build_libretro_beetle_vb() {
   build_libretro_generic_makefile_rootdir "mednafen_vb"
}

build_libretro_beetle_pce_fast() {
   build_libretro_generic_makefile_rootdir "mednafen_pce_fast"
}

build_libretro_beetle_supergrafx() {
   build_libretro_generic_makefile_rootdir "mednafen_supergrafx"
}

build_libretro_fceumm()
{
   CORENAME="fceumm"
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}
      cd src/drivers/libretro/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${CORENAME}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}

build_libretro_gambatte()
{
   CORENAME="gambatte"
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}/
      cd libgambatte/libretro/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${CORENAME}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}

build_libretro_nx() {
   build_libretro_generic_makefile_rootdir "nxengine"
}

build_libretro_prboom()
{
   build_libretro_generic_makefile_libretrodir "prboom"
}

build_libretro_dinothawr()
{
   CORENAME="dinothawr"
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}
      cd android/eclipse/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${CORENAME}"
         cp ../libs/${a}/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}

build_libretro_nestopia() {
   build_libretro_generic_makefile_libretrodir "nestopia"
}

build_libretro_pcsx_rearmed()
{
   build_libretro_generic_makefile_rootdir "pcsx_rearmed"
}

build_libretro_tyrquake() {
   build_libretro_generic_makefile_libretrodir "tyrquake"
}

build_libretro_picodrive() {
   build_libretro_generic_makefile_rootdir "picodrive"
}

build_libretro_quicknes() {
   build_libretro_generic_makefile_libretrodir "quicknes"
}

build_libretro_handy() {
   build_libretro_generic_makefile_libretrodir "handy"
}

build_libretro_yabause() {
   build_libretro_generic_makefile_libretrodir "yabause"
}

build_libretro_mupen64()
{
   build_libretro_generic_makefile_libretrodir "mupen64plus"
}

build_libretro_3dengine() {
   build_libretro_generic_makefile_rootdir "3dengine"
}

build_libretro_desmume()
{
   CORENAME="desmume"
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}/
      cd desmume/src/libretro/jni
      for a in "${ABIS[@]}"; do
         if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${CORENAME}"
         cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
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
   
   for a in "${ABIS[@]}"; do
      if [ -d $RARCH_DIST_DIR/${a} ]; then
         echo "Directory $RARCH_DIST_DIR/${a} already exists, skipping creation..."
      else
         mkdir $RARCH_DIST_DIR/${a}
      fi
   done
}

build_libretro_bsnes()
{
   CORENAME="bsnes"
   #TODO - maybe accuracy/balanced cores as well
   cd $BASE_DIR
   if [ -d "libretro-${CORENAME}" ]; then
      echo "=== Building ${CORENAME} ==="
      cd libretro-${CORENAME}/
      cd perf/target-libretro/jni
      for a in "${ABIS[@]}"; do
        if [ -z "${NOCLEAN}" ]; then
            ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
         fi
         ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build ${a} ${CORENAME}"
         cp ../libs/${a}/libretro_bsnes_performance.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/bsnes_performance_libretro${FORMAT}.${FORMAT_EXT}
      done
   else
      echo "${CORENAME} not fetched, skipping ..."
   fi
}



create_dist_dir

if [ $1 ]; then
   $1
else
   build_libretro_2048
   #build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_psx
   build_libretro_beetle_bsnes
   build_libretro_snes9x
   build_libretro_snes9x_next
   build_libretro_genesis_plus_gx
   build_libretro_fba_full
   build_libretro_vbam
   build_libretro_vba_next
   #build_libretro_bnes
   build_libretro_fceumm
   build_libretro_gambatte
   #build_libretro_meteor
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   #build_libretro_mame078
   #build_libretro_mame
   #build_libretro_dosbox
   #build_libretro_scummvm
   build_libretro_picodrive
   build_libretro_handy
   build_libretro_desmume
   build_libretro_pcsx_rearmed
   build_libretro_mupen64
   #build_libretro_ffmpeg
   build_libretro_yabause
   build_libretro_dinothawr
   build_libretro_3dengine
fi
