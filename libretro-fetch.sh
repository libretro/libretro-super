#!/bin/bash

. ./libretro-config.sh

# Keep three copies so we don't have to rebuild stuff all the time.
fetch_project_bsnes()
{
   echo "=== Fetching $3 ==="
   if [ -d "$2" ]; then
      cd "$2"
      git pull
      cd ..
   else
      git clone $1 "$2"
   fi

   if [ -d "$2" ]; then
      cd "$2"

      if [ -d "perf" ]; then
         cd perf
         git pull ..
         cd ..
      else
         git clone . perf
      fi

      if [ -d "balanced" ]; then
         cd balanced
         git pull ..
         cd ..
      else
         git clone . balanced
      fi

      cd ..
   fi
}

fetch_project()
{
   echo "=== Fetching $3 ==="
   if [ -d "$2" ]; then
      cd "$2"
      git pull
      cd ..
   else
      git clone "$1" "$2"
   fi
   echo "=== Fetched ==="
}

fetch_project_submodule()
{
   echo "=== Fetching $3 ==="
   if [ -d "$2" ]; then
      cd "$2"
      git pull
      cd ..
   else
      git clone "$1" "$2"
   cd "$2"
   git submodule update --init
   cd ..
   fi
   echo "=== Fetched ==="
}

if [ -z $WRITERIGHTS ]; then
   REPO_BASE="https://github.com"
else
   REPO_BASE="git://github.com"
fi

fetch_project "$REPO_BASE/libretro/RetroArch.git" "retroarch" "libretro/RetroArch"

fetch_project_bsnes "git://gitorious.org/bsnes/bsnes.git --branch libretro" "libretro-bsnes" "libretro/bSNES"
fetch_project "$REPO_BASE/libretro/snes9x.git" "libretro-s9x" "libretro/SNES9x"
fetch_project "$REPO_BASE/libretro/snes9x-next.git" "libretro-s9x-next" "libretro/SNES9x-Next"
fetch_project "$REPO_BASE/libretro/Genesis-Plus-GX.git" "libretro-genplus" "libretro/Genplus GX"
fetch_project "$REPO_BASE/libretro/fba-libretro.git" "libretro-fba" "libretro/FBA"
fetch_project "$REPO_BASE/libretro/vba-next.git" "libretro-vba-next" "libretro/VBA Next"
fetch_project "$REPO_BASE/libretro/vbam-libretro.git" "libretro-vbam" "libretro/VBA-M"
fetch_project "$REPO_BASE/libretro/libretro-handy.git" "libretro-handy" "libretro/Handy"
fetch_project "$REPO_BASE/libretro/bnes-libretro.git" "libretro-bnes" "libretro/bNES"
fetch_project "$REPO_BASE/libretro/fceu-next.git" "libretro-fceu" "libretro/FCEU"
fetch_project "$REPO_BASE/libretro/gambatte-libretro.git" "libretro-gambatte" "libretro/Gambatte"
fetch_project "$REPO_BASE/libretro/meteor-libretro.git" "libretro-meteor" "libretro/Meteor"
fetch_project "$REPO_BASE/libretro/nxengine-libretro.git" "libretro-nx" "libretro/NX"
fetch_project "$REPO_BASE/libretro/libretro-prboom.git" "libretro-prboom" "libretro/PRBoom"
fetch_project "$REPO_BASE/libretro/stella-libretro.git" "libretro-stella" "libretro/Stella"
fetch_project "$REPO_BASE/libretro/desmume-libretro.git" "libretro-desmume" "libretro/Desmume"
fetch_project "$REPO_BASE/libretro/QuickNES_Core.git" "libretro-quicknes" "libretro/QuickNES"
fetch_project "$REPO_BASE/libretro/nestopia.git" "libretro-nestopia" "libretro/Nestopia"
fetch_project "$REPO_BASE/libretro/tyrquake.git" "libretro-tyrquake" "libretro/tyrquake"
fetch_project "$REPO_BASE/libretro/pcsx_rearmed.git" "libretro-pcsx-rearmed" "libretro/pcsx_rearmed"
fetch_project "$REPO_BASE/libretro/mednafen-libretro.git" "libretro-mednafen" "libretro/Mednafen"
fetch_project "$REPO_BASE/libretro/scummvm.git" "libretro-scummvm" "libretro/scummvm"
fetch_project "$REPO_BASE/libretro/yabause.git" "libretro-yabause" "libretro/yabause"
fetch_project "$REPO_BASE/libretro/dosbox-libretro.git" "libretro-dosbox" "libretro/dosbox"
fetch_project "$REPO_BASE/libretro/virtualjaguar-libretro.git" "libretro-virtualjaguar" "libretro/virtualjaguar"
fetch_project "$REPO_BASE/libretro/mame2003-libretro.git" "libretro-mame078" "libretro/mame078"
fetch_project "$REPO_BASE/libretro/mame2010-libretro.git" "libretro-mame139" "libretro/mame139"
fetch_project "$REPO_BASE/libretro/mame-libretro.git" "libretro-mame" "libretro/mame"
fetch_project "$REPO_BASE/libretro/scenewalker-libretro.git" "libretro-gl-scenewalker" "libretro/SceneWalker"
fetch_project "$REPO_BASE/libretro/modelviewer-libretro.git" "libretro-gl-modelviewer" "libretro/ModelViewer"
fetch_project "$REPO_BASE/libretro/modelviewer-location-libretro.git" "libretro-gl-modelviewer-location" "libretro/ModelViewer-Location"
fetch_project "$REPO_BASE/libretro/libretro-ffmpeg.git" "libretro-ffmpeg" "libretro/ffmpeg"
fetch_project "$REPO_BASE/libretro/bsnes-libretro-cplusplus98.git" "libretro-bsnes-cplusplus98" "libretro/bsnes-cplusplus98"
fetch_project_submodule "$REPO_BASE/libretro/picodrive.git" "libretro-picodrive" "libretro/picodrive"
fetch_project_submodule "$REPO_BASE/libretro/ppsspp-libretro.git" "libretro-pppsspp" "libretro/ppsspp"
fetch_project "$REPO_BASE/libretro/tgbdual-libretro.git" "libretro-tgbdual" "libretro/tgbdual"
fetch_project "$REPO_BASE/libretro/mupen64plus-libretro.git" "libretro-mupen64plus" "libretro/mupen64plus"
fetch_project "$REPO_BASE/libretro/instancingviewer-libretro-gl.git" "libretro-gl-instancingviewer" "libretro/instancingviewer"
fetch_project "$REPO_BASE/libretro/instancingviewer-camera.git" "libretro-gl-instancingviewer-camera" "libretro/instancingviewer-camera"
fetch_project "$REPO_BASE/libretro/Dinothawr.git" "libretro-dinothawr" "libretro/Dinothawr"
fetch_project "$REPO_BASE/libretro/libretro-hatari.git" "libretro-hatari" "libretro/Hatari"
fetch_project "$REPO_BASE/libretro/libretro-uae.git" "libretro-uae" "libretro/UAE"
fetch_project "$REPO_BASE/libretro/libretro-3dengine.git" "libretro-3dengine" "libretro/3DEngine"
fetch_project "$REPO_BASE/libretro/libretro-remotejoy.git" "libretro-remotejoy" "libretro/RemoteJoy"
