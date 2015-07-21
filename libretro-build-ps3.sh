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

# The PS3 build rules have all been moved to libretro-build.sh

if [[ -z "$1" ]]; then
WANT_CORES=" \
	fb_alpha \
	fceumm  \
	genesis_plus_gx \
	handy \
	mame078 \
	mednafen_gba \
	mednafen_lynx \
	mednafen_ngp \
	mednafen_pce_fast \
	mednafen_pcfx \
	mednafen_psx \
	mednafen_supergrafx \
	mednafen_vb \
	nestopia \
	nxengine \
	quicknes \
	stella \
	tyrquake \
	gw \
	mgba"
else
WANT_CORES="$@"
fi

platform=ps3 ${BASE_DIR}/libretro-build.sh ${WANT_CORES}
