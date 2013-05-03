#!/bin/sh

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/pc

if [ -z "$1" ]; then
   LIBRETRO_DIR="/usr/local/lib/libretro"
else
   LIBRETRO_DIR="$1"
fi

if [ ! -d "$LIBRETRO_DIR" ]; then
   mkdir -p "$LIBRETRO_DIR"
fi

for lib in "$RARCH_DIST_DIR"/*
do
   if [ -f $lib ]; then
      install -v -m644 $lib "$LIBRETRO_DIR"
   else
      echo "Library $lib not found, skipping ..."
   fi
done

