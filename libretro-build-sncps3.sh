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

# The SNC PS3 build rules have all been moved to libretro-build.sh

if [[ -z "$1" ]]; then
WANT_CORES=" \
	2048
	snes9x_next \
	gambatte \
	prboom \
	vba_next \
	vecx"
else
WANT_CORES="$@"
fi

platform=sncps3 ${BASE_DIR}/libretro-build.sh ${WANT_CORES}
