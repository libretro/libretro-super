#!/bin/bash

# BSDs don't have readlink -f
read_link()
{
   TARGET_FILE="$1"
   cd $(dirname "$TARGET_FILE")
   TARGET_FILE=$(basename "$TARGET_FILE")

   while [ -L "$TARGET_FILE" ]
   do
      TARGET_FILE=$(readlink "$TARGET_FILE")
      cd $(dirname "$TARGET_FILE")
      TARGET_FILE=$(basename "$TARGET_FILE")
   done

   PHYS_DIR=$(pwd -P)
   RESULT="$PHYS_DIR/$TARGET_FILE"
   echo $RESULT
}

SCRIPT=$(read_link "$0")
echo "Script: $SCRIPT"
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/android
FORMAT=_android
FORMAT_EXT=so

if [ -z "$JOBS" ]; then
   JOBS=4
fi

die()
{
   echo $1
   #exit 1
}

build_libretro_beetle_bsnes()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-bsnes" ]; then
      cd libretro-beetle-bsnes
      cd jni
      echo "=== Building Beetle bSNES ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle bSNES"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle bSNES"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_bsnes_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_bsnes_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_bsnes_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle bSNES not fetched, skipping ..."
   fi
}

build_libretro_beetle_lynx()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-lynx" ]; then
      cd libretro-beetle-lynx
      cd jni
      echo "=== Building Beetle Lynx ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle Lynx"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle Lynx"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_lynx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_lynx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_lynx_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle Lynx not fetched, skipping ..."
   fi
}

build_libretro_beetle_gba()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-gba" ]; then
      cd libretro-beetle-gba
      cd jni
      echo "=== Building Beetle GBA ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle GBA"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle GBA"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_gba_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_gba_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_gba_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle GBA not fetched, skipping ..."
   fi
}

build_libretro_beetle_ngp()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-ngp" ]; then
      cd libretro-beetle-ngp
      cd jni
      echo "=== Building Beetle NGP ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle NGP"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle NGP"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle NGP not fetched, skipping ..."
   fi
}

build_libretro_beetle_wswan()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-wswan" ]; then
      cd libretro-beetle-wswan
      cd jni
      echo "=== Building Beetle WSwan ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle WSwan"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle WSwan"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle WSwan not fetched, skipping ..."
   fi
}

build_libretro_beetle_psx()
{ cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-psx" ]; then
      cd libretro-beetle-psx
      cd jni
      echo "=== Building Beetle PSX ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle PSX"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle PSX"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle PSX not fetched, skipping ..."
   fi
}

build_libretro_beetle_pcfx()
{ cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-pcfx" ]; then
      cd libretro-beetle-pcfx
      cd jni
      echo "=== Building Beetle PCFX ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle PCFX"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle PCFX"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_pcfx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_pcfx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_pcfx_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle PCFX not fetched, skipping ..."
   fi
}

build_libretro_beetle_vb()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-vb" ]; then
      cd libretro-beetle-vb
      cd jni
      echo "=== Building Beetle VB ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle VB"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle VB"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle VB not fetched, skipping ..."
   fi
}

build_libretro_beetle_pce_fast()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-pce-fast" ]; then
      cd libretro-beetle-pce-fast
      cd jni
      echo "=== Building Beetle PCE Fast ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle PCE Fast"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle PCE Fast"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle PCE Fast not fetched, skipping ..."
   fi
}

build_libretro_beetle_supergrafx()
{
   cd $BASE_DIR
   pwd
   if [ -d "libretro-beetle-supergrafx" ]; then
      cd libretro-beetle-supergrafx
      cd jni
      echo "=== Building Beetle SuperGrafx ==="
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean Beetle SuperGrafx"
      fi
      ndk-build APP_ABI="armeabi-v7a mips x86" || die "Failed to build Beetle SuperGrafx"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_supergrafx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_supergrafx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_supergrafx_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Beetle SuperGrafx not fetched, skipping ..."
   fi
}

build_libretro_s9x()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x" ]; then
      echo "=== Building SNES9x ==="
      cd libretro-s9x/
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
	  fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/snes9x_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/snes9x_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/snes9x_libretro${FORMAT}.${FORMAT_EXT}
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
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/snes9x_next_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/snes9x_next_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/snes9x_next_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "SNES9x-Next not fetched, skipping ..."
   fi
}

build_libretro_stella()
{
   cd $BASE_DIR
   if [ -d "libretro-stella" ]; then
      echo "=== Building Stella ==="
      cd libretro-stella/
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/stella_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/stella_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/stella_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Stella not fetched, skipping ..."
   fi
}

build_libretro_genplus()
{
   cd $BASE_DIR
   if [ -d "libretro-genplus" ]; then
      echo "=== Building Genplus GX ==="
      cd libretro-genplus/
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/genesis_plus_gx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/genesis_plus_gx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/genesis_plus_gx_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Genplus GX not fetched, skipping ..."
   fi
}

