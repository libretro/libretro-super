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

. "$BASE_DIR/libretro-config.sh" config_platform

RARCH_DIR="$BASE_DIR/dist"
RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"

if [ -z "$1" ]; then
	LIBRETRO_DIR="/usr/local/lib/libretro"
else
	LIBRETRO_DIR="$1"
fi

mkdir -p "$LIBRETRO_DIR"
for lib in "$RARCH_DIST_DIR"/*
do
	if [ -f "$lib" ]; then
		install -v -m 644 "$lib" "$LIBRETRO_DIR"
	else
		echo "Library $lib not found, skipping ..."
	fi
done

for infofile in "$RARCH_DIR"/info/*.info
do
	if [ -f "$infofile" ]; then
		install -v -m 644 "$infofile" "$LIBRETRO_DIR"
	fi
done

