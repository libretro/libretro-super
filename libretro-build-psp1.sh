#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
WORKDIR="$PWD"
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/psp1
FORMAT=_psp1
FORMAT_COMPILER_TARGET=psp1
FORMAT_COMPILER_TARGET_ALT=psp1
FORMAT_EXT=a
JOBS=7
MAKE=make

. "$BASE_DIR/libretro-build-common.sh"

if [ $1 ]; then
	$1
else
	libretro_build_core 2048
	libretro_build_core bluemsx
	libretro_build_core fceumm
	libretro_build_core fmsx
	libretro_build_core gambatte
	libretro_build_core genesis_plus_gx
	libretro_build_core handy
	#libretro_build_core mame078
	libretro_build_core mednafen
	libretro_build_core mednafen_bsnes
	libretro_build_core mednafen_gba
	libretro_build_core mednafen_lynx
	libretro_build_core mednafen_ngp
	libretro_build_core mednafen_pce_fast
	libretro_build_core mednafen_pcfx
	libretro_build_core mednafen_supergrafx
	libretro_build_core mednafen_vb
	libretro_build_core mednafen_wswan
	libretro_build_core nestopia
	libretro_build_core nxengine
	libretro_build_core o2em
	libretro_build_core picodrive
	libretro_build_core prboom
	libretro_build_core prosystem
	libretro_build_core quicknes
	libretro_build_core snes9x_next
	libretro_build_core stella
	libretro_build_core tgbdual
	libretro_build_core tyrquake
	libretro_build_core vba_next
	libretro_build_core vecx

	build_libretro_fba_cps2
fi
