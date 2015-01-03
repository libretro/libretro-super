#!/bin/bash

set -e

BASE_DIR="$PWD"
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/theos_ios
FORMAT=_ios
FORMAT_COMPILER_TARGET=theos_ios
FORMAT_COMPILER_TARGET_ALT=theos_ios
FORMAT_EXT=dylib
JOBS=7
MAKE=make
CXX11="clang++ -std=c++11 -stdlib=libc++ -miphoneos-version-min=5.0"
IOS=1

. ./libretro-build-common.sh

if [ $1 ]; then
   $1
else
   build_libretro_2048
   build_libretro_bluemsx
   build_libretro_fmsx
   #build_libretro_bsnes_cplusplus98
   #build_libretro_bsnes
   #build_libretro_beetle_lynx
   #build_libretro_beetle_gba
   #build_libretro_beetle_ngp
   #build_libretro_beetle_pce_fast
   #build_libretro_beetle_supergrafx
   #build_libretro_beetle_pcfx
   #build_libretro_beetle_vb
   #build_libretro_beetle_wswan
   #build_libretro_mednafen_psx
   #build_libretro_beetle_bsnes
   build_libretro_catsfc
   build_libretro_snes9x
   build_libretro_snes9x_next
   build_libretro_genesis_plus_gx
   build_libretro_fb_alpha
   build_libretro_vbam
   build_libretro_vba_next
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_meteor
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
   #build_libretro_picodrive
   build_libretro_handy
   build_libretro_desmume
   #build_libretro_pcsx_rearmed
   #build_libretro_pcsx_rearmed_interpreter
   #build_libretro_mupen64
   #build_libretro_yabause
   #build_libretro_ffmpeg
   build_libretro_3dengine
   build_libretro_vecx
   build_libretro_tgbdual
   build_libretro_prosystem
   #build_libretro_dinothawr
   build_libretro_virtualjaguar
   build_libretro_o2em
   build_libretro_4do
   build_libretro_gpsp
   #build_libretro_emux
fi