build_libretro_fba_full()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha ==="
      cd libretro-fba
      cd svn-current/trunk
      cd projectfiles/libretro-android/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/fb_alpha_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/fb_alpha_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/fb_alpha_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Final Burn Alpha not fetched, skipping ..."
   fi
}

build_libretro_vbam()
{
   cd $BASE_DIR
   if [ -d "libretro-vbam" ]; then
      echo '=== Building VBA-M ==='
      cd libretro-vbam/
      cd src/libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/vbam_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/vbam_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/vbam_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo 'VBA-M not fetched, skipping ...'
   fi
}

build_libretro_vba_next()
{
   cd $BASE_DIR
   if [ -d "libretro-vba-next" ]; then
      echo "=== Building VBA-Next ==="
      cd libretro-vba-next/
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/vba_next_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/vba_next_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/vba_next_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "VBA-Next not fetched, skipping ..."
   fi
}

build_libretro_fceumm()
{
   cd $BASE_DIR
   if [ -d "libretro-fceumm" ]; then
      echo "=== Building FCEUmm ==="
      cd libretro-fceumm
      cd src/drivers/libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/fceumm_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/fceumm_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/fceumm_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "FCEUmm not fetched, skipping ..."
   fi
}

build_libretro_gambatte()
{
   cd $BASE_DIR
   if [ -d "libretro-gambatte" ]; then
      echo "=== Building Gambatte ==="
      cd libretro-gambatte/libgambatte
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/gambatte_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/gambatte_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/gambatte_libretro${FORMAT}.${FORMAT_EXT}
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
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/nxengine_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/nxengine_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/nxengine_libretro${FORMAT}.${FORMAT_EXT}
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
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/prboom_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/prboom_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/prboom_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "PRBoom not fetched, skipping ..."
   fi
}

build_libretro_dinothawr()
{
   cd $BASE_DIR
   if [ -d "libretro-dinothawr" ]; then
      echo "=== Building Dinothawr ==="
      cd libretro-dinothawr
      cd android/eclipse/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/dinothawr_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/mips/dinothawr_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/x86/dinothawr_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Dinothawr not fetched, skipping ..."
   fi
}

build_libretro_nestopia()
{
   cd $BASE_DIR
   if [ -d "libretro-nestopia" ]; then
      echo "=== Building Nestopia ==="
      cd libretro-nestopia/libretro
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/nestopia_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/nestopia_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/nestopia_libretro${FORMAT}.${FORMAT_EXT}
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
      #ndk-build clean APP_ABI=armeabi-v7a
      #ndk-build -j$JOBS NO_NEON=1 APP_ABI=armeabi-v7a
      #cp ../libs/armeabi-v7a/libretro-noneon.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/pcsx_rearmed_libretro${FORMAT}.${FORMAT_EXT}
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI=armeabi-v7a
      fi
      ndk-build -j$JOBS APP_ABI=armeabi-v7a
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/pcsx_rearmed_libretro_neon${FORMAT}.${FORMAT_EXT}
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
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/tyrquake_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/tyrquake_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/tyrquake_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "TyrQuake not fetched, skipping ..."
   fi
}

build_libretro_modelviewer()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-modelviewer" ]; then
      echo "=== Building Modelviewer (GL) ==="
      cd libretro-gl-modelviewer
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/modelviewer_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/modelviewer_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/modelviewer_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "ModelViewer not fetched, skipping ..."
   fi
}

build_libretro_modelviewer_location()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-modelviewer-location" ]; then
      echo "=== Building Modelviewer Location (GL) ==="
      cd libretro-gl-modelviewer-location
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/modelviewer_location_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/modelviewer_location_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/modelviewer_location_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "ModelViewer Location not fetched, skipping ..."
   fi
}

build_libretro_instancingviewer()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-instancingviewer" ]; then
      echo "=== Building InstancingViewer (GL) ==="
      cd libretro-gl-instancingviewer
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/instancingviewer_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/instancingviewer_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/instancingviewer_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "InstancingViewer not fetched, skipping ..."
   fi
}

build_libretro_instancingviewer_camera()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-instancingviewer-camera" ]; then
      echo "=== Building InstancingViewer Camera (GL) ==="
      cd libretro-gl-instancingviewer-camera
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "InstancingViewer Camera not fetched, skipping ..."
   fi
}

CORENAME="3dengine"

build_libretro_3dengine() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-3dengine' ]; then
      echo '=== Building 3DEngine (GL) ==='
      cd libretro-${CORENAME}
      cd jni

      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo '3DEngine not fetched, skipping ...'
   fi
}

build_libretro_scenewalker()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-scenewalker" ]; then
      echo "=== Building SceneWalker (GL) ==="
      cd libretro-gl-scenewalker
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/scenewalker_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/scenewalker_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/scenewalker_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "SceneWalker not fetched, skipping ..."
   fi
}

