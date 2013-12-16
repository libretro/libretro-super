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

build_libretro_mednafen()
{
   #TODO - refactor
   cd $BASE_DIR
   pwd
   if [ -d "libretro-mednafen" ]; then
      echo "=== Building Mednafen cores ==="
      cd libretro-mednafen
      cd jni
      echo "=== Building Mednafen NGP ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_ngp"
      ndk-build core=ngp clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_ngp"
      ndk-build core=ngp -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_ngp"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_ngp_libretro${FORMAT}.${FORMAT_EXT}

      echo "=== Building Mednafen WonderSwan ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_wswan"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_wswan_libretro${FORMAT}.${FORMAT_EXT}

      echo "=== Building Mednafen VirtualBoy ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_vb"
      ndk-build core=vb clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_vb"
      ndk-build core=vb -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_vb"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_vb_libretro${FORMAT}.${FORMAT_EXT}

      echo "=== Building Mednafen PCE Fast ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_pce_fast"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_pce_fast_libretro${FORMAT}.${FORMAT_EXT}

      echo "=== Building Mednafen PSX ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_psx"
      ndk-build core=psx clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_psx"
      ndk-build core=psx -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_psx"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/mednafen_psx_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "Mednafen not fetched, skipping ..."
   fi
}

build_libretro_s9x()
{
   cd $BASE_DIR
   if [ -d "libretro-s9x" ]; then
      echo "=== Building SNES9x ==="
      cd libretro-s9x/
      cd libretro/jni
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/vba_next_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/vba_next_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/vba_next_libretro${FORMAT}.${FORMAT_EXT}
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/fceumm_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/fceumm_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/fceumm_libretro${FORMAT}.${FORMAT_EXT}
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI=armeabi-v7a
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/modelviewer_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/modelviewer_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/modelviewer_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "ModelViewer not fetched, skipping ..."
   fi
}

build_libretro_instancingviewer()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-instancingviewer" ]; then
      echo "=== Building InstancingViewer (GL) ==="
      cd libretro-gl-instancingviewer
      cd jni
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
      ndk-build -j$JOBS APP_ABI="armeabi-v7a mips x86"
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/instancingviewer_camera_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo "InstancingViewer Camera not fetched, skipping ..."
   fi
}

build_libretro_scenewalker()
{
   cd $BASE_DIR
   if [ -d "libretro-gl-scenewalker" ]; then
      echo "=== Building SceneWalker (GL) ==="
      cd libretro-gl-scenewalker
      cd jni
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI=armeabi-v7a
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      cd libretro-desmume
      cd jni
      ndk-build clean
      ndk-build -j$JOBS APP_ABI=armeabi-v7a
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/desmume_libretro${FORMAT}.${FORMAT_EXT}

      ndk-build clean
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
      ndk-build clean APP_ABI="armeabi-v7a mips x86"
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
      ndk-build clean APP_ABI="armeabi-v7a x86"
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
      ndk-build clean APP_ABI="armeabi-v7a"
      ndk-build -j$JOBS APP_ABI="armeabi-v7a"
      cp ../libs/armeabi-v7a/libretro_mupen64plus.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/mupen64plus_libretro${FORMAT}.${FORMAT_EXT}
   else
      echo 'Mupen64 Plus not fetched, skipping ...'
   fi
}

create_dist_dir

if [ $1 ]; then
   $1
else
   #build_libretro_bsnes_cplusplus98
   build_libretro_bsnes
   build_libretro_mednafen
   #build_libretro_mednafen_gba
   #build_libretro_mednafen_snes
   #build_libretro_mednafen_psx
   build_libretro_s9x
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba_full
   build_libretro_vbam
   build_libretro_vba_next
   #build_libretro_bnes
   build_libretro_fceu
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
   build_libretro_dinothawr
fi
