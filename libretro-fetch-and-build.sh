#!/bin/bash

####usage:
# ./libretro-fetch-and-build.sh configfile
# if you want to force all enabled cores to rebuild prepend FORCE=YES
# you may need to specify your make command by prepending it to the commandline, for instance MAKE=mingw32-make
#
# eg: FORCE=YES MAKE=mingw32-make ./libretro-fetch-and-build.sh buildbot.conf

####environment configuration:
echo configuring build environment
. ./libretro-config.sh

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
echo "SCRIPT: $SCRIPT"
BASE_DIR=$(dirname "$SCRIPT")
if [ -z "$RARCH_DIST_DIR" ]; then
    RARCH_DIR="$BASE_DIR/dist"
    RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi

mkdir -p "$RARCH_DIST_DIR"

if [ "$HOST_CC" ]; then
    CC="${HOST_CC}-gcc"
    CXX="${HOST_CC}-g++"
    CXX11="${HOST_CC}-g++"
    STRIP="${HOST_CC}-strip"
fi


if [ -z "$MAKE" ]; then
   if uname -s | grep -i MINGW32 > /dev/null 2>&1; then
      MAKE=mingw32-make
   else
      if type gmake > /dev/null 2>&1; then
         MAKE=gmake
      else
         MAKE=make
      fi
   fi
fi


if [ -z "$CC" ]; then
   if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
      CC=cc
   elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
      CC=mingw32-gcc
   else
      CC=gcc
   fi
fi

if [ -z "$CXX" ]; then
   if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
      CXX=c++
      CXX11="clang++ -std=c++11 -stdlib=libc++"
   elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
      CXX=mingw32-g++
      CXX11=mingw32-g++
   else
      CXX=g++
      CXX11=g++
   fi
fi

echo
echo "CC = $CC"
echo "CXX = $CXX"
echo "STRIP = $STRIP"
echo

cd "${BASE_DIR}"

####build commands
build_libretro_generic_makefile() {


    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    SILENT=$5

    cd $DIR
    cd $SUBDIR

    if [ -z "${NOCLEAN}" ]; 
    then
	echo "cleaning up..."
        echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} clean"
	${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} clean
	if [ $? -eq 0 ];
        then 
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."
    echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS}"
    ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS}
    if [ $? -eq 0 ];
    then 
        echo success!
        cp ${NAME}_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro$FORMAT.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi
	
}


#fetch a project and mark it for building if there have been any changes

while read line; do
    
    NAME=`echo $line | cut --fields=1 --delimiter=" "`
    DIR=`echo $line | cut --fields=2 --delimiter=" "`
    URL=`echo $line | cut --fields=3 --delimiter=" "`
    TYPE=`echo $line | cut --fields=4 --delimiter=" "`
    ENABLED=`echo $line | cut --fields=5 --delimiter=" "`
    COMMAND=`echo $line | cut --fields=6 --delimiter=" "`
    MAKEFILE=`echo $line | cut --fields=7 --delimiter=" "`
    SUBDIR=`echo $line | cut --fields=8 --delimiter=" "`
   
    if [ "${ENABLED}" == "YES" ];
    then
        echo "Processing $NAME"
        echo ============================================
	echo URL: $URL
        echo REPO TYPE: $TYPE
	echo ENABLED: $ENABLED
        echo COMMAND: $COMMAND
   	echo MAKEFILE: $MAKEFILE
	echo
 	echo

        ARGS=""

        TEMP=`echo $line | cut --fields=9 --delimiter=" "`
        if [ -n ${TEMP} ];
        then
           ARGS="${TEMP}"
        fi
        TEMP=""
        TEMP=`echo $line | cut --fields=10 --delimiter=" "`
        if [ -n ${TEMP} ];
        then
           ARGS="${ARGS} ${TEMP}"
        fi
        TEMP=""
        TEMP=`echo $line | cut --fields=11 --delimiter=" "`
        if [ -n ${TEMP} ];
        then
           ARGS="${ARGS} ${TEMP}"
        fi

        echo ARGS: $ARGS

        if [ -d "${DIR}/.git" ];
        then
            cd $DIR
            echo "pulling from repo... "
            OUT=`git pull`
            if [[ $OUT == *"Already up-to-date"* ]]
            then
                BUILD="NO"
	    else
		BUILD="YES"
            fi

            cd ..

	else
            echo "cloning repo..."
            git clone --depth=1 "$URL" "$DIR"
            BUILD="YES"
        fi

        if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ];
	then
	    echo building core...
	    if [ "${COMMAND}" == "GENERIC" ]; then
		    build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET}
	    fi
	else
	    echo core already up-to-date...
	fi

    fi
    
    cd "${BASE_DIR}"

done  < $1

