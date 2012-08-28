#!/bin/sh

die()
{
   echo $1
   #exit 1
}

if [ -z "$CC" ]; then
   CC=gcc
fi

build_libretro_bsnes()
{
   if [ -d "libretro-bsnes/perf" ]; then
      echo "=== Building bSNES performance ==="
      cd libretro-bsnes/perf/bsnes
      make platform=win compiler="$CC" ui=target-libretro profile=performance -j4 || die "Failed to build bSNES performance core"
      cp -f out/retro.dll ../../libretro-089-bsnes-performance.dll
      cd ../../..
   else
      echo "bSNES performance not fetched, skipping ..."
   fi

   if [ -d "libretro-bsnes/compat" ]; then
      echo "=== Building bSNES compatibility ==="
      cd libretro-bsnes/compat/bsnes
      make platform=win compiler="$CC" ui=target-libretro profile=compatibility -j4 || die "Failed to build bSNES compatibility core"
      cp -f out/retro.dll ../../libretro-089-bsnes-compat.dll
      cd ../../..
   else
      echo "bSNES compat not fetched, skipping ..."
   fi

   if [ -d "libretro-bsnes" ]; then
      echo "=== Building bSNES accuracy ==="
      cd libretro-bsnes/bsnes
      make platform=win compiler="$CC" ui=target-libretro profile=accuracy -j4 || die "Failed to build bSNES accuracy core"
      cp -f out/retro.dll ../libretro-089-bsnes-accuracy.dll
      cd ../..
   fi
}

build_libretro_s9x()
{
   if [ -d "libretro-s9x" ]; then
      echo "=== Building SNES9x ==="
      cd libretro-s9x/libretro
      make CC=$CC CXX=$CXX platform=win -j4 || die "Failed to build SNES9x"
      cp libretro.dll ../libretro-git-snes9x.dll
      cd ../..
   else
      echo "SNES9x not fetched, skipping ..."
   fi
}

build_libretro_s9x_next()
{
   if [ -d "libretro-s9x-next" ]; then
      echo "=== Building SNES9x-Next ==="
      cd libretro-s9x-next/
      make CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build SNES9x-Next"
      cp retro.dll libretro-git-snes9x-next.dll
      cd ..
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

build_libretro_genplus()
{
   if [ -d "libretro-genplus" ]; then
      echo "=== Building Genplus GX ==="
      cd libretro-genplus/
      make CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build Genplus GX"
      cp retro.dll libretro-git-genplus.dll
      cd ..
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libretro_fba()
{
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba/src-0.2.97.26
      make -f makefile.libretro generate-files
      make CC=$CC CXX=$CXX platform=win -f makefile.libretro -j4 || die "Failed to build Final Burn Alpha"
      cp retro.dll ../libretro-git-fba.dll
      cd ../..
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

build_libretro_vba()
{
   if [ -d "libretro-vba" ]; then
      echo "=== Building VBA-Next ==="
      cd libretro-vba/
      make CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build VBA-Next"
      cp retro.dll libretro-git-vba.dll
      cd ..
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libretro_bnes()
{
   if [ -d "libretro-bnes" ]; then
      echo "=== Building bNES ==="
      cd libretro-bnes
      mkdir -p obj
      make CC=$CC CXX=$CXX platform=win -j4 || die "Failed to build bNES"
      cp retro.dll libretro-git-bnes.dll
      cd ..
   else
      echo "bNES not fetched, skipping ..."
   fi
}

build_libretro_fceu()
{
   if [ -d "libretro-fceu" ]; then
      echo "=== Building FCEU ==="
      cd libretro-fceu
      make CC=$CC CXX=$CXX platform=win -f Makefile.libretro-fceumm -j4 || die "Failed to build FCEU"
      cp retro.dll libretro-git-fceu.dll
      cd ..
   else
      echo "FCEU not fetched, skipping ..."
   fi
}

build_libretro_gambatte()
{
   if [ -d "libretro-gambatte" ]; then
      echo "=== Building Gambatte ==="
      cd libretro-gambatte/libgambatte
      make CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build Gambatte"
      cp retro.dll ../libretro-git-gambatte.dll
      cd ../..
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}

build_libretro_meteor()
{
   if [ -d "libretro-meteor" ]; then
      echo "=== Building Meteor ==="
      cd libretro-meteor/libretro
      make platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Meteor"
      cp retro.dll ../libretro-git-meteor.dll
      cd ../
   else
      echo "Meteor not fetched, skipping ..."
   fi
}

build_libretro_stella()
{
   if [ -d "libretro-stella" ]; then
      echo "=== Building Stella ==="
      cd libretro-stella
      make platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Stella"
      cp retro.dll libretro-git-stella.dll
      cd ../
   else
      echo "Stella not fetched, skipping ..."
   fi
}

MEDNAFEN_VER=0924

build_libretro_mednafen()
{
   if [ -d "libretro-mednafen-${1}" ]; then
      echo "=== Building Mednafen/${2} ==="
      cd libretro-mednafen-${1}
      make platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Mednafen/${2}"
      cp retro.dll libretro-${MEDNAFEN_VER}-mednafen-${1}.dll
      cd ../
   else
      echo "Mednafen/${2} not fetched, skipping ..."
   fi
}

build_libretro_bsnes
build_libretro_s9x
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_bnes
build_libretro_fceu
build_libretro_gambatte
build_libretro_meteor
build_libretro_stella
build_libretro_mednafen psx PSX
build_libretro_mednafen pce PCE
build_libretro_mednafen wswan WSwan
build_libretro_mednafen ngp NGP

