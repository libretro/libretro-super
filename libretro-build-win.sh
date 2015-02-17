#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

BASE_DIR=$(pwd)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/win
FORMAT=_win
FORMAT_EXT=dll
MSVC_NAME=msvc-2010
RELEASE_LTCG=Release
RELEASE=Release

die()
{
	echo $1
	#exit 1
}

source $BASE_DIR/libretro-build-common-xdk.sh

if [ $1 ]; then
	$1
else
	#build_libretro_beetle_lynx
	build_libretro_beetle_gba
	build_libretro_beetle_ngp
	build_libretro_beetle_pce_fast
	build_libretro_beetle_supergrafx
	build_libretro_beetle_pcfx
	build_libretro_mednafen_psx
	build_libretro_beetle_vb
	build_libretro_beetle_wswan
	#build_libretro_beetle_bsnes
	build_libretro_snes9x
	build_libretro_snes9x_next
	build_libretro_genesis_plus_gx
	#build_libretro_fb_alpha
	build_libretro_vba_next
	build_libretro_fceumm
	build_libretro_gambatte
	build_libretro_nx
	build_libretro_prboom
	build_libretro_stella
	#build_libretro_quicknes
	build_libretro_nestopia
	build_libretro_tyrquake
	build_libretro_mame078
	build_libretro_picodrive
	#build_libretro_handy
fi
