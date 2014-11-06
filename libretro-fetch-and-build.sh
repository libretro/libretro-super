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

echo
[[ "${ARM_NEON}" ]] && echo 'ARM NEON opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
[[ "${CORTEX_A8}" ]] && echo 'Cortex A8 opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
[[ "${CORTEX_A9}" ]] && echo 'Cortex A9 opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo 'ARM hardfloat ABI enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo 'ARM softfloat ABI enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"
[[ "${IOS}" ]] && echo 'iOS detected...'

echo "${FORMAT_COMPILER_TARGET}"
echo "${FORMAT_COMPILER_TARGET_ALT}"


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

RESET_FORMAT_COMPILER_TARGET=$FORMAT_COMPILER_TARGET
RESET_FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET_ALT

check_opengl() {
   if [ "${BUILD_LIBRETRO_GL}" ]; then
      if [ "${ENABLE_GLES}" ]; then
         echo '=== OpenGL ES enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
         export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
      else
         echo '=== OpenGL enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
         export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
      fi
   else
      echo '=== OpenGL disabled in build ==='
   fi
}

reset_compiler_targets() {
   export FORMAT_COMPILER_TARGET=$RESET_FORMAT_COMPILER_TARGET
   export FORMAT_COMPILER_TARGET_ALT=$RESET_FORMAT_COMPILER_TARGET_ALT
}



cd "${BASE_DIR}"

####build commands
build_libretro_generic_makefile() {


    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    ARGS=$6

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
    if [ -z ${ARGS} ];
    then
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}
    fi

    if [ $? -eq 0 ];
    then 
        echo success!
        cp ${NAME}_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro$FORMAT.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi
	
}

build_libretro_generic_gl_makefile() {


    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    ARGS=$6

    cd $DIR
    cd $SUBDIR

    check_opengl

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
    if [ -z ${ARGS} ];
    then
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}
    fi

    if [ $? -eq 0 ];
    then 
        echo success!
        cp ${NAME}_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro$FORMAT.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi

    reset_compiler_targets
	
}

#fetch a project and mark it for building if there have been any changes

#sleep 10
echo
echo

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
	echo
	echo

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
		    build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
            elif [ "${COMMAND}" == "GL" ]; then
                    build_libretro_generic_gl_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"

	    fi
	else
	    echo core already up-to-date...
	fi
        echo

    fi
    
    cd "${BASE_DIR}"
    

done  < $1

