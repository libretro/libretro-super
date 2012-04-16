#!/bin/sh

if [ -z "$1" ]; then
   LIBSNES_DIR="/usr/local/lib/libsnes"
else
   LIBSNES_DIR="$1"
fi

if [ ! -d "$PREFIX/lib/libsnes" ]; then
   mkdir -p "$LIBSNES_DIR"
fi

LIBS=""
LIBS="$LIBS libsnes/libsnes-performance.so"
LIBS="$LIBS libsnes/libsnes-compat.so"
LIBS="$LIBS libsnes/libsnes-accuracy.so"
LIBS="$LIBS libsnes-s9x/libsnes-snes9x.so"
LIBS="$LIBS libsnes-s9x-next/libsnes-snes9x-next.so"
LIBS="$LIBS libsnes-genplus/libsnes-genplus.so"
LIBS="$LIBS libsnes-fba/libsnes-fba.so"
LIBS="$LIBS libsnes-vba/libsnes-vba.so"
LIBS="$LIBS libsnes-fceu/libsnes-fceu.so"
LIBS="$LIBS libsnes-bnes/libsnes-bnes.so"
LIBS="$LIBS libsnes-gambatte/libsnes-gambatte.so"
LIBS="$LIBS libsnes-meteor/libsnes-meteor.so"

for lib in $LIBS
do
   if [ -f $lib ]; then
      install -v -m644 $lib "$LIBSNES_DIR"
   else
      echo "Library $lib not found, skipping ..."
   fi
done

