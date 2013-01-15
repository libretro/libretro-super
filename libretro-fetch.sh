#!/bin/sh


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

fetch_project_mednafen()
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
      for core in psx pce-fast wswan
      do
         if [ -d "$core" ]; then
            cd $core
            git pull ..
            cd ..
         else
            git clone . $core
         fi
      done
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

REPO_BASE="git://github.com"

fetch_project_bsnes "git://gitorious.org/bsnes/bsnes.git --branch libretro" "libretro-bsnes" "libretro/bSNES"
fetch_project "$REPO_BASE/snes9xgit/snes9x.git" "libretro-s9x" "libretro/SNES9x"
fetch_project "$REPO_BASE/libretro/snes9x-next.git" "libretro-s9x-next" "libretro/SNES9x-Next"
fetch_project "$REPO_BASE/libretro/Genesis-Plus-GX.git" "libretro-genplus" "libretro/Genplus GX"
fetch_project "$REPO_BASE/libretro/fba-libretro.git" "libretro-fba" "libretro/FBA"
fetch_project "$REPO_BASE/libretro/vba-next.git" "libretro-vba" "libretro/VBA"
fetch_project "$REPO_BASE/libretro/bnes-libretro.git" "libretro-bnes" "libretro/bNES"
fetch_project "$REPO_BASE/libretro/fceu-next.git" "libretro-fceu" "libretro/FCEU"
fetch_project "$REPO_BASE/libretro/gambatte-libretro.git" "libretro-gambatte" "libretro/Gambatte"
fetch_project "$REPO_BASE/libretro/meteor-libretro.git" "libretro-meteor" "libretro/Meteor"
fetch_project "$REPO_BASE/libretro/nxengine-libretro.git" "libretro-nx" "libretro/NX"
fetch_project "$REPO_BASE/libretro/libretro-prboom.git" "libretro-prboom" "libretro/PRBoom"
fetch_project "$REPO_BASE/libretro/stella-libretro.git" "libretro-stella" "libretro/Stella"
fetch_project "$REPO_BASE/libretro/desmume-libretro.git" "libretro-desmume" "libretro/Desmume"
fetch_project "$REPO_BASE/libretro/QuickNES_Core.git" "libretro-quicknes" "libretro/QuickNES"
fetch_project_mednafen "$REPO_BASE/libretro/mednafen-libretro.git" "libretro-mednafen" "libretro/Mednafen"

