#!/bin/sh

ARCH_EXT="$1"

SCRIPT=$(readlink -f "$0")
BASE_DIR=$(dirname "$SCRIPT")
RARCH_DIR="$BASE_DIR/dist"
RARCH_DIST_DIR="$RARCH_DIR/windows"

cd "$RARCH_DIST_DIR"
for file in *.dll
do
   REGEX_MV="s|^\(.*\)\.dll$|\1-${ARCH_EXT}.dll|"
   REGEX="s|^\(.*\)\.dll$|\1-${ARCH_EXT}.zip|"
   FILENAME="`echo $file | sed -e $REGEX_MV`"
   mv -v "$file" "$FILENAME"
   zip "`echo $file | sed -e $REGEX`" "$FILENAME"
   rm -f "$FILENAME"
done

