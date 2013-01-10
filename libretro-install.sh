#!/bin/sh

if [ -z "$1" ]; then
   LIBRETRO_DIR="/usr/local/lib/libretro"
else
   LIBRETRO_DIR="$1"
fi

if [ ! -d "$LIBRETRO_DIR" ]; then
   mkdir -p "$LIBRETRO_DIR"
fi

LIBS=""
LIBS="$LIBS libretro-bsnes/libretro-bsnes-performance.so"
LIBS="$LIBS libretro-bsnes/libretro-bsnes-compat.so"
LIBS="$LIBS libretro-bsnes/libretro-bsnes-accuracy.so"
LIBS="$LIBS libretro-s9x/libretro-snes9x.so"
LIBS="$LIBS libretro-s9x-next/libretro-snes9x-next.so"
LIBS="$LIBS libretro-genplus/libretro-genplus.so"
LIBS="$LIBS libretro-fba/libretro-fba.so"
LIBS="$LIBS libretro-vba/libretro-vba.so"
LIBS="$LIBS libretro-fceu/libretro-fceu.so"
LIBS="$LIBS libretro-bnes/libretro-bnes.so"
LIBS="$LIBS libretro-gambatte/libretro-gambatte.so"
LIBS="$LIBS libretro-meteor/libretro-meteor.so"
LIBS="$LIBS libretro-nx/libretro-nx.so"
LIBS="$LIBS libretro-prboom/libretro-prboom.so"
LIBS="$LIBS libretro-stella/libretro-stella.so"
LIBS="$LIBS libretro-desmume/libretro-desmume.so"
LIBS="$LIBS libretro-mednafen/libretro-mednafen-psx.so"
LIBS="$LIBS libretro-mednafen/libretro-mednafen-pce-fast.so"
LIBS="$LIBS libretro-mednafen/libretro-mednafen-wswan.so"
LIBS="$LIBS libretro-quicknes/libretro-quicknes.so"

for lib in $LIBS
do
   if [ -f $lib ]; then
      install -v -m644 $lib "$LIBRETRO_DIR"
   else
      echo "Library $lib not found, skipping ..."
   fi
done

