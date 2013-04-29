#!/bin/sh

SCRIPT=$(readlink -f $0)
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
JOBS=7

echo $RARCH_DIR

die()
{
   echo $1
   #exit 1
}

build_libretro_mednafen()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen ==="
      cd libretro-mednafen
      cd jni
      ndk-build clean || die "Failed to clean mednafen_ngp"
      ndk-build core=ngp clean || die "Failed to clean mednafen_ngp"
      ndk-build core=ngp -j$JOBS || die "Failed to build mednafen_ngp"
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_mednafen_ngp.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_mednafen_ngp.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_mednafen_ngp.so

      ndk-build clean || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan clean || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan -j$JOBS || die "Failed to build mednafen_wswan"

      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_mednafen_wswan.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_mednafen_wswan.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_mednafen_wswan.so

      ndk-build clean || die "Failed to clean mednafen_vb"
      ndk-build core=vb clean || die "Failed to clean mednafen_vb"
      ndk-build core=vb -j$JOBS || die "Failed to build mednafen_vb"

      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_mednafen_vb.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_mednafen_vb.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_mednafen_vb.so

      ndk-build clean || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast clean || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast -j$JOBS || die "Failed to build mednafen_pce_fast"

      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_mednafen_pce_fast.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_mednafen_pce_fast.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_mednafen_pce_fast.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_snes9x_next.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_snes9x_next.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_snes9x_next.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_genesis_plus_gx.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_genesis_plus_gx.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_genesis_plus_gx.so
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libretro_fba()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba
      cd svn-current/trunk
      cd projectfiles/libretro-android/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_fba.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_fba.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_fba.so
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

build_libretro_vba()
{
   cd $BASE_DIR
   if [ -d "libretro-vba" ]; then
      echo "=== Building VBA-Next ==="
      cd libretro-vba/
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_vba_next.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_vba_next.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_vba_next.so
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libretro_fceu()
{
   cd $BASE_DIR
   if [ -d "libretro-fceu" ]; then
      echo "=== Building FCEU ==="
      cd libretro-fceu
      cd fceumm-code/src/drivers/libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_fceumm.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_fceumm.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_fceumm.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_gambatte.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_gambatte.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_gambatte.so
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
      cd jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_nxengine.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_nxengine.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_nxengine.so
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
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_prboom.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_prboom.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_prboom.so
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
      cd jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_nestopia.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_nestopia.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_nestopia.so
   else
      echo "Nestopia not fetched, skipping ..."
   fi
}

build_libretro_pcsx_rearmed()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-pcsx-rearmed" ]; then
      echo "=== Building PCSX ReARMed ==="
      cd libretro-pcsx-rearmed
      cd jni
      ndk-build clean
      ndk-build -j$JOBS NO_NEON=1
      cp ../libs/armeabi-v7a/libretro-noneon.so $RARCH_DIR/android/armeabi-v7a/libretro_pcsx_rearmed.so
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_pcsx_rearmed-neon.so
   else
      echo "PCSX ReARMed not fetched, skipping ..."
   fi
}

build_libretro_tyrquake()
{
   cd $BASE_DIR
   if [ -d "libretro-tyrquake" ]; then
      echo "=== Building TyrQuake ==="
      cd libretro-tyrquake
      cd libretro/jni
      ndk-build clean
      ndk-build -j$JOBS
      cp ../libs/armeabi-v7a/libretro.so $RARCH_DIR/android/armeabi-v7a/libretro_tyrquake.so
      cp ../libs/mips/libretro.so $RARCH_DIR/android/mips/libretro_tyrquake.so
      cp ../libs/x86/libretro.so $RARCH_DIR/android/x86/libretro_tyrquake.so
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

   if [ -d $RARCH_DIR/android ]; then
      echo "Directory $RARCH_DIR/android already exists, skipping creation..."
   else
      mkdir $RARCH_DIR/android
   fi

   if [ -d $RARCH_DIR/android/armeabi-v7a ]; then
      echo "Directory $RARCH_DIR/android/armeabi-v7a already exists, skipping creation..."
   else
      mkdir $RARCH_DIR/android/armeabi-v7a
   fi

   if [ -d $RARCH_DIR/android/mips ]; then
      echo "Directory $RARCH_DIR/android/mips already exists, skipping creation..."
   else
      mkdir $RARCH_DIR/android/mips
   fi

   if [ -d $RARCH_DIR/android/x86 ]; then
      echo "Directory $RARCH_DIR/android/x86 already exists, skipping creation..."
   else
      mkdir $RARCH_DIR/android/x86
   fi
}

create_dist_dir

build_libretro_pcsx_rearmed
build_libretro_mednafen
build_libretro_s9x_next
build_libretro_genplus
build_libretro_fba
build_libretro_vba
build_libretro_fceu
build_libretro_gambatte
build_libretro_nx
build_libretro_prboom
build_libretro_nestopia
build_libretro_tyrquake
