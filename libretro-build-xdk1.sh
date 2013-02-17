#!/bin/sh

CORES_DIR=C:/local-repos
ROOT_DIR=$CORES_DIR/libretro-super
RARCH_DIR=$CORES_DIR/RetroArch
RARCH_DIST_DIR=$RARCH_DIR/dist-scripts
FORMAT=_xdk
LIB_EXT=lib
MSVC_NAME=msvc-2003-xbox1

die()
{
   echo $1
   #exit 1
}

MEDNAFEN_DIR_NAME=mednafen-libretro

build_libretro_mednafen()
{
   cd $CORES_DIR
   if [ -d "$MEDNAFEN_DIR_NAME" ]; then
      echo "=== Building Mednafen ==="
      cd $MEDNAFEN_DIR_NAME/msvc/pce-fast

      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/mednafen_pce_fast_libretro$FORMAT.lib $RARCH_DIST_DIR

      cd ../
      cd wswan
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/mednafen_wswan_libretro$FORMAT.lib $RARCH_DIST_DIR

      cd ../
      cd ngp
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/mednafen_ngp_libretro$FORMAT.lib $RARCH_DIST_DIR

      #msvc/vb/$MSVC_NAME.bat
      #cp msvc/vb/$MSVC_NAME/mednafen_vb_libretro$FORMAT.lib $RARCH_DIST_DIR
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

#build_libretro_s9x()
#{
   #if [ -d "libretro-s9x" ]; then
      #echo "=== Building SNES9x ==="
      #cd libretro-s9x/libretro
      #make -j4 || die "Failed to build SNES9x"
      #cp libretro.so ../libretro-snes9x.so
      #cd ../..
   #else
      #echo "SNES9x not fetched, skipping ..."
   #fi
#}

S9X_NEXT_DIR_NAME=snes9x-next

build_libretro_s9x_next()
{
   cd $CORES_DIR
   if [ -d "$S9X_NEXT_DIR_NAME" ]; then
      echo "=== Building SNES9x-Next ==="
      cd $S9X_NEXT_DIR_NAME
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/snes9x_next_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

GENPLUS_DIR_NAME=Genesis-Plus-GX

build_libretro_genplus()
{
   cd $CORES_DIR
   if [ -d "$GENPLUS_DIR_NAME" ]; then
      echo "=== Building Genplus GX ==="
      cd $GENPLUS_DIR_NAME
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/genesis_plus_gx_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

FBA_DIR_NAME=fba-libretro

build_libretro_fba()
{
   cd $CORES_DIR
   if [ -d "$FBA_DIR_NAME" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd $FBA_DIR_NAME/svn-current/trunk
      cd projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/fb_alpha_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR

      echo "=== Building Final Burn Alpha Cores (CPS1) ==="
      cd ../../fbacores/cps1/projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/fb_alpha_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR/fba_cores_cps1_libretro$FORMAT.$LIB_EXT
      cd ../../../../

      echo "=== Building Final Burn Alpha Cores (CPS2) ==="
      cd fbacores/cps2/projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR/fba_cores_cps2_libretro$FORMAT.$LIB_EXT
      cd ../../../../

      echo "=== Building Final Burn Alpha Cores (NeoGeo) ==="
      cd fbacores/neogeo/projectfiles/visualstudio-2003-libretro-xbox1
      cmd.exe /k $MSVC_NAME.bat
      cp Release_LTCG/libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR/fba_cores_neo_libretro$FORMAT.$LIB_EXT
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

VBA_NEXT_DIR_NAME=vba-next

build_libretro_vba()
{
   cd $CORES_DIR
   if [ -d "$VBA_NEXT_DIR_NAME" ]; then
      echo "=== Building VBA-Next ==="
      cd $VBA_NEXT_DIR_NAME
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release/vba_next_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

FCEUMM_DIR_NAME=fceu-next

build_libretro_fceu()
{
   cd $CORES_DIR
   if [ -d "$FCEUMM_DIR_NAME" ]; then
      echo "=== Building FCEU ==="
      cd $FCEUMM_DIR_NAME
      cd fceumm-code/src/drivers/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/fceumm_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "FCEU not fetched, skipping ..."
   fi
}

GAMBATTE_DIR_NAME=gambatte-libretro

build_libretro_gambatte()
{
   cd $CORES_DIR
   if [ -d "$GAMBATTE_DIR_NAME" ]; then
      echo "=== Building Gambatte ==="
      cd $GAMBATTE_DIR_NAME/libgambatte
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/gambatte_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "Gambatte not fetched, skipping ..."
   fi
}

NXENGINE_DIR_NAME=nxengine-libretro

build_libretro_nx()
{
   cd $CORES_DIR
   if [ -d "$NXENGINE_DIR_NAME" ]; then
      echo "=== Building NXEngine ==="
      cd $NXENGINE_DIR_NAME
      cd nxengine-1.0.0.4/libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/nxengine_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "NXEngine not fetched, skipping ..."
   fi
}

PRBOOM_DIR_NAME=libretro-prboom

build_libretro_prboom()
{
   cd $CORES_DIR
   if [ -d "$PRBOOM_DIR_NAME" ]; then
      echo "=== Building PRBoom ==="
      cd $PRBOOM_DIR_NAME
      cd libretro/msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/prboom_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}


#build_libretro_stella()
#{
   #if [ -d "libretro-stella" ]; then
      #echo "=== Building Stella ==="
      #cd libretro-stella
      #make -j4 || die "Failed to build Stella"
      #cp libretro.so libretro-stella.so
      #cd ../
   #else
      #echo "Stella not fetched, skipping ..."
   #fi
#}

#build_libretro_desmume()
#{
   #if [ -d "libretro-desmume" ]; then
      #echo "=== Building Desmume ==="
      #cd libretro-desmume
      #make -f Makefile.libretro -j4 || die "Failed to build Desmume"
      #cp libretro.so libretro-desmume.so
      #cd ../
   #else
      #echo "Desmume not fetched, skipping ..."
   #fi
#}

#build_libretro_quicknes()
#{
   #if [ -d "libretro-quicknes" ]; then
      #echo "=== Building QuickNES ==="
      #cd libretro-quicknes/libretro
      #make -j4 || die "Failed to build QuickNES"
      #cp libretro.so ../libretro-quicknes.so
      #cd ../..
   #else
      #echo "QuickNES not fetched, skipping ..."
   #fi
#}

NESTOPIA_DIR_NAME=nestopia

build_libretro_nestopia()
{
   cd $CORES_DIR
   if [ -d "$NESTOPIA_DIR_NAME" ]; then
      echo "=== Building Nestopia ==="
      cd $NESTOPIA_DIR_NAME/libretro
      cd msvc
      cmd.exe /k $MSVC_NAME.bat
      cp $MSVC_NAME/Release_LTCG/nestopia_libretro$FORMAT.$LIB_EXT $RARCH_DIST_DIR
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

build_libretro_mednafen
#build_libretro_s9x
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_fceu
build_libretro_gambatte
build_libretro_nx
build_libretro_prboom
#build_libretro_stella
#build_libretro_desmume
#build_libretro_quicknes
build_libretro_nestopia

