display_usage() { 
   echo -e "\nSetup a RetroArch PS2 build environment on Debian/Ubuntu" 
   echo -e "\nUsage: [install] [build] [export]\n" 
   echo -e "It will install the toolchain in ~/tools\n"
   echo -e "Arguments:\n"
   echo -e "install:\n install or re(install) the toolchain"
   echo -e "prepare-profile:\n update the bash profile with the needed variables"
   echo -e "export-variables:\n Export in this bash session the needed variables"
} 

update-profile()
{
   echo "" >> ~/.profile
   echo "#### PS2DEV ####" >> ~/.profile
   echo "export PS2DEV=~/tools/ps2dev" >> ~/.profile
   echo "export PS2SDK=\$PS2DEV/ps2sdk" >> ~/.profile
   echo "export PATH=\$PATH:\$PS2DEV/bin:\$PS2DEV/ee/bin:\$PS2DEV/iop/bin:\$PS2DEV/dvp/bin:\$PS2SDK/bin" >> ~/.profile
   
   #load profile
   source ~/.profile
}

export-variables()
{
   export PS2DEV=~/tools/ps2dev
   export PS2SDK=$PS2DEV/ps2sdk
   export PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin
}

download-ps2toolchain()
{
   # PS2Toolchain
   cd ~
   if [ ! -d ~/ps2tools/ps2toolchain ]; then
      mkdir ~/ps2tools
      cd ps2tools
      git clone https://github.com/ps2dev/ps2toolchain.git
   fi
}

download-ps2sdk-ports()
{
   #PS2SDK-Ports
   cd ~
   if [ ! -d ~/ps2tools/ps2sdk-ports ]; then
      mkdir ~/ps2tools
      cd ps2tools
      git clone https://github.com/ps2dev/ps2sdk-ports.git
   fi
}

download-gskit()
{
   #GSKit
   cd ~
   if [ ! -d ~/ps2tools/gskit ]; then
      mkdir ~/ps2tools
      cd ps2tools
      git clone https://github.com/ps2dev/gsKit.git
   fi
}

download-ps2-packer()
{
   #PS2-Packer
   cd ~
   if [ ! -d ~/ps2tools/ps2-packer ]; then
      mkdir ~/ps2tools
      cd ps2tools
      git clone https://github.com/ps2dev/ps2-packer.git
   fi
}

install-ps2toolchain()
{
   if [ ! -d ~/ps2tools/ps2toolchain ]; then
      echo You need to donwload first the ps2toolchain
   fi

   cd ~/ps2tools/ps2toolchain
   git fetch && git pull
   ./toolchain.sh
}

install-ps2sdk-ports()
{
   if [ ! -d ~/ps2tools/ps2sdk-ports ]; then
      echo You need to donwload first the ps2sdk-ports
   fi

   cd ~/ps2tools/ps2sdk-ports
   git fetch && git pull
   make clean && make && make install
}

install-gskit()
{
   if [ ! -d ~/ps2tools/gskit ]; then
      echo You need to donwload first the gskit
   fi

   cd ~/ps2tools/gskit
   git fetch && git pull
   make clean && make && make install
}

install-ps2-packer()
{
   if [ ! -d ~/ps2tools/ps2-packer ]; then
      echo You need to donwload first the ps2-packer
   fi

   cd ~/ps2tools/ps2-packer
   git fetch && git pull
   make clean && make && make install
}

#!/bin/bash
platform=ps2

if [ "$1" = "prepare-profile" ]; then
   mkdir -p ~/tools/ps2dev
   export-variables
fi;

if [ "$1" = "export-variables" ]; then
   mkdir -p ~/tools/ps2dev
   update-profile
fi;

if [ "$1" = "install" ]; then
   
   #load profile
   source ~/.profile

   if [ -z ${PS2DEV+x} ]; then
      echo $platform variables not found, run first either prepare-profile or export-variables...
   else
      # Install needed dependencies
      sudo apt install -yqqq build-essential git p7zip tar wget patch libucl-dev
      sudo apt install -yqqq libucl-dev zlib1g-dev

      #Download everything
      download-ps2toolchain
      download-ps2sdk-ports
      download-gskit
      download-ps2-packer

      #install everything
      install-ps2toolchain
      install-ps2sdk-ports
      install-gskit
      install-ps2-packer

      echo $platform environment ready...
   fi
   
fi;

if [ $# -le 0 ]; then 
   display_usage
fi
