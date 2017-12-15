display_usage() { 
	echo "Usage: [install] [build]" 
	echo -e "It will install the toolchain in /home/buildbot/tools\n"
	echo -e "Arguments:\n"
	echo -e "install:\n install or re(install) the toolchain"
	echo -e "build:\n update the source tree and build everything"

} 

#!/bin/bash

export PATH=$PATH:/home/buildbot/tools/devkitpro/devkitPSP/bin/
export DEVKITPRO=/home/buildbot/tools/devkitpro/
export DEVKITPSP=/home/buildbot/tools/devkitpro/devkitPSP/
export platform=psp1
export PLATFORM=psp1
export CC=psp-gcc
export CXX=psp-g++

cd ~

if [ "$1" = "install" ]; then
   if [[ "$MSYSTEM" == *"MINGW64"* ]]; then
      pacman -S git make p7zip tar wget

      mkdir -p /home/buildbot/tools/devkitpro
      cd /home/buildbot/tools/devkitpro
      wget https://bot.libretro.com/.dev/psp/devkitPSP_r16-1-x86_64-win.tar.gz
      tar zxvf devkitPSP_r16-1-x86_64-win.tar.gz
      rm devkitPSP_r16-1-x86_64-win.tar.gz

      cd ~
      mkdir libretro
      cd libretro
      git clone https://github.com/libretro/libretro-super.git psp

   else
      apt install build-essential git p7zip tar wget

      mkdir -p tools/devkitpro
      cd tools/devkitpro
      wget https://bot.libretro.com/.dev/psp/devkitPSP_r16-1-x86_64-linux.tar.bz2
      tar jxvf devkitPSP_r16-1-x86_64-linux.tar.bz2
      rm devkitPSP_r16-1-x86_64-linux.tar.bz2

      cd ~
      mkdir libretro
      cd libretro
      git clone https://github.com/libretro/libretro-super.git psp

      cd ~
      sudo mkdir -p /home/buildbot
      sudo ln -s ~/tools /home/buildbot/tools

   fi;
fi;

if [ "$1" = "build" ]; then
   cd ~/libretro/psp
   git pull
   ./libretro-buildbot-recipe.sh recipes/playstation/psp
fi;

if [  $# -le 1 ]; then 
   display_usage
fi
