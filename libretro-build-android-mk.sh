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



# $1 is core name
# $2 is subdir (if there's no subdir, put "." here)
build_libretro_generic_makefile()
{
   cd $BASE_DIR
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ==="
      cd libretro-${1}
      cd ${2}
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
   build_libretro_generic_makefile "2048" "jni"
}

build_libretro_stella() {
   build_libretro_generic_makefile "stella" "jni"
}

build_libretro_genesis_plus_gx() {
   build_libretro_generic_makefile "genesis_plus_gx" "libretro/jni"
}

build_libretro_vba_next() {
   build_libretro_generic_makefile "vba_next" "libretro/jni"
}

build_libretro_vbam() {
   build_libretro_generic_makefile "vbam" "src/libretro/jni"
}

build_libretro_catsfc() {
   build_libretro_generic_makefile "catsfc" "jni"
}

build_libretro_snes9x() {
   build_libretro_generic_makefile "snes9x" "libretro/jni"
}

build_libretro_snes9x_next() {
   build_libretro_generic_makefile "snes9x_next" "libretro/jni"
}

build_libretro_beetle_bsnes() {
   build_libretro_generic_makefile "mednafen_snes" "jni"
}

build_libretro_beetle_lynx() {
   build_libretro_generic_makefile "mednafen_lynx" "jni"
}

build_libretro_beetle_gba() {
   build_libretro_generic_makefile "mednafen_gba" "jni"
}

build_libretro_beetle_ngp() {
   build_libretro_generic_makefile "mednafen_ngp" "jni"
}

build_libretro_beetle_wswan() {
   build_libretro_generic_makefile "mednafen_wswan" "jni"
}

build_libretro_beetle_psx() {
   build_libretro_generic_makefile "mednafen_psx" "jni"
}

build_libretro_beetle_pcfx() {
   build_libretro_generic_makefile "mednafen_pcfx" "jni"
}

build_libretro_beetle_vb() {
   build_libretro_generic_makefile "mednafen_vb" "jni"
}

build_libretro_beetle_pce_fast() {
   build_libretro_generic_makefile "mednafen_pce_fast" "jni"
}

build_libretro_beetle_supergrafx() {
   build_libretro_generic_makefile "mednafen_supergrafx" "jni"
}

build_libretro_nx() {
   build_libretro_generic_makefile "nxengine" "jni"
}

build_libretro_prboom()
{
   build_libretro_generic_makefile "prboom" "libretro/jni"
}

build_libretro_nestopia() {
   build_libretro_generic_makefile "nestopia" "libretro/jni"
}

build_libretro_tyrquake() {
   build_libretro_generic_makefile "tyrquake" "libretro/jni"
}

build_libretro_pcsx_rearmed() {
   build_libretro_generic_makefile "pcsx_rearmed" "jni"
}


build_libretro_picodrive() {
   build_libretro_generic_makefile "picodrive" "jni"
}

build_libretro_quicknes() {
   build_libretro_generic_makefile "quicknes" "libretro/jni"
}

build_libretro_handy() {
   build_libretro_generic_makefile "handy" "libretro/jni"
}

build_libretro_yabause() {
   build_libretro_generic_makefile "yabause" "libretro/jni"
}

build_libretro_vecx() {
   build_libretro_generic_makefile "vecx" "libretro/jni"
}

build_libretro_mupen64()
{
   build_libretro_generic_makefile "mupen64plus" "libretro/jni"
}

build_libretro_3dengine() {
   build_libretro_generic_makefile "3dengine" "jni"
}

build_libretro_fceumm() {
   build_libretro_generic_makefile "fceumm" "src/drivers/libretro/jni"
}

build_libretro_gambatte() {
   build_libretro_generic_makefile "gambatte" "libgambatte/libretro/jni"
}


build_libretro_dinothawr() {
   build_libretro_generic_makefile "dinothawr" "android/eclipse/jni"
}

build_libretro_virtualjaguar() {
   build_libretro_generic_makefile "virtualjaguar" "jni"
}

build_libretro_desmume() {
   build_libretro_generic_makefile "desmume" "desmume/src/libretro/jni"
}

build_libretro_fb_alpha() {
   build_libretro_generic_makefile "fb_alpha" "svn-current/trunk/projectfiles/libretro-android/jni"
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
      cd target-libretro/jni
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
   #build_libretro_4do
   #build_libretro_bluemsx
   #build_libretro_fmsx
   #build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   #build_libretro_bsnes_mercury
   build_libretro_beetle_lynx
   #build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_psx
   #build_libretro_beetle_bsnes
   build_libretro_catsfc
   build_libretro_snes9x
   build_libretro_snes9x_next
   build_libretro_genesis_plus_gx
   build_libretro_fb_alpha
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
   build_libretro_yabause
   build_libretro_vecx
   #build_libretro_tgbdual
   #build_libretro_prosystem
   build_libretro_dinothawr
   build_libretro_virtualjaguar
   build_libretro_mupen64
   #build_libretro_ffmpeg
   build_libretro_3dengine
   #build_libretro_ppsspp
   #build_libretro_o2em
fi
