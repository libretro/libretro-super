#!/bin/sh

die()
{
   echo $1
   #exit 1
}

if [ "$HOST_CC" ]; then
   CC="${HOST_CC}-gcc"
   CXX="${HOST_CC}-g++"
   STRIP="${HOST_CC}-strip"
fi

if [ -z "$MAKE" ]; then
   if [ "$(expr substr $(uname -s) 1 7)" == "MINGW32" ]; then
      MAKE=mingw32-make
   else
      MAKE=make
   fi
fi

if [ -z "$CC" ]; then
   if [ "$(expr substr $(uname -s) 1 7)" == "MINGW32" ]; then
      CC=mingw32-gcc
   else
      CC=gcc
   fi
fi

if [ -z "$CXX" ]; then
   if [ "$(expr substr $(uname -s) 1 7)" == "MINGW32" ]; then
      CXX=mingw32-g++
   else
      CXX=g++
   fi
fi

build_libretro_bsnes()
{
   if [ -d "libretro-bsnes/perf" ]; then
      echo "=== Building bSNES performance ==="
      cd libretro-bsnes/perf/higan
      $MAKE platform=win compiler="$CC" ui=target-libretro profile=performance -j4 || die "Failed to build bSNES performance core"
      cp -f out/retro.dll ../../libretro-092-bsnes-performance.dll
      cd ../../..
   else
      echo "bSNES performance not fetched, skipping ..."
   fi

   if [ -d "libretro-bsnes/balanced" ]; then
      echo "=== Building bSNES balanced ==="
      cd libretro-bsnes/balanced/higan
      $MAKE platform=win compiler="$CC" ui=target-libretro profile=balanced -j4 || die "Failed to build bSNES balanced core"
      cp -f out/retro.dll ../../libretro-092-bsnes-balanced.dll
      cd ../../..
   else
      echo "bSNES compat not fetched, skipping ..."
   fi

   if [ -d "libretro-bsnes" ]; then
      echo "=== Building bSNES accuracy ==="
      cd libretro-bsnes/higan
      $MAKE platform=win compiler="$CC" ui=target-libretro profile=accuracy -j4 || die "Failed to build bSNES accuracy core"
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
      $MAKE core=psx platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build mednafen/psx"
      cp retro.dll ../libretro-0928-mednafen-psx.dll
      "$STRIP" ../libretro-0928-mednafen-psx.dll
      cd ..

      cd pce-fast
      $MAKE core=pce-fast platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build mednafen/pce-fast"
      cp retro.dll ../libretro-0928-mednafen-pce-fast.dll
      "$STRIP" ../libretro-0928-mednafen-pce-fast.dll
      cd ..

      cd wswan
      $MAKE core=wswan platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build mednafen/wswan"
      cp retro.dll ../libretro-0928-mednafen-wswan.dll
      "$STRIP" ../libretro-0928-mednafen-wswan.dll
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
      $MAKE CC=$CC CXX=$CXX platform=win -j4 || die "Failed to build SNES9x"
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
      $MAKE CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build SNES9x-Next"
      cp snes9x_next_retro.dll libretro-git-snes9x-next.dll
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
      $MAKE CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build Genplus GX"
      cp genesis_plus_gx_retro.dll libretro-git-genplus.dll
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
      $MAKE CC=$CC CXX=$CXX platform=win -f makefile.libretro -j4 || die "Failed to build Final Burn Alpha"
      cp fb_alpha_retro.dll ../../libretro-git-fba.dll
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
      $MAKE CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build VBA-Next"
      cp vba_next_retro.dll libretro-git-vba.dll
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
      $MAKE CC=$CC CXX=$CXX platform=win -j4 || die "Failed to build bNES"
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
      $MAKE CC=$CC CXX=$CXX platform=win -C fceumm-code -f Makefile.libretro -j4 || die "Failed to build FCEU"
      cp fceumm-code/fceumm_retro.dll libretro-git-fceu.dll
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
      $MAKE CC=$CC CXX=$CXX platform=win -f Makefile.libretro -j4 || die "Failed to build Gambatte"
      cp gambatte_retro.dll ../libretro-git-gambatte.dll
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
      $MAKE platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Meteor"
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
      $MAKE platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Stella"
      cp stella_retro.dll libretro-git-stella.dll
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
      $MAKE platform=win CC=$CC CXX=$CXX -f Makefile.libretro -j4 || die "Failed to build Desmume"
      cp retro.dll libretro-git-desmume.dll
      cd ../
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

build_libretro_quicknes()
{
   if [ -d "libretro-quicknes" ]; then
      echo "=== Building QuickNES ==="
      cd libretro-quicknes/libretro
      $MAKE platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build QuickNES"
      cp quicknes_retro.dll ../libretro-git-quicknes.dll
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
      $MAKE platform=win CC=$CC CXX=$CXX -j4 || die "Failed to build Nestopia"
      cp nestopia_retro.dll ../libretro-144-nestopia.dll
      cd ../..
   else
      echo "Nestopia not fetched, skipping ..."
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

