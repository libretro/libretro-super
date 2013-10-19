#!/bin/sh

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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_mednafen_ngp.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_mednafen_ngp.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_mednafen_ngp.${FORMAT_EXT}

      echo "=== Building Mednafen WonderSwan ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_wswan"
      ndk-build core=wswan -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_wswan"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_mednafen_wswan.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_mednafen_wswan.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_mednafen_wswan.${FORMAT_EXT}

      echo "=== Building Mednafen VirtualBoy ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_vb"
      ndk-build core=vb clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_vb"
      ndk-build core=vb -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_vb"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_mednafen_vb.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_mednafen_vb.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_mednafen_vb.${FORMAT_EXT}

      echo "=== Building Mednafen PCE Fast ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_pce_fast"
      ndk-build core=pce-fast -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_pce_fast"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_mednafen_pce_fast.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_mednafen_pce_fast.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_mednafen_pce_fast.${FORMAT_EXT}

      echo "=== Building Mednafen PSX ==="
      ndk-build clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_psx"
      ndk-build core=psx clean APP_ABI="armeabi-v7a mips x86" || die "Failed to clean mednafen_psx"
      ndk-build core=psx -j$JOBS APP_ABI="armeabi-v7a mips x86" || die "Failed to build mednafen_psx"

      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_mednafen_psx.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_mednafen_psx.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_mednafen_psx.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_snes9x.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_snes9x.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_snes9x.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_snes9x_next.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_snes9x_next.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_snes9x_next.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_stella.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_stella.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_stella.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_genesis_plus_gx.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_genesis_plus_gx.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_genesis_plus_gx.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_fba.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_fba.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_fba.${FORMAT_EXT}
   else
      echo "Final Burn Alpha not fetched, skipping ..."
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_vba_next.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_vba_next.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_vba_next.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_fceumm.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_fceumm.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_fceumm.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_gambatte.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_gambatte.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_gambatte.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_nxengine.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_nxengine.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_nxengine.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_prboom.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_prboom.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_prboom.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_dinothawr.${FORMAT_EXT}
      cp ../libs/mips/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_dinothawr.${FORMAT_EXT}
      cp ../libs/x86/libretro_dino.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_dinothawr.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_nestopia.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_nestopia.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_nestopia.${FORMAT_EXT}
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
      ndk-build clean APP_ABI=armeabi-v7a
      ndk-build -j$JOBS NO_NEON=1 APP_ABI=armeabi-v7a
      cp ../libs/armeabi-v7a/libretro-noneon.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_pcsx_rearmed.${FORMAT_EXT}
      ndk-build clean APP_ABI=armeabi-v7a
      ndk-build -j$JOBS APP_ABI=armeabi-v7a
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_pcsx_rearmed-neon.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_tyrquake.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_tyrquake.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_tyrquake.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_modelviewer.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_modelviewer.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_modelviewer.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_instancingviewer.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_instancingviewer.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_instancingviewer.${FORMAT_EXT}
   else
      echo "InstancingViewer not fetched, skipping ..."
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_scenewalker.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/mips/libretro_scenewalker.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_scenewalker.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro_picodrive.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/libretro_picodrive.${FORMAT_EXT}
   else
      echo "Picodrive not fetched, skipping ..."
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/libretro_desmume.${FORMAT_EXT}

      ndk-build clean
      ndk-build -j$JOBS APP_ABI=x86
      cp ../libs/x86/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/x86/libretro_desmume.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/armeabi-v7a/libretro_quicknes.${FORMAT_EXT}
      cp ../libs/mips/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/mips/libretro_quicknes.${FORMAT_EXT}
      cp ../libs/x86/libretro.${FORMAT_EXT} "$RARCH_DIST_DIR"/x86/libretro_quicknes.${FORMAT_EXT}
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

build_libretro_bsnes_performance()
{
   cd $BASE_DIR
   if [ -d "libretro-bsnes" ]; then
      echo "=== Building bsnes (performance core) ==="
      cd libretro-bsnes/perf
      cd target-libretro/jni
      ndk-build clean APP_ABI="armeabi-v7a x86"
      ndk-build -j$JOBS APP_ABI="armeabi-v7a x86"
      cp ../libs/armeabi-v7a/libretro_bsnes_performance.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_bsnes_performance.${FORMAT_EXT}
      cp ../libs/x86/libretro_bsnes_performance.${FORMAT_EXT} $RARCH_DIST_DIR/x86/libretro_bsnes_performance.${FORMAT_EXT}
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
      cp ../libs/armeabi-v7a/libretro_mupen64plus.${FORMAT_EXT} $RARCH_DIST_DIR/armeabi-v7a/libretro_mupen64plus.${FORMAT_EXT}
   else
      echo 'Mupen64 Plus not fetched, skipping ...'
   fi
}

create_dist_dir

if [ $1 ]; then
   $1
else
   build_libretro_pcsx_rearmed
   build_libretro_mednafen
   build_libretro_s9x
   build_libretro_s9x_next
   build_libretro_genplus
   build_libretro_fba_full
   build_libretro_vba_next
   build_libretro_fceu
   build_libretro_gambatte
   build_libretro_nx
   build_libretro_prboom
   build_libretro_stella
   build_libretro_quicknes
   build_libretro_desmume
   build_libretro_nestopia
   build_libretro_tyrquake
   build_libretro_modelviewer
   build_libretro_instancingviewer
   build_libretro_scenewalker
   build_libretro_picodrive
   build_libretro_bsnes_performance
   build_libretro_mupen64
   build_libretro_dinothawr
fi
