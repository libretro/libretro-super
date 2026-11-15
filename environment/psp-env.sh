display_usage() { 
   echo -e "\nSetup a RetroArch PSP build environment on Debian/Ubuntu or MSYS2 (MINGW64 only)" 
   echo -e "\nUsage: [install] [build] [export]\n" 
   echo -e "It will install the toolchain in /home/buildbot/tools\n"
   echo -e "Arguments:\n"
   echo -e "install:\n install or re(install) the toolchain"
   echo -e "build:\n update the source tree and build everything"
   echo -e "export:\n setup the environment for local building, run with source psp-env.sh"
} 

fetch()
{
   cd ~
   if [ ! -d ~/libretro/psp ]; then
      mkdir libretro
      cd libretro
      git clone https://github.com/libretro/libretro-super.git psp
   fi
}

#!/bin/bash
platform=psp1

if [ "$1" = "install" ]; then
   if [[ "$MSYSTEM" == *"MINGW64"* ]]; then

      pacman -S git make p7zip tar wget

      mkdir -p /home/buildbot/tools/devkitpro
      cd /home/buildbot/tools/devkitpro
      wget https://bot.libretro.com/.dev/psp/devkitPSP_r16-1-x86_64-win.tar.gz
      tar zxvf devkitPSP_r16-1-x86_64-win.tar.gz
      rm devkitPSP_r16-1-x86_64-win.tar.gz

      fetch 
   else

      sudo apt install build-essential git p7zip tar wget

      mkdir -p tools/devkitpro
      cd tools/devkitpro
      wget https://bot.libretro.com/.dev/psp/devkitPSP_r16-1-x86_64-linux.tar.bz2
      tar jxvf devkitPSP_r16-1-x86_64-linux.tar.bz2
      rm devkitPSP_r16-1-x86_64-linux.tar.bz2

      fetch 

      if [ ! -d "/home/buildbot/tools" ]; then
         sudo mkdir -p /home/buildbot
         sudo ln -s ~/tools /home/buildbot/tools
      fi;
   fi;
   echo $platform environment ready...
fi;

if [ "$1" = "build" ]; then
   if [ -d "/home/buildbot/tools/devkitpro/" ]; then
      cd ~/libretro/psp
      git pull
      ./libretro-buildbot-recipe.sh recipes/playstation/psp
   else
      echo $platform environment not found, run with install again...
   fi
fi;

if [ "$1" = "export" ]; then
   if [ -d "/home/buildbot/tools/devkitpro/" ]; then
      export PATH=$PATH:/home/buildbot/tools/devkitpro/devkitPSP/bin/
      export DEVKITPRO=/home/buildbot/tools/devkitpro/
      export DEVKITPSP=/home/buildbot/tools/devkitpro/devkitPSP/
      export platform=psp1
      export PLATFORM=psp1
      export CC=psp-gcc
      export CXX=psp-g++
      echo $platform environment ready...
   else
      echo $platform environment not found, run with install again...
   fi;
fi

if [ $# -le 0 ]; then 
   display_usage
fi

