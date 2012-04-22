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
      git clone "$1" "$2"
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

      if [ -d "compat" ]; then
         cd perf
         git pull ..
         cd ..
      else
         git clone . compat
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

REPO_BASE="git://github.com"

fetch_project_bsnes "$REPO_BASE/Themaister/bsnes-libretro.git" "libretro-bsnes" "libretro/bSNES"
fetch_project "$REPO_BASE/snes9xgit/snes9x.git" "libretro-s9x" "libretro/SNES9x"
fetch_project "$REPO_BASE/twinaphex/snes9x-next.git" "libretro-s9x-next" "libretro/SNES9x-Next"
fetch_project "$REPO_BASE/twinaphex/genesis-next.git" "libretro-genplus" "libretro/Genplus GX"
fetch_project "$REPO_BASE/twinaphex/fba-libretro.git" "libretro-fba" "libretro/FBA"
fetch_project "$REPO_BASE/twinaphex/vba-next.git" "libretro-vba" "libretro/VBA"
fetch_project "$REPO_BASE/Themaister/bnes-libretro.git" "libretro-bnes" "libretro/bNES"
fetch_project "$REPO_BASE/twinaphex/fceu-next.git" "libretro-fceu" "libretro/FCEU"
fetch_project "$REPO_BASE/Themaister/gambatte-libretro.git" "libretro-gambatte" "libretro/Gambatte"
fetch_project "$REPO_BASE/Themaister/meteor-libretro.git" "libretro-meteor" "libretro/Meteor"
fetch_project "$REPO_BASE/twinaphex/nxengine-libretro.git" "libretro-nx" "libretro/NX"

