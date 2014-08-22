#!/bin/bash

build_libretro_fba_cps2_gx()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (CPS2) ==="
      cd libretro-fba/
      cd svn-old/trunk
      cd fbacores/cps2
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS2"
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS2"
      cp fba_cores_cps2_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_cps2_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_fba()
{
   build_libretro_fb_alpha
   build_libretro_fba_cps1
   build_libretro_fba_cps2_gx
   build_libretro_fba_neogeo
}
