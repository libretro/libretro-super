#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
WORKDIR="$PWD"
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/qnx
FORMAT=_qnx
FORMAT_COMPILER_TARGET=qnx
FORMAT_COMPILER_TARGET_ALT=qnx
FORMAT_EXT=so
JOBS=7
MAKE=make

CC="qcc -Vgcc_ntoarmv7le"
CXX="QCC -Vgcc_ntoarmv7le"
CXX11="QCC -Vgcc_ntoarmv7le"

. "$BASE_DIR/libretro-build-common.sh"

if [ $1 ]; then
	$1
else
	libretro_build_core 2048
	libretro_build_core 3dengine
	libretro_build_core 4do
	libretro_build_core bluemsx
	#libretro_build_core bnes
	#libretro_build_core bsnes
	libretro_build_core bsnes_cplusplus98
	#libretro_build_core bsnes_mercury
	libretro_build_core catsfc
	#libretro_build_core desmume
	#libretro_build_core dinothawr
	libretro_build_core dosbox
	libretro_build_core fb_alpha
	#libretro_build_core ffmpeg
	libretro_build_core fceumm
	libretro_build_core fmsx
	libretro_build_core gambatte
	libretro_build_core genesis_plus_gx
	libretro_build_core gpsp
	libretro_build_core handy
	#libretro_build_core mame
	libretro_build_core mame078
	libretro_build_core mednafen_gba
	libretro_build_core mednafen_lynx
	libretro_build_core mednafen_pce_fast
	libretro_build_core mednafen_pcfx
	libretro_build_core mednafen_psx
	libretro_build_core mednafen_snes
	libretro_build_core mednafen_supergrafx
	libretro_build_core mednafen_vb
	libretro_build_core mednafen_wswan
	#libretro_build_core meteor
	libretro_build_core mupen64plus
	libretro_build_core nestopia
	libretro_build_core nxengine
	libretro_build_core o2em
	libretro_build_core pcsx_rearmed
	libretro_build_core picodrive
	#libretro_build_core ppsspp
	libretro_build_core prboom
	libretro_build_core prosystem
	libretro_build_core quicknes
	libretro_build_core scummvm
	libretro_build_core snes9x
	libretro_build_core snes9x_next
	libretro_build_core stella
	libretro_build_core tgbdual
	libretro_build_core tyrquake
	libretro_build_core vba_next
	libretro_build_core vbam
	libretro_build_core vecx
	libretro_build_core virtualjaguar
	#libretro_build_core yabause
fi
