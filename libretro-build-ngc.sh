#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR="$PWD"

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
else
	if [[ "$0" != /* ]]; then
		# Make the path absolute
		BASE_DIR="$WORKDIR/$BASE_DIR"
	fi
fi

RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/ngc
FORMAT=_ngc
FORMAT_COMPILER_TARGET=ngc
FORMAT_COMPILER_TARGET_ALT=ngc
FORMAT_EXT=a
JOBS=7
MAKE=make

. "$BASE_DIR/libretro-build-common-gx.sh"
. "$BASE_DIR/libretro-build-common.sh"

if [ $1 ]; then
	$1
else
	libretro_build_core bluemsx
	libretro_build_core fceumm
	libretro_build_core fmsx
	libretro_build_core gambatte
	libretro_build_core genesis_plus_gx
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
	libretro_build_core prboom
	libretro_build_core quicknes
	libretro_build_core snes9x_next
	libretro_build_core tyrquake
	libretro_build_core vba_next
	#libretro_build_core yabause

	build_libretro_fba # not in libretro-build-common!
fi
