#!/bin/sh

if [ -z "$1" ]; then
   LIBRETRO_DIR="libretro"
else
   LIBRETRO_DIR="$1"
fi

ARCH_EXT="$2"

if [ ! -d "$LIBRETRO_DIR" ]; then
   mkdir -p "$LIBRETRO_DIR"
fi

LIBS=""
LIBS="$LIBS libretro-bsnes/libretro-089-bsnes-performance.dll"
LIBS="$LIBS libretro-bsnes/libretro-089-bsnes-compat.dll"
LIBS="$LIBS libretro-bsnes/libretro-089-bsnes-accuracy.dll"
LIBS="$LIBS libretro-s9x/libretro-git-snes9x.dll"
LIBS="$LIBS libretro-s9x-next/libretro-git-snes9x-next.dll"
LIBS="$LIBS libretro-genplus/libretro-git-genplus.dll"
LIBS="$LIBS libretro-fba/libretro-git-fba.dll"
LIBS="$LIBS libretro-vba/libretro-git-vba.dll"
LIBS="$LIBS libretro-fceu/libretro-git-fceu.dll"
LIBS="$LIBS libretro-bnes/libretro-git-bnes.dll"
LIBS="$LIBS libretro-gambatte/libretro-git-gambatte.dll"
LIBS="$LIBS libretro-meteor/libretro-git-meteor.dll"
LIBS="$LIBS libretro-stella/libretro-git-stella.dll"
LIBS="$LIBS libretro-desmume/libretro-git-desmume.dll"
LIBS="$LIBS libretro-mednafen/libretro-0926-mednafen-psx.dll"
LIBS="$LIBS libretro-mednafen/libretro-0924-mednafen-pce-fast.dll"
LIBS="$LIBS libretro-mednafen/libretro-0922-mednafen-wswan.dll"

for lib in $LIBS
do
   if [ -f $lib ]; then
      install -v -m644 $lib "$LIBRETRO_DIR"
   else
      echo "Library $lib not found, skipping ..."
   fi
done

cd "$LIBRETRO_DIR"
for file in `find . -name "*.dll"`
do
   REGEX_MV="s|^\(.*\)\.dll$|\1-${ARCH_EXT}.dll|"
   REGEX="s|^\(.*\)\.dll$|\1-${ARCH_EXT}.zip|"
   FILENAME="`echo $file | sed -e $REGEX_MV`"
   mv -v "$file" "$FILENAME"
   zip "`echo $file | sed -e $REGEX`" "$FILENAME"
done