build_libretro_picodrive()
{
   cd $BASE_DIR
   if [ -d "libretro-picodrive" ]; then
      echo "=== Building Picodrive ==="
      cd libretro-picodrive
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI=armeabi-v7a
      fi
      ndk-build -j$JOBS APP_ABI=armeabi-v7a
      cp ../libs/armeabi-v7a/libretro_picodrive.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/picodrive_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Picodrive not fetched, skipping ..."
   fi
}

build_libretro_handy()
{
   cd $BASE_DIR
   if [ -d "libretro-handy" ]; then
      echo "=== Building Handy ==="
      cd libretro-handy
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/handy_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/mips/handy_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/x86/handy_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Handy not fetched, skipping ..."
   fi
}

build_libretro_desmume()
{
   cd $BASE_DIR
   if [ -d "libretro-desmume" ]; then
      echo "=== Building Desmume ==="
      cd libretro-desmume/desmume/src/libretro
      cd jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean
      fi
      ndk-build -j$JOBS APP_ABI=armeabi-v7a
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/desmume_libretro${FORMAT}.${FORMAT_EXT}
	  if [ -z "${NOCLEAN}" ]; then
         ndk-build clean
      fi
      ndk-build -j$JOBS APP_ABI=x86
      cp ../libs/x86/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/x86/desmume_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Desmume not fetched, skipping ..."
   fi
}

build_libretro_quicknes()
{
   cd $BASE_DIR
   if [ -d "libretro-quicknes" ]; then
      echo "=== Building QuickNES ==="
      cd libretro-quicknes
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/quicknes_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/mips/quicknes_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/x86/quicknes_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "QuickNES not fetched, skipping ..."
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

   if [ -d $RARCH_DIST_DIR/armeabi-v7a ]; then
      echo "Directory $RARCH_DIST_DIR/armeabi-v7a already exists, skipping creation..."
   else
      mkdir $RARCH_DIST_DIR/armeabi-v7a
   fi

   if [ -d $RARCH_DIST_DIR/mips ]; then
      echo "Directory $RARCH_DIST_DIR/mips already exists, skipping creation..."
   else
      mkdir $RARCH_DIST_DIR/mips
   fi

   if [ -d $RARCH_DIST_DIR/x86 ]; then
      echo "Directory $RARCH_DIST_DIR/x86 already exists, skipping creation..."
   else
      mkdir $RARCH_DIST_DIR/x86
   fi
}

build_libretro_bsnes()
{
   #TODO - maybe accuracy/balanced cores as well
   cd $BASE_DIR
   if [ -d "libretro-bsnes" ]; then
      echo "=== Building bsnes (performance core) ==="
      cd libretro-bsnes/perf
      cd target-libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a x86"
      cp ../libs/armeabi-v7a/libretro_bsnes_performance.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/bsnes_performance_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro_bsnes_performance.${FORMAT_EXT} $RARCH_DIST_DIR/x86/bsnes_performance_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "bsnes not fetched, skipping ..."
   fi
}

build_libretro_mupen64()
{
   cd $BASE_DIR
   if [ -d "libretro-mupen64plus" ]; then
      echo '=== Building Mupen 64 Plus (ARMv7 dynarec) ==='
      cd libretro-mupen64plus
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a"
      cp ../libs/armeabi-v7a/libretro_mupen64plus.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mupen64plus_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo 'Mupen64 Plus not fetched, skipping ...'
   fi
}

build_libretro_yabause()
{
   cd $BASE_DIR
   if [ -d "libretro-yabause" ]; then
      echo '=== Building Yabause ==='
      cd libretro-yabause
      cd libretro/jni
      if [ -z "${NOCLEAN}" ]; then
         ndk-build clean APP_ABI="armeabi-v7a mips x86"
      fi
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/yabause_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/mips/yabause_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/x86/yabause_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo 'Yabause not fetched, skipping ...'
   fi
}

create_dist_dir

if [ $1 ]; then
   $1
else
   #build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   build_libretro_beetle_lynx
   build_libretro_beetle_gba
   build_libretro_beetle_ngp
   build_libretro_beetle_pce_fast
   build_libretro_beetle_supergrafx
   build_libretro_beetle_pcfx
   build_libretro_beetle_vb
   build_libretro_beetle_wswan
   build_libretro_beetle_psx
   build_libretro_beetle_bsnes
   build_libretro_s9x
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba_full
   build_libretro_vbam
   build_libretro_vba_next
   #build_libretro_bnes
   build_libretro_fceumm
   build_libretro_gambatte
   build_libretro_meteor
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_nestopia
   build_libretro_tyrquake
   #build_libretro_mame078
   #build_libretro_mame
   #build_libretro_dosbox
   #build_libretro_scummvm
   build_libretro_picodrive
   build_libretro_handy
   build_libretro_desmume
   build_libretro_pcsx_rearmed
   build_libretro_modelviewer
   build_libretro_scenewalker
   build_libretro_instancingviewer
   build_libretro_instancingviewer_camera
   build_libretro_mupen64
   #build_libretro_ffmpeg
   build_libretro_yabause
   build_libretro_dinothawr
   build_libretro_3dengine
fi
