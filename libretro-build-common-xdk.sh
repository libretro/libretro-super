#!/bin/bash

die()
{
   echo $1
   #exit 1
}

build_libretro_mednafen_pce_fast()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen PCE Fast ==="
      cd libretro-mednafen
      cd msvc/pce-fast

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/mednafen_pce_fast_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Mednafen PCE Fast not fetched, skipping ..."
   fi
}

build_libretro_mednafen_wswan()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen Wswan ==="
      cd libretro-mednafen
      cd msvc/wswan

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/mednafen_wswan_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Mednafen Wswan not fetched, skipping ..."
   fi
}

build_libretro_mednafen_ngp()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen NGP ==="
      cd libretro-mednafen
      cd msvc/ngp

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/mednafen_ngp_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Mednafen NGP not fetched, skipping ..."
   fi
}

build_libretro_mednafen_vb()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen VB ==="
      cd libretro-mednafen
      cd msvc/vb

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/mednafen_vb_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Mednafen VB not fetched, skipping ..."
   fi
}

build_libretro_mednafen_gba()
{
   cd $BASE_DIR
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen GBA ==="
      cd libretro-mednafen
      cd msvc/gba

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/mednafen_gba_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Mednafen GBA not fetched, skipping ..."
   fi
}

build_libretro_s9x()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x" ]; then
      echo "=== Building SNES9x ==="
      cd libretro-s9x/
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/snes9x_libretro$FORMAT.$FORMAT_EXT
   else
      echo "SNES9x not fetched, skipping ..."
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
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/snes9x_next_libretro$FORMAT.$FORMAT_EXT
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
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/genesis_plus_gx_libretro$FORMAT.$FORMAT_EXT
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
      cp $MSVC_NAME/$RELEASE/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/vba_next_libretro$FORMAT.$FORMAT_EXT
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
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/mame078_libretro$FORMAT.$FORMAT_EXT
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
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/fceumm_libretro$FORMAT.$FORMAT_EXT
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
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/gambatte_libretro$FORMAT.$FORMAT_EXT
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
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/nxengine_libretro$FORMAT.$FORMAT_EXT
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

build_libretro_stella()
{
   cd $BASE_DIR
   if [ -d "libretro-stella" ]; then
      echo "=== Building Stella ==="
      cd libretro-stella
      cd msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/stella_libretro$FORMAT.$FORMAT_EXT
   else
      echo "Stella not fetched, skipping ..."
   fi
}

build_libretro_picodrive()
{
   cd $BASE_DIR
   if [ -d "libretro-picodrive" ]; then
      echo "=== Building Picodrive ==="
      cd libretro-picodrive
      cd platform/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/$RELEASE_LTCG/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/picodrive_libretro$FORMAT.$FORMAT_EXT
   else
      echo Picodrive not fetched, skipping ..."
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
