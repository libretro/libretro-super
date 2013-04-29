#!/bin/sh

build_libretro_fba()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba/
      cd svn-current/trunk
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha"
      cp fb_alpha_libretro$FORMAT.a $RARCH_DIST_DIR

      echo "=== Building Final Burn Alpha Cores (CPS1) ==="
      cd fbacores/cps1
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS1"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS1"
      cp fb_alpha_libretro$FORMAT.a $RARCH_DIST_DIR/fba_cores_cps1_libretro$FORMAT.a
      cd ../../
      
      echo "=== Building Final Burn Alpha Cores (CPS2) ==="
      cd fbacores/cps2
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS2"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS2"
      cp libretro$FORMAT.a $RARCH_DIST_DIR/fba_cores_cps2_libretro$FORMAT.a
      cd ../../

      echo "=== Building Final Burn Alpha Cores (NeoGeo) ==="
      cd fbacores/neogeo
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores NeoGeo"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores NeoGeo"
      cp libretro$FORMAT.a $RARCH_DIST_DIR/fba_cores_neo_libretro$FORMAT.a
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}
