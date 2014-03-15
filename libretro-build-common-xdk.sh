#!/bin/bash

die()
{
   echo $1
   #exit 1
}

build_libretro_mednafen()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen ==="
      cd libretro-mednafen
      cd msvc/pce-fast

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/mednafen_pce_fast_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"

      cd ../
      cd wswan
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/mednafen_wswan_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"

      cd ../
      cd ngp
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/mednafen_ngp_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"

      cd ../
      cd vb
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/mednafen_vb_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_s9x_next()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x-next" ]; then
      echo "=== Building SNES9x-Next ==="
      cd libretro-s9x-next/
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/snes9x_next_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

build_libretro_genplus()
{
   cd $BASE_DIR
   if [ -d "libretro-genplus" ]; then
      echo "=== Building Genplus GX ==="
      cd libretro-genplus/
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/genesis_plus_gx_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libretro_vba_next()
{
   cd $BASE_DIR
   if [ -d "libretro-vba-next" ]; then
      echo "=== Building VBA-Next ==="
      cd libretro-vba-next/
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release/vba_next_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libretro_mame078() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame078' ]; then
      echo '=== Building MAME 0.78 ==='
      cd libretro-mame078
      cd src/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/msvc-2010-360.$FORMAT_EXT "$RARCH_DIST_DIR"/mame078_libretro$FORMAT.$FORMAT_EXT
   else
      echo 'MAME 0.78 not fetched, skipping ...'
   fi
}

build_libretro_fceu()
{
   cd $BASE_DIR
   if [ -d "libretro-fceu" ]; then
      echo "=== Building FCEU ==="
      cd libretro-fceu
      cd fceumm-code/src/drivers/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/fceumm_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "FCEU not fetched, skipping ..."
   fi
}

build_libretro_gambatte()
{
   cd $BASE_DIR
   if [ -d "libretro-gambatte" ]; then
      echo "=== Building Gambatte ==="
      cd libretro-gambatte/libgambatte
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/gambatte_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}

build_libretro_nx()
{
   cd $BASE_DIR
   if [ -d "libretro-nx" ]; then
      echo "=== Building NXEngine ==="
      cd libretro-nx
      cd nxengine-1.0.0.4/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/nxengine_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "NXEngine not fetched, skipping ..."
   fi
}

build_libretro_nx()
{
   cd "$BASE_DIR"
   if [ -d "libretro-nx" ]; then
      echo "=== Building NXEngine ==="
      cd libretro-nx
      cd nxengine-1.0.0.4/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/nxengine_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "NXEngine not fetched, skipping ..."
   fi
}

build_libretro_prboom()
{
   cd $BASE_DIR
   if [ -d "libretro-prboom" ]; then
      echo "=== Building PRBoom ==="
      cd libretro-prboom
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/prboom_libretro$FORMAT.$FORMAT_EXT
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}

build_libretro_nestopia()
{
   cd $BASE_DIR
   if [ -d "libretro-nestopia" ]; then
      echo "=== Building Nestopia ==="
      cd libretro-nestopia/libretro
      cd msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/nestopia_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

build_libretro_tyrquake()
{
   cd $BASE_DIR
   if [ -d "libretro-tyrquake" ]; then
      echo "=== Building TyrQuake ==="
      cd libretro-tyrquake
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/tyrquake_libretro$FORMAT.$FORMAT_EXT
   else
      echo "TyrQuake not fetched, skipping ..."
   fi
}

build_libretro_nx()
{
   cd $BASE_DIR
   if [ -d "libretro-nx" ]; then
      echo "=== Building NXEngine ==="
      cd libretro-nx
      cd nxengine-1.0.0.4/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/nxengine_libretro$FORMAT.$FORMAT_EXT "$RARCH_DIST_DIR"
   else
      echo "NXEngine not fetched, skipping ..."
   fi
}

create_dist_dir()
{
   if [ -d $RARCH_DIR ]; then
      echo "Directory $RARCH_DIR already exists, skipping creation..."
   else
      mkdir $RARCH_DIR
   fi

   if [ -d $RARCH_DIST_DIR ]; then
      echo "Directory $RARCH_DIST_DIR already exists, skipping creation..."
   else
      mkdir $RARCH_DIST_DIR
   fi
}

create_dist_dir
