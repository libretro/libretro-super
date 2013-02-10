#!/bin/sh

CORES_DIR=~/local-repos
ROOT_DIR=$CORES_DIR/libretro-super
RARCH_DIR=$CORES_DIR/RetroArch
RARCH_DIST_DIR=$RARCH_DIR/dist-scripts
FORMAT=_ps3
JOBS=7

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
      cd $MEDNAFEN_DIR_NAME
      cd jni
      ndk-build clean || die "Failed to clean mednafen_ngp"
      ndk-build core=ngp clean || die "Failed to clean mednafen_ngp"
      ndk-build core=ngp -j$JOBS || die "Failed to build mednafen_ngp"
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_mednafen_ngp.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_mednafen_ngp.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_mednafen_ngp.so

      ndk-build clean || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan clean || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan -j$JOBS || die "Failed to build mednafen_wswan"

      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_mednafen_wswan.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_mednafen_wswan.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_mednafen_wswan.so

      ndk-build clean || die "Failed to clean mednafen_vb"
      ndk-build core=vb clean || die "Failed to clean mednafen_vb"
      ndk-build core=vb -j$JOBS || die "Failed to build mednafen_vb"

      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_mednafen_vb.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_mednafen_vb.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_mednafen_vb.so

      ndk-build clean || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast clean || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast -j$JOBS || die "Failed to build mednafen_pce_fast"

      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_mednafen_pce_fast.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_mednafen_pce_fast.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_mednafen_pce_fast.so

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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_snes9x_next.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_snes9x_next.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_snes9x_next.so
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

GENPLUS_NEXT_DIR_NAME=Genesis-Plus-GX

build_libretro_genplus()
{
   cd $CORES_DIR
   if [ -d "$GENPLUS_DIR_NAME" ]; then
      echo "=== Building Genplus GX ==="
      cd $GENPLUS_DIR_NAME
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_genesis_plus_gx.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_genesis_plus_gx.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_genesis_plus_gx.so
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
      cd projectfiles/libretro-android/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_fba.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_fba.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_fba.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_vba_next.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_vba_next.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_vba_next.so
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
      cd fceumm-code/src/drivers/libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_fceumm.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_fceumm.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_fceumm.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_gambatte.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_gambatte.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_gambatte.so
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
      cd jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_nxengine.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_nxengine.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_nxengine.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_prboom.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_prboom.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_prboom.so
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
      cd jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_nestopia.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/phoenix/libs/mips/libretro_nestopia.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/phoenix/libs/x86/libretro_nestopia.so
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

PCSX_REARMED_DIR_NAME=pcsx_rearmed

build_libretro_pcsx_rearmed()
{
   cd $CORES_DIR
   if [ -d "$PCSX_REARMED_DIR_NAME" ]; then
      echo "=== Building PCSX ReARMed ==="
      cd $PCSX_REARMED_DIR_NAME
      cd jni
      ndk-build clean
      ndk-build -j$JOBS NO_NEON=1
      cp ../libs/armeabi-v7a/libretro-noneon.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_pcsx_rearmed.so
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/phoenix/libs/armeabi-v7a/libretro_pcsx_rearmed-neon.so
   else
      echo "PCSX ReARMed not fetched, skipping ..."
   fi
}

build_libretro_pcsx_rearmed
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
