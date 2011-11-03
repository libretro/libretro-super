#!/bin/sh

die()
{
   echo $1
   exit 1
}

build_libsnes()
{
   if [ -d "libsnes/perf" ]; then
      echo "=== Building bSNES performance ==="
      cd libsnes/perf
      make profile=performance -j4 || die "Failed to build bSNES performance core"
      cp -f out/libsnes.so ../libsnes-performance.so
      cd ../..
   else
      echo "bSNES performance not fetched, skipping ..."
   fi

   if [ -d "libsnes/compat" ]; then
      echo "=== Building bSNES compatibility ==="
      cd libsnes/compat
      make profile=compatibility -j4 || die "Failed to build bSNES compatibility core"
      cp -f out/libsnes.so ../libsnes-compat.so
      cd ../..
   else
      echo "bSNES compat not fetched, skipping ..."
   fi

   if [ -d "libsnes" ]; then
      echo "=== Building bSNES accuracy ==="
      cd libsnes
      make profile=accuracy -j4 || die "Failed to build bSNES accuracy core"
      cp -f out/libsnes.so libsnes-accuracy.so
      cd ..
   fi
}

build_libsnes_s9x()
{
   if [ -d "libsnes-s9x" ]; then
      echo "=== Building SNES9x ==="
      cd libsnes-s9x/unix
      make -j4 || die "Failed to build SNES9x"
      cp libsnes.so ../libsnes-snes9x.so
      cd ../..
   else
      echo "SNES9x not fetched, skipping ..."
   fi
}

build_libsnes_genplus()
{
   if [ -d "libsnes-genplus" ]; then
      echo "=== Building Genplus GX ==="
      cd libsnes-genplus/src/libsnes
      make -j4 || die "Failed to build Genplus GX"
      cp libsnes.so ../../libsnes-genplus.so
      cd ../../..
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libsnes_fba()
{
   if [ -d "libsnes-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libsnes-fba/src-0.2.97.13/burner/libsnes
      make -j4 || die "Failed to build Final Burn Alpha"
      cp libsnes.so ../../../libsnes-fba.so
      cd ../../../..
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

build_libsnes_vba()
{
   if [ -d "libsnes-vba" ]; then
      echo "=== Building VBA-Next ==="
      cd libsnes-vba/trunk/platform/libsnes-gba
      make -j4 || die "Failed to build VBA-Next"
      cp libsnes.so ../../../libsnes-vba.so
      cd ../../../..
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libsnes_bnes()
{
   if [ -d "libsnes-bnes" ]; then
      echo "=== Building bNES ==="
      cd libsnes-bnes
      mkdir -p obj
      make -j4 || die "Failed to build bNES"
      cp libnes.so libsnes-bnes.so
      cd ..
   else
      echo "bNES not fetched, skipping ..."
   fi
}

build_libsnes_fceu()
{
   if [ -d "libsnes-fceu" ]; then
      echo "=== Building FCEU ==="
      cd libsnes-fceu/src/libsnes
      make -j4 || die "Failed to build FCEU"
      cp libsnes.so ../../libsnes-fceu.so
      cd ../../..
   else
      echo "bNES not fetched, skipping ..."
   fi
}

build_libsnes_gambatte()
{
   if [ -d "libsnes-gambatte" ]; then
      echo "=== Building Gambatte ==="
      cd libsnes-gambatte/libgambatte
      make -j4 || die "Failed to build Gambatte"
      cd libsnes
      make -j4 || die "Failed to build Gambatte"
      cp libsnes.so ../../libsnes-gambatte.so
      cd ../../..
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}


build_libsnes
build_libsnes_s9x
build_libsnes_genplus
build_libsnes_fba
build_libsnes_vba
build_libsnes_bnes
build_libsnes_fceu
build_libsnes_gambatte

