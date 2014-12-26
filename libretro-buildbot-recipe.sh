#!/bin/bash

####usage:
# ./libretro-fetch-and-build.sh configfile
# if you want to force all enabled cores to rebuild prepend FORCE=YES
# you may need to specify your make command by prepending it to the commandline, for instance MAKE=mingw32-make
#
# eg: FORCE=YES MAKE=mingw32-make ./libretro-fetch-and-build.sh buildbot

####environment configuration:
echo "Setting up Environment for $1"
echo ============================================

ORIGPATH=$PATH
WORK=$PWD

echo Original PATH: $PATH

while read line; do
    KEY=`echo $line | cut --fields=1 --delimiter=" "`
    VALUE=`echo $line | cut --fields=2 --delimiter=" "`

    if [ "${KEY}" == "PATH" ];
    then
        export PATH=${VALUE}:${ORIGPATH}
        echo New PATH: $PATH

    else
        export ${KEY}=${VALUE}
        echo $KEY: $VALUE
    fi
done  < $1.conf
echo
echo

. ./libretro-config.sh

echo
[[ "${ARM_NEON}" ]] && echo 'ARM NEON opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
[[ "${CORTEX_A8}" ]] && echo 'Cortex A8 opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
[[ "${CORTEX_A9}" ]] && echo 'Cortex A9 opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo 'ARM hardfloat ABI enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo 'ARM softfloat ABI enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"
[[ "${IOS}" ]] && echo 'iOS detected...'

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

if [ "${PLATFORM}" == "android" ];
then

IFS=' ' read -ra ABIS <<< "$TARGET_ABIS"
   for a in "${ABIS[@]}"; do
   echo $a
      if [ -d $RARCH_DIST_DIR/${a} ]; then
         echo "Directory $RARCH_DIST_DIR/${a} already exists, skipping creation..."
      else
         mkdir $RARCH_DIST_DIR/${a}
      fi
   done
fi

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

if [ "${CC}" ] && [ "${CXX}" ]; then
   COMPILER="CC=${CC} CXX=${CXX}"
else
   COMPILER=""
fi

echo
echo "CC = $CC"
echo "CXX = $CXX"
echo "STRIP = $STRIP"
echo "COMPILER = $COMPILER"
echo

export CC=$CC
export CXX=$CXX

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
        echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean"
	${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean
	if [ $? -eq 0 ];
        then 
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."
    if [ -z "${ARGS}" ]
    then
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
    fi

    if [ $? -eq 0 ];
    then 
        echo success!
        cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi

}

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
        echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean"
	${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean
	if [ $? -eq 0 ];
        then 
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."
    if [ -z "${ARGS}" ]
    then
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
    fi

    if [ $? -eq 0 ];
    then
        echo success!
        cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi

}

build_libretro_generic_theos() {

    echo PARAMETERS: DIR $2, SUBDIR: $3, MAKEFILE: $4

    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    ARGS=$6

    cd $DIR
    cd $SUBDIR

    ln -s $THEOS theos


    if [ -z "${NOCLEAN}" ];
    then
	echo "cleaning up..."
        echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean"
	${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean
	if [ $? -eq 0 ];
        then
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."
    if [ -z "${ARGS}" ]
    then
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
    fi

    if [ $? -eq 0 ];
    then
        echo success!
        cp -v objs/obj/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi

}

build_libretro_generic_jni() {

    echo PARAMETERS: DIR $2, SUBDIR: $3

    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    ARGS=$6

    cd ${DIR}/${SUBDIR}

    for a in "${ABIS[@]}"; do
        if [ -z "${NOCLEAN}" ]; 
        then
	    echo "cleaning up..."
	    echo "cleanup command: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean"
	        ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean
	        if [ $? -eq 0 ];
	    then 
	        echo success!
	    else
	        echo error while cleaning up
	    fi
        fi

	echo "compiling for ${a}..."
        if [ -z "${ARGS}" ]
        then
	    echo "buid command: ${NDK} -j${JOBS} APP_ABI=${a}"
	    ${NDK} -j${JOBS} APP_ABI=${a}
        else
	    echo "buid command: ${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} "
	    ${NDK} -j${JOBS} APP_ABI=${a} ${ARGS}
        fi
        if [ $? -eq 0 ];
        then
	    echo success!
	    cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}.${FORMAT_EXT}
        else
	    echo error while compiling $1
        fi
    done
}

