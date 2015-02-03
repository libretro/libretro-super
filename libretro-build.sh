#! /bin/bash
# vi: sw=3 ts=3 et

# BSDs don't have readlink -f
read_link()
{
   TARGET_FILE="${1}"
   cd "`dirname "${TARGET_FILE}"`"
   TARGET_FILE="`basename "${TARGET_FILE}"`"

   while [ -L "${TARGET_FILE}" ]; do
      TARGET_FILE="`readlink "${TARGET_FILE}"`"
      cd "`dirname "${TARGET_FILE}"`"
      TARGET_FILE="`basename "${TARGET_FILE}"`"
   done

   PHYS_DIR="`pwd -P`"
   RESULT="${PHYS_DIR}/${TARGET_FILE}"
   echo ${RESULT}
}
SCRIPT="`read_link "$0"`"
BASE_DIR="`dirname "${SCRIPT}"`"
WORKDIR="`pwd`"

. ${BASE_DIR}/libretro-config.sh
. ${BASE_DIR}/libretro-build-common.sh

mkdir -p "$RARCH_DIST_DIR"

if [ -n "${1}" ]; then
   NOBUILD_SUMMARY=1
   while [ -n "${1}" ]; do
      "${1}"
      shift
   done
else
   build_libretro_2048
   build_libretro_4do
   build_libretro_bluemsx
   build_libretro_fmsx
   build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   build_libretro_bsnes_mercury
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_mednafen_psx
   build_libretro_beetle_snes
   build_libretro_catsfc
   build_libretro_snes9x
   build_libretro_snes9x_next
   build_libretro_genesis_plus_gx
   build_libretro_fb_alpha
   build_libretro_vbam
   build_libretro_vba_next
   build_libretro_bnes
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_meteor
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_mame078
   build_libretro_mame
   build_libretro_dosbox
   build_libretro_scummvm
   build_libretro_picodrive
   build_libretro_handy
   build_libretro_desmume
   if [ $FORMAT_COMPILER_TARGET != "win" ]; then
      build_libretro_pcsx_rearmed
   fi
   build_libretro_yabause
   build_libretro_vecx
   build_libretro_tgbdual
   build_libretro_prosystem
   build_libretro_dinothawr
   build_libretro_virtualjaguar
   build_libretro_mupen64
   build_libretro_ffmpeg
   build_libretro_3dengine
   build_libretro_ppsspp
   build_libretro_o2em
   build_libretro_hatari
   build_libretro_gpsp
   build_libretro_emux
   build_summary
fi

