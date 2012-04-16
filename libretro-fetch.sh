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

fetch_project_bsnes "$REPO_BASE/Themaister/libsnes.git" "libsnes" "libsnes/bSNES"
fetch_project "$REPO_BASE/Themaister/snes9x-libsnes.git" "libsnes-s9x" "libsnes/SNES9x"
fetch_project "$REPO_BASE/twinaphex/snes9x-next.git" "libsnes-s9x-next" "libsnes/SNES9x-Next"
fetch_project "$REPO_BASE/twinaphex/genesis-next.git" "libsnes-genplus" "libsnes/Genplus GX"
fetch_project "$REPO_BASE/twinaphex/fba-next-slim.git" "libsnes-fba" "libsnes/FBA"
fetch_project "$REPO_BASE/twinaphex/vba-next.git" "libsnes-vba" "libsnes/VBA"
fetch_project "$REPO_BASE/Themaister/bnes-libsnes.git" "libsnes-bnes" "libsnes/bNES"
fetch_project "$REPO_BASE/twinaphex/fceu-next.git" "libsnes-fceu" "libsnes/FCEU"
fetch_project "$REPO_BASE/Themaister/gambatte-libsnes.git" "libsnes-gambatte" "libsnes/Gambatte"
fetch_project "git://git.code.sf.net/p/meteorgba/code.git" "libsnes-meteor" "libsnes/Meteor"

