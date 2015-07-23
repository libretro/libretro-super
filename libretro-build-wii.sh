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

# The Wii build rules have all been moved to libretro-build.sh

if [[ -z "$1" ]]; then
WANT_CORES=" \
	2048 \
	bluemsx \
	fceumm  \
	fmsx \
	gambatte \
	genesis_plus_gx \
	mednafen_gba \
	mednafen_lynx \
	mednafen_ngp \
	mednafen_pce_fast \
	mednafen_pcfx \
	mednafen_supergrafx \
	mednafen_wswan \
	mednafen_vb \
	nestopia \
	nxengine \
	quicknes \
	prboom \
	snes9x_next \
	vba_next \
	tyrquake \
	gw \
	mgba \
	fb_alpha_cps1 \
	fb_alpha_cps2 \
	vecx"
else
WANT_CORES="$@"
fi

platform=wii ${BASE_DIR}/libretro-build.sh ${WANT_CORES}
