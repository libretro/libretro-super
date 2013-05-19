#!/bin/sh

if [ "$platform" ]; then
   if [ "$platform" = "win" ]; then
      DIST_DIR=win
   elif [ "$platform" = "osx" ]; then
      DIST_DIR=osx
   else
      DIST_DIR=unix
   fi
else
   UNAME=$(uname)

   if [ $(echo $UNAME | grep Linux) ]; then
      DIST_DIR=unix
   elif [ $(echo $UNAME | grep BSD) ]; then
      DIST_DIR=bsd
   elif [ $(echo $UNAME | grep Darwin) ]; then
      DIST_DIR=osx
   elif [ $(echo $UNAME | grep -i MINGW) ]; then
      DIST_DIR=win
   else
      DIST_DIR=unix
   fi
fi

# BSDs don't have readlink -f
read_link()
{
   TARGET_FILE="$1"
   cd $(dirname "$TARGET_FILE")
   TARGET_FILE=$(basename "$TARGET_FILE")

   while [ -L "$TARGET_FILE" ]
   do
      TARGET_FILE=$(readlink "$TARGET_FILE")
      cd $(dirname "$TARGET_FILE")
      TARGET_FILE=$(basename "$TARGET_FILE")
   done

   PHYS_DIR=$(pwd -P)
   RESULT="$PHYS_DIR/$TARGET_FILE"
   echo $RESULT
}

SCRIPT=$(read_link "$0")
BASE_DIR=$(dirname "$SCRIPT")
RARCH_DIR="$BASE_DIR/dist"
RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"

if [ -z "$1" ]; then
   LIBRETRO_DIR="/usr/local/lib/libretro"
else
   LIBRETRO_DIR="$1"
fi

for lib in "$RARCH_DIST_DIR"/*
do
   if [ -f "$lib" ]; then
      install -v -m644 "$lib" "$LIBRETRO_DIR"
   else
      echo "Library $lib not found, skipping ..."
   fi
done

