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
	vba_next \
	2048 \
	prboom \
	reicast \
	snes9x2010"
else
WANT_CORES="$@"
fi

export STATIC_LINKING=1

${BASE_DIR}/libretro-build.sh ${WANT_CORES}
