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
      cd libretro-bsnes/perf/higan
      make platform=win compiler="$CC" ui=target-libretro profile=performance -j4 || die "Failed to build bSNES performance core"
      cp -f out/retro.dll ../../libretro-092-bsnes-performance.dll
      cd ../../..
   else
      echo "bSNES performance not fetched, skipping ..."
   fi

   if [ -d "libretro-bsnes/balanced" ]; then
      echo "=== Building bSNES balanced ==="
      cd libretro-bsnes/balanced/higan
      make platform=win compiler="$CC" ui=target-libretro profile=balanced -j4 || die "Failed to build bSNES balanced core"
      cp -f out/retro.dll ../../libretro-092-bsnes-balanced.dll
      cd ../../..
   else
      echo "bSNES compat not fetched, skipping ..."
   fi

   if [ -d "libretro-bsnes" ]; then
      echo "=== Building bSNES accuracy ==="
      cd libretro-bsnes/higan
      make platform=win compiler="$CC" ui=target-libretro profile=accuracy -j4 || die "Failed to build bSNES accuracy core"
      cp -f out/retro.dll ../libretro-092-bsnes-accuracy.dll
      cd ../..
   fi
}

build_libretro_mednafen()
{
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen ==="
      cd libretro-mednafen

      cd psx
      make core=psx platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build mednafen/psx"
      cp retro.dll ../libretro-0926-mednafen-psx.dll
      cd ..

      cd pce-fast
      make core=pce-fast platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build mednafen/pce-fast"
      cp retro.dll ../libretro-0924-mednafen-pce-fast.dll
      cd ..

      cd wswan
      make core=wswan platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build mednafen/wswan"
      cp retro.dll ../libretro-0922-mednafen-wswan.dll
      cd ..

      cd ..
   else
      echo "Mednafen not fetched, skipping ..."
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
      cd libretro-fba/svn-current/trunk
      make CC=$CC CXX=$CXX platform=win -f makefile.libretro -j4 || die "Failed to build Final Burn Alpha"
      cp retro.dll ../../libretro-git-fba.dll
      cd ../../..
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
      make CC=$CC CXX=$CXX platform=win -C src-fceumm -f Makefile.libretro -j4 || die "Failed to build FCEU"
      cp src-fceumm/retro.dll libretro-git-fceu.dll
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
      cd ../..
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

build_libretro_desmume()
{
   if [ -d "libretro-desmume" ]; then
      echo "=== Building Desmume ==="
      cd libretro-desmume
      make platform=win CC=$CC CXX=$CXX -f Makefile.libretro -j4 || die "Failed to build Desmume"
      cp retro.dll libretro-git-desmume.dll
      cd ../
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

build_libretro_quicknes()
{
   if [ -d "libretro-quicknes" ]; then
      echo "=== Building Desmume ==="
      cd libretro-quicknes/libretro
      make platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build QuickNES"
      cp retro.dll ../libretro-git-quicknes.dll
      cd ../..
   else
      echo "QuickNES not fetched, skipping ..."
   fi
}

build_libretro_nestopia()
{
   if [ -d "libretro-nestopia" ]; then
      echo "=== Building Nestopia ==="
      cd libretro-nestopia/libretro
      make platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Nestopia"
      cp retro.dll ../libretro-143-nestopia.dll
      cd ../..
   else
      echo "QuickNES not fetched, skipping ..."
   fi
}

build_libretro_bsnes
build_libretro_mednafen
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
build_libretro_desmume
build_libretro_quicknes
build_libretro_nestopia

