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

if [[ -z "$1" ]]; then
WANT_CORES=" \
	81 \
	fbalpha2012 \
	fceumm  \
	fuse \
	genesis_plus_gx \
	handy \
	mame2000 \
	mame2003 \
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
	prosystem \
	prboom \
	stella \
	tyrquake \
	vba_next \
	gw \
	mgba"
else
WANT_CORES="$@"
fi

platform=ps3 ${BASE_DIR}/libretro-build.sh ${WANT_CORES}