build_libretro_bsnes_jni() {

    echo PARAMETERS: DIR $2, SUBDIR: $3

    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    PROFILE=$6

    CORENAME=bsnes

    cd ${DIR}/${SUBDIR}

    for a in "${ABIS[@]}"; do
        if [ -z "${NOCLEAN}" ];
        then
	    echo "cleaning up..."
	    echo "cleanup command: ${NDK} -j${JOBS} APP_ABI=${a} clean"
	        ${NDK} -j${JOBS} APP_ABI=${a} clean
	        if [ $? -eq 0 ];
	    then
	        echo success!
	    else
	        echo error while cleaning up
	    fi
        fi

	echo "compiling for ${a}..."
        if [ -z "${ARGS}" ]
        then
	    echo "buid command: ${NDK} -j${JOBS} APP_ABI=${a}"
	    ${NDK} -j${JOBS} APP_ABI=${a}
        else
	    echo "buid command: ${NDK} -j${JOBS} APP_ABI=${a}"
	    ${NDK} -j${JOBS} APP_ABI=${a}
        fi
        if [ $? -eq 0 ];
        then
	    echo success!
	    cp -v ../libs/${a}/libretro_${CORENAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_libretro_${PROFILE}${FORMAT}.${FORMAT_EXT}
        else
	    echo error while compiling $1
        fi
    done
}


build_libretro_generic_gl_makefile() {


    NAME=$1
    DIR=$2
    SUBDIR=$3
    MAKEFILE=$4
    PLATFORM=$5
    ARGS=$6


    check_opengl

    cd $DIR
    cd $SUBDIR

    if [ -z "${NOCLEAN}" ]; 
    then
	echo "cleaning up..."
        echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean"
	${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean
	if [ $? -eq 0 ];
        then 
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."
    if [ -z "${ARGS}" ];
    then
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
    fi

    if [ $? -eq 0 ];
    then 
        echo success!
        cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
    else
        echo error while compiling $1
    fi

    reset_compiler_targets


}


build_libretro_bsnes() {


    NAME=$1
    DIR=$2
    PROFILE=$3
    MAKEFILE=$4
    PLATFORM=$5
    BSNESCOMPILER=$6


    cd $DIR


    if [ -z "${NOCLEAN}" ]; 
    then
	echo "cleaning up..."

        rm -f obj/*.{o,"${FORMAT_EXT}"}
        rm -f out/*.{o,"${FORMAT_EXT}"}	


    if [ "${PROFILE}" == "cpp98" -o "${PROFILE}" == "bnes" ];
	then
	    ${MAKE} clean
	fi


        if [ $? -eq 0 ];
        then
            echo success!
        else
            echo error while cleaning up
        fi
    fi

    echo "compiling..."


    if [ "${PROFILE}" == "cpp98" ];
    then
        ${MAKE} platform="${PLATFORM}" ${COMPILER} "-j${JOBS}"
    elif [ "${PROFILE}" == "bnes" ];
    then
		echo "buid command: ${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler=${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}
		${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler="${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}
    else
        echo "buid command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}"
        ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}
    fi

    if [ $? -eq 0 ];
    then
        echo success!
        if [ "${PROFILE}" == "cpp98" ];
        then
            cp -fv "out/libretro.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}"
        elif [ "${PROFILE}" == "bnes" ];
        then
            cp -fv "libretro.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}"
        else
            cp -fv "out/${NAME}_libretro$FORMAT.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
        fi
    else
        echo error while compiling $1
    fi

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
        echo DIR: $DIR
        echo SUBDIR: $SUBDIR


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
        TEMP=""
        TEMP=`echo $line | cut --fields=12 --delimiter=" "`
        if [ -n ${TEMP} ];
        then
           ARGS="${ARGS} ${TEMP}"
        fi
        TEMP=""
        TEMP=`echo $line | cut --fields=13 --delimiter=" "`
        if [ -n ${TEMP} ];
        then
           ARGS="${ARGS} ${TEMP}"
        fi
        TEMP=""
        TEMP=`echo $line | cut --fields=14 --delimiter=" "`
        if [ -n ${TEMP} ];
        then
           ARGS="${ARGS} ${TEMP}"
        fi

	ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"  

        echo ARGS: $ARGS
	echo
	echo

        if [ "${TYPE}" == "PROJECT" ];
        then
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

                if [ "${PREVCORE}" == "bsnes" -a "${PREVBUILD}" == "YES" -a "${COMMAND}" == "BSNES" ]; then
                    FORCE="YES"
                    BUILD="YES"
                fi

                if [ "${PREVCORE}" == "mame" -a "${PREVBUILD}" == "YES" -a "${NAME}" == "mess" ]; then
                    FORCE="YES"
                    BUILD="YES"
                fi

                if [ "${PREVCORE}" == "mess" -a "${PREVBUILD}" == "YES" -a "${NAME}" == "ume" ]; then
                    FORCE="YES"
                    BUILD="YES"
                fi


                cd ..

			else
                echo "cloning repo..."
                git clone --depth=1 "$URL" "$DIR"
                BUILD="YES"
			fi
		elif [ "${TYPE}" == "psp_hw_render" ]; 
		then
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
                git clone "$URL" "$DIR" --depth=1
				cd $DIR
				git checkout $TYPE
				cd ..
                BUILD="YES"
            fi

        elif [ "${TYPE}" == "SUBMODULE" ]; 
		then
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
                OUT=`git submodule foreach git pull origin master`
                cd ..
	    else
                echo "cloning repo..."
                git clone --depth=1 "$URL" "$DIR"
                cd $DIR
                git submodule update --init
                BUILD="YES"
            fi
        fi

        if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ];
	then
	    echo building core...
	    if [ "${COMMAND}" == "GENERIC" ]; then
		    build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
            elif [ "${COMMAND}" == "GENERIC_GL" ]; then
                    build_libretro_generic_gl_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
	    elif [ "${COMMAND}" == "GENERIC_ALT" ]; then
		    build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
	    elif [ "${COMMAND}" == "GENERIC_JNI" ]; then
		    build_libretro_generic_jni $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
	    elif [ "${COMMAND}" == "BSNES_JNI" ]; then
		    build_libretro_bsnes_jni $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
	    elif [ "${COMMAND}" == "GENERIC_THEOS" ]; then
		    build_libretro_generic_theos $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
	    elif [ "${COMMAND}" == "BSNES" ]; then
		    build_libretro_bsnes $NAME $DIR "${ARGS}" $MAKEFILE ${FORMAT_COMPILER_TARGET} ${CXX11}

	    fi
	else
	    echo core already up-to-date...
	fi
        echo

    fi

    cd "${BASE_DIR}"
    PREVCORE=$NAME
    PREVBUILD=$BUILD

done  < $1

echo "Building RetroArch"
echo ============================================
cd $WORK
BUILD=""

if [ "${PLATFORM}" == "psp1" ];
then

    while read line; do

         NAME=`echo $line | cut --fields=1 --delimiter=" "`
         DIR=`echo $line | cut --fields=2 --delimiter=" "`
         URL=`echo $line | cut --fields=3 --delimiter=" "`
         TYPE=`echo $line | cut --fields=4 --delimiter=" "`
         ENABLED=`echo $line | cut --fields=5 --delimiter=" "`
         SUBDIR=`echo $line | cut --fields=8 --delimiter=" "`

         if [ "${ENABLED}" == "YES" ];
         then
            echo "Processing $NAME"
            echo ============================================
            echo NAME: $NAME
            echo DIR: $DIR
            echo SUBDIR: $SUBDIR
            echo URL: $URL
            echo REPO TYPE: $TYPE
	    echo ENABLED: $ENABLED

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
            TEMP=""
            TEMP=`echo $line | cut --fields=12 --delimiter=" "`
            if [ -n ${TEMP} ];
            then
               ARGS="${ARGS} ${TEMP}"
            fi
            TEMP=""
            TEMP=`echo $line | cut --fields=13 --delimiter=" "`
            if [ -n ${TEMP} ];
            then
                ARGS="${ARGS} ${TEMP}"
            fi
            TEMP=""
            TEMP=`echo $line | cut --fields=14 --delimiter=" "`
            if [ -n ${TEMP} ];
            then
                ARGS="${ARGS} ${TEMP}"
            fi

     	    ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"  

            echo ARGS: $ARGS

            if [ -d "${DIR}/.git" ];
            then

                cd $DIR
                echo "pulling from repo... "
                OUT=`git pull`
                echo $OUT
                if [[ $OUT == *"Already up-to-date"* ]]
                then
                    BUILD="NO"
                else
                    BUILD="YES"
                fi
                cd ..

            else
                echo "cloning repo..."
                git clone "$URL" "$DIR" --depth=1
                cd $DIR
                BUILD="YES"
                cd ..
            fi
        fi

        if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ];
        then
            cd $DIR
    	    rm -rfv psp1/pkg/
	    cd dist-scripts
	    rm *.a
	    cp -v $RARCH_DIST_DIR/* .
	    sh ./psp1-cores.sh
        fi

    done  < $1.ra

fi

if [ "${PLATFORM}" == "android" ] && [ "${RA}" == "YES" ];
then

    while read line; do

         NAME=`echo $line | cut --fields=1 --delimiter=" "`
         DIR=`echo $line | cut --fields=2 --delimiter=" "`
         URL=`echo $line | cut --fields=3 --delimiter=" "`
         TYPE=`echo $line | cut --fields=4 --delimiter=" "`
         ENABLED=`echo $line | cut --fields=5 --delimiter=" "`
         PARENTDIR=`echo $line | cut --fields=6 --delimiter=" "`

         if [ "${ENABLED}" == "YES" ];
         then
            echo "Processing $NAME"
            echo ============================================
            echo NAME: $NAME
            echo DIR: $DIR
            echo PARENT: $PARENTDIR
            echo URL: $URL
            echo REPO TYPE: $TYPE
	    echo ENABLED: $ENABLED

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
            TEMP=""
            TEMP=`echo $line | cut --fields=12 --delimiter=" "`
            if [ -n ${TEMP} ];
            then
               ARGS="${ARGS} ${TEMP}"
            fi
            TEMP=""
            TEMP=`echo $line | cut --fields=13 --delimiter=" "`
            if [ -n ${TEMP} ];
            then
                ARGS="${ARGS} ${TEMP}"
            fi
            TEMP=""
            TEMP=`echo $line | cut --fields=14 --delimiter=" "`
            if [ -n ${TEMP} ];
            then
                ARGS="${ARGS} ${TEMP}"
            fi

     	    ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"

            echo ARGS: $ARGS

            if [ -d "${PARENTDIR}/${DIR}/.git" ];
            then
		cd $PARENTDIR
                cd $DIR
                echo "pulling from repo... "
                OUT=`git pull`
                echo $OUT
		if [ "${TYPE}" == "PROJECT" ];
		then
		    RADIR=$DIR
                    if [[ $OUT == *"Already up-to-date"* ]]
                    then
                        BUILD="NO"
                    else
                        BUILD="YES"
                    fi
                fi
                cd $WORK

            else
                echo "cloning repo..."
		cd $PARENTDIR
                git clone "$URL" "$DIR" --depth=1
                cd $DIR
		if [ "${TYPE}" == "PROJECT" ];
		then
                    BUILD="YES"
		    RADIR=$DIR

                fi
                cd $WORK
            fi
        fi

	echo
	echo
    done  < $1.ra
    if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ];
    then
        echo "Compiling Shaders"
        echo ============================================

	echo RADIR $RADIR
	cd $RADIR
	$MAKE -f Makefile.griffin shaders-convert-glsl PYTHON3=$PYTHON

		echo "Processing Assets"
        echo ============================================

	rm -Rv android/phoenix/assets/overlays
	cp -Rv media/overlays android/phoenix/assets/
	rm -Rv android/phoenix/assets/shaders_glsl
	cp -Rv media/shaders_glsl android/phoenix/assets/
	rm -Rv android/phoenix/assets/autoconfig
	cp -Rv media/autoconfig android/phoenix/assets/
	rm -Rv android/phoenix/assets/info
	cp -Rv $RARCH_DIR/info android/phoenix/assets/

	echo "Building"
        echo ============================================
	cd android/phoenix
	rm bin/*.apk

        $NDK clean
        $NDK -j8
	android update project --path . --target android-21
	android update project --path libs/googleplay --target android-21
	android update project --path libs/appcompat --target android-21
	ant debug
    fi

fi

PATH=$ORIGPATH
