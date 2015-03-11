#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

#$1 recipe
#$2 jobname
#$3 workdir

####usage:
# ./libretro-fetch-and-build.sh configfile
# if you want to force all enabled cores to rebuild prepend FORCE=YES
# you may need to specify your make command by prepending it to the commandline, for instance MAKE=mingw32-make
#
# eg: FORCE=YES MAKE=mingw32-make ./libretro-fetch-and-build.sh buildbot

####environment configuration:
echo "BUILDBOT JOB: Setting up Environment for $1"
echo

ORIGPATH=$PATH
WORK=$PWD

echo Original PATH: $PATH

while read line; do
	KEY=`echo $line | cut -f 1 -d " "`
	VALUE=`echo $line | cut -f 2 -d " "`

	if [ "${KEY}" = "PATH" ]; then
		export PATH=${VALUE}:${ORIGPATH}
		echo New PATH: $PATH
	else
		export ${KEY}=${VALUE}
		echo $KEY: $VALUE
	fi
done < $1.conf
echo
echo

. $WORK/libretro-config.sh

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
	while [ -L "$TARGET_FILE" ]; do
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

mkdir -v -p "$RARCH_DIST_DIR"

if [ "${PLATFORM}" = "android" ]; then
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
buildbot_log() {

	HASH=`echo -n "$1" | openssl sha1 -hmac $SIG | cut -f 2 -d " "`
	curl --data "message=$1&sign=$HASH" $LOGURL
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

	if [ "${NAME}" = "mame078" ]; then
		OLDJ=$JOBS
		JOBS=1
	fi

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid $1 cleanup success!
		else
			echo BUILDBOT JOB: $jobid $1 cleanup failure!
		fi
	fi

	echo "compiling..."
	if [ -z "${ARGS}" ]; then
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
	else
		if [ "${NAME}" = "mame2010" ]; then

			echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}" buildtools
			${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} buildtools
		fi
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
	fi

	if [ $? -eq 0 ]; then 
		MESSAGE="$1 build successful ($jobid)"
		cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}.${FORMAT_EXT}
	else
		MESSAGE="$1 build failed ($jobid)"
	fi
	echo BUILDBOT JOB: $MESSAGE
	buildbot_log "$MESSAGE"
	JOBS=$OLDJ
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

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid $1 cleanup success!
		else
			echo BUILDBOT JOB: $jobid $1 cleanup failure!
		fi
	fi

	echo "compiling..."
	if [ -z "${ARGS}" ]; then
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
	fi

	if [ $? -eq 0 ]; then
		MESSAGE="$1 build successful ($jobid)"
		cp -v objs/obj/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
	else
		MESSAGE="$1 build failure ($jobid)"
	fi
	echo BUILDBOT JOB: $MESSAGE
	buildbot_log "$MESSAGE"
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
		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then 
				echo BUILDBOT JOB: $jobid $a $1 cleanup success!
			else
				echo BUILDBOT JOB: $jobid $a $1 cleanup failure!
			fi
		fi

		echo "compiling for ${a}..."
		if [ -z "${ARGS}" ]; then
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a}"
			${NDK} -j${JOBS} APP_ABI=${a}
		else
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} "
			${NDK} -j${JOBS} APP_ABI=${a} ${ARGS}
		fi
		if [ $? -eq 0 ]; then
			MESSAGE="$1-$a build successful ($jobid)"		
			echo BUILDBOT JOB: $MESSAGE
			buildbot_log "$MESSAGE"
			cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}.${FORMAT_EXT}
		else
			MESSAGE="$1-$a build failure ($jobid)"
			echo BUILDBOT JOB: $MESSAGE
			buildbot_log "$MESSAGE"
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
		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then
				echo BUILDBOT JOB: $jobid $1 cleanup success!
			else
				echo BUILDBOT JOB: $jobid $1 cleanup failure!
			fi
		fi

		echo "compiling for ${a}..."
		if [ -z "${ARGS}" ]; then
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a}"
			${NDK} -j${JOBS} APP_ABI=${a}
		else
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a}"
			${NDK} -j${JOBS} APP_ABI=${a}
		fi
		if [ $? -eq 0 ]; then
			MESSAGE="$1 build successful ($jobid)"
			cp -v ../libs/${a}/libretro_${CORENAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}
		else
			MESSAGE="$1 build failure ($jobid)"
		fi
		echo BUILDBOT JOB: $MESSAGE
		buildbot_log "$MESSAGE"
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

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean
		if [ $? -eq 0 ]; then 
			echo BUILDBOT JOB: $jobid $1 cleanup success!
		else
			echo BUILDBOT JOB: $jobid $1 cleanup failure!
		fi
	fi

	echo "compiling..."
	if [ -z "${ARGS}" ]; then
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}
	fi

	if [ $? -eq 0 ]; then 
		MESSAGE="$1 build successful ($jobid)"
		cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
	else
		MESSAGE="$1 build failure ($jobid)"
	fi
	echo BUILDBOT JOB: $MESSAGE
	buildbot_log "$MESSAGE"

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

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."

		rm -f obj/*.{o,"${FORMAT_EXT}"}
		rm -f out/*.{o,"${FORMAT_EXT}"}	

		if [ "${PROFILE}" = "cpp98" -o "${PROFILE}" = "bnes" ]; then
			${MAKE} clean
		fi

		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid $1 cleanup success!
		else
			echo BUILDBOT JOB: $jobid $1 cleanup failure!
		fi
	fi

	echo "compiling..."

	if [ "${PROFILE}" = "cpp98" ]; then
		${MAKE} platform="${PLATFORM}" ${COMPILER} "-j${JOBS}"
	elif [ "${PROFILE}" = "bnes" ]; then
		echo "build command: ${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler=${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}
		${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler="${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}
	fi

	if [ $? -eq 0 ]; then
		MESSAGE="$1 build successful ($jobid)"
		if [ "${PROFILE}" = "cpp98" ]; then
			cp -fv "out/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}"
		elif [ "${PROFILE}" = "bnes" ]; then
			cp -fv "${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}"
		else
			cp -fv "out/${NAME}_libretro$FORMAT.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
		fi
	else
		MESSAGE="$1 build failure ($jobid)"
	fi
	echo BUILDBOT JOB: $MESSAGE
	buildbot_log "$MESSAGE"
}

#fetch a project and mark it for building if there have been any changes

#sleep 10
export jobid=$1

if [ -z "$2" ]; then
	echo no argument supplied
else
	echo processing $2 only
	TASK=$2
fi


echo
echo
while read line; do
	NAME=`echo $line | cut -f 1 -d " "`
	DIR=`echo $line | cut -f 2 -d " "`
	URL=`echo $line | cut -f 3 -d " "`
	TYPE=`echo $line | cut -f 4 -d " "`
	ENABLED=`echo $line | cut -f 5 -d " "`
	COMMAND=`echo $line | cut -f 6 -d " "`
	MAKEFILE=`echo $line | cut -f 7 -d " "`
	SUBDIR=`echo $line | cut -f 8 -d " "`

	if [ ! -z "$TASK" ]; then
		if [ "${TASK}" != "${NAME}" ]; then
			continue
		fi
	fi

	if [ "${ENABLED}" = "YES" ]; then
		echo "BUILDBOT JOB: $jobid Processing $NAME"
		echo
		echo URL: $URL
		echo REPO TYPE: $TYPE
		echo ENABLED: $ENABLED
		echo COMMAND: $COMMAND
		echo MAKEFILE: $MAKEFILE
		echo DIR: $DIR
		echo SUBDIR: $SUBDIR
		DIR=$3

		ARGS=""

		TEMP=`echo $line | cut -f 9 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${TEMP}"
		fi
		TEMP=""
		TEMP=`echo $line | cut -f 10 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${ARGS} ${TEMP}"
		fi
		TEMP=""
		TEMP=`echo $line | cut -f 11 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${ARGS} ${TEMP}"
		fi
		TEMP=""
		TEMP=`echo $line | cut -f 12 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${ARGS} ${TEMP}"
		fi
		TEMP=""
		TEMP=`echo $line | cut -f 13 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${ARGS} ${TEMP}"
		fi
		TEMP=""
		TEMP=`echo $line | cut -f 14 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${ARGS} ${TEMP}"
		fi

		ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"

		echo ARGS: $ARGS
		echo
		echo

		if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then
			echo building core...
			if [ "${COMMAND}" = "GENERIC" ]; then
				build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
			elif [ "${COMMAND}" = "GENERIC_GL" ]; then
				build_libretro_generic_gl_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
			elif [ "${COMMAND}" = "GENERIC_ALT" ]; then
				build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
			elif [ "${COMMAND}" = "GENERIC_JNI" ]; then
				build_libretro_generic_jni $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
			elif [ "${COMMAND}" = "BSNES_JNI" ]; then
				build_libretro_bsnes_jni $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
			elif [ "${COMMAND}" = "GENERIC_THEOS" ]; then
				build_libretro_generic_theos $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"
			elif [ "${COMMAND}" = "BSNES" ]; then
				build_libretro_bsnes $NAME $DIR "${ARGS}" $MAKEFILE ${FORMAT_COMPILER_TARGET} ${CXX11}
			fi
		else
			echo BUILDBOT JOB: $jobid $NAME already up-to-date...
		fi
		echo
	fi

	cd "${BASE_DIR}"
	PREVCORE=$NAME
	PREVBUILD=$BUILD
done < $1

echo 
cd $WORK
BUILD=""


if [ ! -z "$TASK" ]; then
	if [ "${TASK}" != "retroarch" ]; then
		exit 
	fi
fi

if [ "${PLATFORM}" = "MINGW64" ] || [ "${PLATFORM}" = "MINGW32" ] && [ "${RA}" = "YES" ]; then
	while read line; do
		NAME=`echo $line | cut -f 1 -d " "`
		DIR=`echo $line | cut -f 2 -d " "`
		URL=`echo $line | cut -f 3 -d " "`
		TYPE=`echo $line | cut -f 4 -d " "`
		ENABLED=`echo $line | cut -f 5 -d " "`
		PARENTDIR=`echo $line | cut -f 6 -d " "`

		if [ ! -z "$TASK" ]; then
			if [ "${TASK}" != "${NAME}" ]; then
				continue
			fi
		fi 
		if [ "${ENABLED}" = "YES" ]; then
			echo "BUILDBOT JOB: $jobid Processing $NAME"
			echo 
			echo NAME: $NAME
			echo DIR: $DIR
			echo PARENT: $PARENTDIR
			echo URL: $URL
			echo REPO TYPE: $TYPE
			echo ENABLED: $ENABLED

			ARGS=""

			TEMP=`echo $line | cut -f 9 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 10 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 11 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 12 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 13 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 14 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi

			ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"

			echo ARGS: $ARGS

		fi

		echo
		echo
	done < $1.ra

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then

		cd $3
		echo "BUILDBOT JOB: $jobid Building"
		echo 

		echo "compiling audio filters"
		cd audio/audio_filters
		echo "audio filter build command: ${MAKE}"
		$MAKE
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid audio filter build success!		
		else
			echo BUILDBOT JOB: $jobid audio filter build failure!
		fi
		
		cd ..
		cd ..
		
		echo "compiling video filters"
		cd gfx/video_filters
		echo "audio filter build command: ${MAKE}"
		$MAKE
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid video filter build success!		
		else
			echo BUILDBOT JOB: $jobid video filter build failure!
		fi
		
		cd ..
		cd ..		
		
		echo "cleaning up..."
		echo "cleanup command: $MAKE clean"
		$MAKE clean
		
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid retroarch cleanup success!		
		else
			echo BUILDBOT JOB: $jobid retroarch cleanup failure!
		fi		

		echo "configuring..."
		echo "configure command: $CONFIGURE"
		${CONFIGURE}
		
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid retroarch configure success!		
		else
			echo BUILDBOT JOB: $jobid retroarch configure failure!
		fi		

		echo "building..."
		echo "build command: $MAKE -j${JOBS}"
		$MAKE -j${JOBS}
		
		if [ $? -eq 0 ]; then
			MESSAGE="retroarch build successful ($jobid)"
			echo $MESSAGE
			buildbot_log "$MESSAGE"
		else
			MESSAGE="retroarch build failed ($jobid)"
			echo $MESSAGE
			buildbot_log "$MESSAGE"
		fi
	fi
fi

PATH=$ORIGPATH
