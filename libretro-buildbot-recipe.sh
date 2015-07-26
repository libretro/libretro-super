
# vim: set ts=3 sw=3 noet ft=sh : bash

####usage:
# ./libretro-fetch-and-build.sh configfile
# if you want to force all enabled cores to rebuild prepend FORCE=YES
# you may need to specify your make command by prepending it to the commandline, for instance MAKE=mingw32-make
#
# eg: FORCE=YES MAKE=mingw32-make ./libretro-fetch-and-build.sh buildbot

####environment configuration:
echo "BUILDBOT JOB: Setting up Environment for $1"
echo

LOGDATE=`date +%Y-%m-%d`

ORIGPATH=$PATH
WORK=$PWD
OLDFORCE=YES

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

	MESSAGE=`echo -e $1`

	HASH=`echo -n "$MESSAGE" | openssl sha1 -hmac $SIG | cut -f 2 -d " "`
	curl --data "message=$MESSAGE&sign=$HASH" $LOGURL


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
	OLDJ=$JOBS

	if [ "${NAME}" = "mame078" ]; then
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
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} &> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		if [ "${NAME}" = "mame2010" ]; then

			echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}" buildtools
			${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} buildtools
		fi
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	if [ $? -eq 0 ]; then
		MESSAGE="$1 build successful [$jobid]"
		if [ "${MAKEPORTABLE}" == "YES" ]; then
			echo "$1 running retrolink [$jobid]"
			$WORK/retrolink.sh ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
		fi
		if [ "${PLATFORM}" = "windows" ]; then
			strip -s ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
		fi
		cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}  &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log

	else
		ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		MESSAGE="$1 build failed [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
        echo BUILDBOT JOB: $MESSAGE
	echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
	buildbot_log "$MESSAGE"
	JOBS=$OLDJ
}


build_libretro_leiradel_makefile() {

	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6

	cd $DIR
	cd $SUBDIR
	OLDJ=$JOBS

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE}.${ARGS} platform=${PLATFORM} -j${JOBS} ${ARGS} clean"
		${MAKE} -f ${MAKEFILE}.${ARGS} platform=${PLATFORM} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid $1 cleanup success!
		else
			echo BUILDBOT JOB: $jobid $1 cleanup failure!
		fi
	fi

	echo "compiling..."
		echo "build command: ${MAKE} -f ${MAKEFILE}.${ARGS} platform=${PLATFORM} -j${JOBS}"
		${MAKE} -f ${MAKEFILE}.${ARGS} platform=${PLATFORM} -j${JOBS} &> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log

		if [ $? -eq 0 ]; then
			MESSAGE="$1 build successful [$jobid]"
			if [ "${PLATFORM}" = "android" ]; then
				cp -v ${NAME}_libretro${FORMAT}.${ARGS}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${ARGS}/${NAME}_libretro${SUFFIX}${FORMAT}.${FORMAT_EXT}  &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			else
				cp -v ${NAME}_libretro${FORMAT}.${ARGS}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${SUFFIX}${FORMAT}.${FORMAT_EXT}  &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			fi
		else
		ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		MESSAGE="$1 build failed [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo BUILDBOT JOB: $MESSAGE
        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
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
		MESSAGE="$1 build successful [$jobid]"
		cp -v objs/obj/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
	else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="$1 build failed [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo BUILDBOT JOB: $MESSAGE
        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
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
			${NDK} -j${JOBS} APP_ABI=${a}  &> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		else
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} "
			${NDK} -j${JOBS} APP_ABI=${a} ${ARGS}  &> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		fi
		if [ $? -eq 0 ]; then
			MESSAGE="$1-$a build successful [$jobid]"
			echo BUILDBOT JOB: $MESSAGE
			buildbot_log "$MESSAGE"
			cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
		else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="$1-$a build failed [$jobid] LOG: http://hastebin.com/$HASTE"
			echo BUILDBOT JOB: $MESSAGE
                        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
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
			MESSAGE="$1 build successful [$jobid]"
			cp -v ../libs/${a}/libretro_${CORENAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_${PROFILE}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
		else
			ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
			MESSAGE="$1 build failed [$jobid] LOG: http://hastebin.com/$HASTE"
		fi
		echo BUILDBOT JOB: $MESSAGE
                echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
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
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}  &> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}  &> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	if [ $? -eq 0 ]; then 
		MESSAGE="$1 build successful [$jobid]"
		cp -v ${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
	else
		ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		MESSAGE="$1 build failed [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo BUILDBOT JOB: $MESSAGE
        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
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
		${MAKE} platform="${PLATFORM}" ${COMPILER} "-j${JOBS}" &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	elif [ "${PROFILE}" = "bnes" ]; then
		echo "build command: ${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler=${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}
		${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler="${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}  &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}  &>> /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	if [ $? -eq 0 ]; then
		MESSAGE="$1 build successful [$jobid]"
		if [ "${PROFILE}" = "cpp98" ]; then
			cp -fv "out/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}"
		elif [ "${PROFILE}" = "bnes" ]; then
			cp -fv "${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}"
		else
			cp -fv "out/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${SUFFIX}.${FORMAT_EXT}
		fi
	else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="$1 build failed [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo BUILDBOT JOB: $MESSAGE
        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
	buildbot_log "$MESSAGE"
}

#fetch a project and mark it for building if there have been any changes

#sleep 10
export jobid=$1

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
		if [ "${TYPE}" = "PROJECT" ]; then
			if [ -d "${DIR}/.git" ]; then

				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				if [[ $OUT == *"Already up-to-date"* ]]; then
					BUILD="NO"
				else
					BUILD="YES"
				fi

				OLDFORCE=$FORCE
				OLDBUILD=$BUILD

				if [ "${PREVCORE}" = "bsnes" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "gw" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "LEIRADEL" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "fuse" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "LEIRADEL" ]; then
					FORCE="YES"
					BUILD="YES"
				fi


				if [ "${PREVCORE}" = "bsnes_mercury" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mame" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "mess" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mess" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "ume" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [[ "${PREVCORE}" == *fb* ]] && [[ "${PREVBUILD}" = "YES" ]] && [[ "${NAME}" == *fb* ]]; then
					FORCE="YES"
					BUILD="YES"
				fi

				cd $WORK
			else
				echo "cloning repo..."
				git clone --depth=1 "$URL" "$DIR"
				BUILD="YES"
			fi
		elif [ "${TYPE}" = "psp_hw_render" ]; then
			if [ -d "${DIR}/.git" ]; then

				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				if [[ $OUT == *"Already up-to-date"* ]]; then
					BUILD="NO"
				else
					BUILD="YES"
				fi
				cd $WORK

			else
				echo "cloning repo..."
				git clone "$URL" "$DIR"
				cd $DIR
				git checkout $TYPE
				cd $WORK
				BUILD="YES"
			fi

		elif [ "${TYPE}" == "SUBMODULE" ]; then
			if [ -d "${DIR}/.git" ]; then

				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				if [[ $OUT == *"Already up-to-date"* ]]; then
					BUILD="NO"
				else
					BUILD="YES"
				fi
				OUT=`git submodule foreach git pull origin master`
				cd $WORK
		else
				echo "cloning repo..."
				git clone --depth=1 "$URL" "$DIR"
				cd $DIR
				git submodule update --init
				BUILD="YES"
			fi
		cd $WORK
		fi

		if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then
			echo building core...
			if [ "${COMMAND}" = "GENERIC" ]; then
				build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
			elif [ "${COMMAND}" = "LEIRADEL" ]; then
				build_libretro_leiradel_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
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

	BUILD=$OLDBUILD
	FORCE=$OLDFORCE

done < $1

echo "BUILDBOT JOB: $jobid Building Retroarch"
echo
cd $WORK
BUILD=""

if [ "${PLATFORM}" = "android" ] && [ "${RA}" = "YES" ]; then
	while read line; do
		NAME=`echo $line | cut -f 1 -d " "`
		DIR=`echo $line | cut -f 2 -d " "`
		URL=`echo $line | cut -f 3 -d " "`
		TYPE=`echo $line | cut -f 4 -d " "`
		ENABLED=`echo $line | cut -f 5 -d " "`
		PARENTDIR=`echo $line | cut -f 6 -d " "`

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

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
				cd $PARENTDIR
				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				echo $OUT
				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
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
				if [ "${TYPE}" = "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR
				fi
				cd $WORK
			fi
		fi

		echo
		echo
	done < $1.ra

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then
		echo "BUILDBOT JOB: $jobid Compiling Shaders"
		echo

		echo RADIR $RADIR
		cd $RADIR
		$MAKE -f Makefile.griffin shaders-convert-glsl PYTHON3=$PYTHON

		echo "BUILDBOT JOB: $jobid Processing Assets"
		echo


                rm -rf android/phoenix/assets/assets
                rm -rf android/phoenix/assets/cores
                rm -rf android/phoenix/assets/info
                rm -rf android/phoenix/assets/overlays
                rm -rf android/phoenix/assets/shaders/shaders_glsl/
                rm -rf android/phoenix/assets/database
                rm -rf android/phoenix/assets/autoconfig
                rm -rf android/phoenix/assets/cheats
                rm -rf android/phoenix/assets/playlists
                rm -rf android/phoenix/assets/dowloads
                rm -rf android/phoenix/assets/remaps
                rm -rf android/phoenix/assets/system

                mkdir -p android/phoenix/assets
                mkdir -p android/phoenix/assets/
                mkdir -p android/phoenix/assets/assets
                mkdir -p android/phoenix/assets/cores
                mkdir -p android/phoenix/assets/info
                mkdir -p android/phoenix/assets/overlays
                mkdir -p android/phoenix/assets/shaders/shaders_glsl/
                mkdir -p android/phoenix/assets/database
                mkdir -p android/phoenix/assets/autoconfig
                mkdir -p android/phoenix/assets/cheats
                mkdir -p android/phoenix/assets/playlists
                mkdir -p android/phoenix/assets/dowloads
                mkdir -p android/phoenix/assets/remaps
                mkdir -p android/phoenix/assets/saves/
                mkdir -p android/phoenix/assets/states/
                mkdir -p android/phoenix/assets/system/


		cp -rf media/assets/xmb android/phoenix/assets/assets/
		cp -rf media/autoconfig/* android/phoenix/assets/autoconfig/
		cp -rf media/libretrodb/rdb android/phoenix/assets/database/
		cp -rf media/libretrodb/cursors android/phoenix/assets/database/
		cp -rf media/overlays/* android/phoenix/assets/overlays/
		cp -rf media/shaders_glsl/* android/phoenix/assets/shaders/shaders_glsl/
		cp -rf media/shaders_glsl /tmp/
                touch  android/phoenix/assets/cheats/.empty-folder
                touch  android/phoenix/assets/saves/.empty-folder
                touch  android/phoenix/assets/states/.empty-folder
                touch  android/phoenix/assets/system/.empty-folder

		cp -rf $RARCH_DIR/info/* android/phoenix/assets/info/

		echo "BUILDBOT JOB: $jobid Building"
		echo
		cd android/phoenix
		rm bin/*.apk

		$NDK clean &> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		$NDK -j${JOBS} &>> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		ant clean &>> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path . --target android-22 &>> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path libs/googleplay --target android-21 &>> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path libs/appcompat --target android-21 &>> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		ant debug &>> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ $? -eq 0 ]; then
			MESSAGE="retroarch build successful [$jobid]"
			echo $MESSAGE
		else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="retroarch build failed [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
                echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
		buildbot_log "$MESSAGE"
	fi
fi

if [ "${PLATFORM}" = "theos_ios" ] && [ "${RA}" = "YES" ]; then
	while read line; do
		NAME=`echo $line | cut -f 1 -d " "`
		DIR=`echo $line | cut -f 2 -d " "`
		URL=`echo $line | cut -f 3 -d " "`
		TYPE=`echo $line | cut -f 4 -d " "`
		ENABLED=`echo $line | cut -f 5 -d " "`
		PARENTDIR=`echo $line | cut -f 6 -d " "`

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

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
				cd $PARENTDIR
				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				echo $OUT
				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
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
				if [ "${TYPE}" = "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR

				fi
				cd $WORK
			fi
		fi

		echo
		echo
	done < $1.ra

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then
		echo "BUILDBOT JOB: $jobid Compiling Shaders"
		echo 

		echo RADIR $RADIR
		cd $RADIR
		$MAKE -f Makefile.griffin shaders-convert-glsl PYTHON3=$PYTHON

		echo "BUILDBOT JOB: $jobid Processing Assets"
		echo 


		echo "BUILDBOT JOB: $jobid Building"
		echo 
		cd apple/iOS
		rm RetroArch.app -rf

		rm -rf *.deb
		export PRODUCT_NAME=RetroArch
		$MAKE clean
		$MAKE -j8
		./package.sh

		mkdir obj/RetroArch.app/modules
		cp -rf ../../../dist/theos/*.* obj/RetroArch.app/modules
		cp -rf ../../../dist/info/*.* obj/RetroArch.app/modules

		$MAKE package

		cp -r *.deb /home/buildbot/www/.radius/
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

		if [ "${ENABLED}" = "YES" ]; then
			echo "BUILDBOT JOB: $jobid Processing $NAME"
			echo 
			echo NAME: $NAME
			echo DIR: $DIR
			echo PARENT: $PARENTDIR
			echo URL: $URL
			echo REPO TYPE: $TYPE
			echo ENABLED: $ENABLED
			
			if [ "${NAME}" = "retroarch" ]; then
				ARGS=""
				TEMP=`echo $line | cut -f 7 -d " "`
				if [ -n ${TEMP} ];
				then
					ARGS="${TEMP}"
				fi
				TEMP=""
				TEMP=`echo $line | cut -f 8 -d " "`
				if [ -n ${TEMP} ]; then
					ARGS="${ARGS} ${TEMP}"
				fi
				TEMP=""
				TEMP=`echo $line | cut -f 9 -d " "`
				if [ -n ${TEMP} ]; then
					ARGS="${ARGS} ${TEMP}"
				fi
				ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"
				echo ARGS: $ARGS
			fi

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
				cd $PARENTDIR
				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				echo $OUT
				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
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

				if [ "${TYPE}" = "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR
				fi
				cd $WORK
			fi
		fi

	echo
	echo
	done < $1.ra
echo b=$BUILD f=$FORCE
	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then
		cd $RADIR
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

		echo "configuring..."
		echo "configure command: $CONFIGURE $ARGS"
		${CONFIGURE} ${ARGS}


		echo "cleaning up..."
		echo "cleanup command: $MAKE clean"
		$MAKE clean

		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid retroarch cleanup success!
		else
			echo BUILDBOT JOB: $jobid retroarch cleanup failure!
		fi



		if [ $? -eq 0 ]; then
			echo BUILDBOT JOB: $jobid retroarch configure success!
		else
			echo BUILDBOT JOB: $jobid retroarch configure failure!
		fi

		echo "building..."
		echo "build command: $MAKE -j${JOBS}"
		$MAKE -j${JOBS} &> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		strip -s retroarch.exe

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch build successful [$jobid]"
			echo $MESSAGE
                        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
			buildbot_log "$MESSAGE"

			echo "Packaging"
			echo ============================================
			cp retroarch.cfg retroarch.default.cfg

			rm -rf windows
			mkdir -p windows
			mkdir -p windows/overlays
			mkdir -p windows/shaders/shaders_cg
			mkdir -p windows/autoconfig
			mkdir -p windows/filters
			mkdir -p windows/filters/video
			mkdir -p windows/filters/audio
			mkdir -p windows/assets
			mkdir -p windows/cheats
			mkdir -p windows/database
			mkdir -p windows/database/cursors
			mkdir -p windows/database/rdb
			mkdir -p windows/playlists
                        mkdir -p windows/content
                        mkdir -p windows/downloads
                        mkdir -p windows/info
                        mkdir -p windows/cores
                        mkdir -p windows/config/remap
                        mkdir -p windows/system
                        mkdir -p windows/saves
                        mkdir -p windows/states

cat << EOF > windows/retroarch.cfg
dpi_override_value = "160"
menu_driver = "xmb"
assets_directory = ":\assets"
audio_filter_dir = ":\filters\audio"
cheat_database_path = ":\cheats"
config_save_on_exit = "true"
content_database_path = ":\database\rdb"
cursor_directory = ":\database\cursors"
input_joypad_driver = "winxinput"
input_osk_overlay_enable = "false"
input_remapping_directory = ":\config\remap"
joypad_autoconfig_dir = ":\autoconfig"
libretro_directory = ":\cores"
libretro_directory = ":\cores"
load_dummy_on_core_shutdown = "false"
menu_collapse_subgroups_enable = "true"
osk_overlay_directory = ":\overlays"
overlay_directory = ":\overlays"
playlist_directory = ":\playlists"
rgui_config_directory = ":\config"
screenshot_directory = ":\screenshots"
video_driver = "gl"
video_filter_dir = ":\filters\video"
video_shader_dir = ":\shaders"
core_assets_directory = ":\downloads"
libretro_info_path = ":\info"

EOF

			cp -v retroarch.default.cfg windows/
			cp -v *.exe tools/*.exe windows/
			cp -rf media/overlays/* windows/overlays
			cp -rf media/shaders_cg/* windows/shaders/shaders_cg
			cp -rf media/autoconfig/* windows/autoconfig
			cp -rf media/assets/* windows/assets
			cp -rf media/libretrodb/cht/* windows/cheats
			cp -rf media/libretrodb/rdb/* windows/database/rdb
			cp -rf media/libretrodb/cursors/* windows/database/cursors
			cp -rf $RARCH_DIR/info/* windows/info
			cp -rf audio/audio_filters/*.dll windows/filters/audio
			cp -rf audio/audio_filters/*.dsp windows/filters/audio
			cp -rf gfx/video_filters/*.dll windows/filters/video
			cp -rf gfx/video_filters/*.filt windows/filters/video
		else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		MESSAGE="retroarch build failed [$jobid] LOG: http://hastebin.com/$HASTE"
		echo $MESSAGE
                echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
		buildbot_log "$MESSAGE"
	   fi
	fi
fi

if [ "${PLATFORM}" = "psp1" ] && [ "${RA}" = "YES" ]; then
	while read line; do
		NAME=`echo $line | cut -f 1 -d " "`
		DIR=`echo $line | cut -f 2 -d " "`
		URL=`echo $line | cut -f 3 -d " "`
		TYPE=`echo $line | cut -f 4 -d " "`
		ENABLED=`echo $line | cut -f 5 -d " "`
		PARENTDIR=`echo $line | cut -f 6 -d " "`

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

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
			cd $PARENTDIR
				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				echo $OUT
				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
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

				if [ "${TYPE}" = "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR
				fi
				cd $WORK
			fi
		fi

		echo
		echo
	done < $1.ra

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" ]; then
		cd $RADIR
		rm -rf psp1/pkg
		echo "BUILDBOT JOB: $jobid Building"
		echo 

		if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ]; then
			cd dist-scripts
			rm *.a
			cp -v $RARCH_DIST_DIR/*.a .
			#ls -1 *.a  | awk -F "." ' { print "cp " $0 " " $1 "_psp1." $2 }' |sh

			./psp1-cores.sh &> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			if [ $? -eq 0 ]; then
				MESSAGE="retroarch build successful [$jobid]"
				echo $MESSAGE
			else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="retroarch build failed [$jobid] LOG: http://hastebin.com/$HASTE"
				echo $MESSAGE
			fi
            buildbot_log "$MESSAGE"
            echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log

			echo "Packaging"
			echo ============================================
            cd $WORK/$RADIR
			cp retroarch.cfg retroarch.default.cfg

			mkdir -p psp1/pkg/
			mkdir -p psp1/pkg/cheats
#			mkdir -p psp1/pkg/database
#			mkdir -p psp1/pkg/database/cursors
			mkdir -p psp1/pkg/database/rdb

#			cp -rf media/libretrodb/cht/* psp1/pkg/cheats
#			cp -rf media/libretrodb/rdb/* psp1/pkg/database/rdb
#			cp -rf media/libretrodb/cursors/* psp1/pkg/database/cursors
		fi
	fi
fi

if [ "${PLATFORM}" == "wii" ] && [ "${RA}" == "YES" ]; then
	while read line; do
		NAME=`echo $line | cut -f 1 -d " "`
		DIR=`echo $line | cut -f 2 -d " "`
		URL=`echo $line | cut -f 3 -d " "`
		TYPE=`echo $line | cut -f 4 -d " "`
		ENABLED=`echo $line | cut -f 5 -d " "`
		PARENTDIR=`echo $line | cut -f 6 -d " "`

		if [ "${ENABLED}" == "YES" ]; then
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

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
				cd $PARENTDIR
				cd $DIR
				echo "pulling from repo... "
				OUT=`git pull`
				echo $OUT
				if [ "${TYPE}" == "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
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

				if [ "${TYPE}" == "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR

				fi
				cd $WORK
			fi
		fi

		echo
		echo
	done  < $1.ra

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ]; then
		cd $RADIR
		  #rm -rf wii/pkg
		echo "BUILDBOT JOB: $jobid Building"
		echo

		if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ]; then
			cd dist-scripts
			rm *.a
			cp -v $RARCH_DIST_DIR/*.a .

			#ls -1 *.a  | awk -F "." ' { print "cp " $0 " " $1 "_wii." $2 }' |sh
			sh ./wii-cores.sh &> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			if [ $? -eq 0 ]; then
				MESSAGE="retroarch build successful [$jobid]"
				echo $MESSAGE
			else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="retroarch build failed [$jobid] LOG: http://hastebin.com/$HASTE"
				echo $MESSAGE
			fi
			buildbot_log "$MESSAGE"
                        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
			cd $WORK/$RADIR
		fi

		echo "Packaging"
		echo ============================================
		cp retroarch.cfg retroarch.default.cfg

		mkdir -p wii/pkg/
		mkdir -p wii/pkg/overlays
		mkdir -p wii/pkg/cheats
		mkdir -p wii/pkg/remaps
#		mkdir -p wii/pkg/database
#		mkdir -p wii/pkg/database/cursors
#		mkdir -p wii/pkg/database/rdb

#		cp -rf media/libretrodb/cht/* wii/pkg/cheats
#		cp -rf media/libretrodb/rdb/* wii/pkg/database/rdb
#		cp -rf media/libretrodb/cursors/* wii/pkg/database/cursors
		cp -rf media/overlays/wii/* wii/pkg/overlays
	fi
fi

if [ "${PLATFORM}" == "ngc" ] && [ "${RA}" == "YES" ];
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
			echo "BUILDBOT JOB: $jobid Processing $NAME"
			echo 
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

		cd $RADIR
		echo "BUILDBOT JOB: $jobid Building"
		echo 

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ];
	then

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		#ls -1 *.a  | awk -F "." ' { print "cp " $0 " " $1 "_ngc." $2 }' |sh
		sh ./ngc-cores.sh &> /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
        if [ $? -eq 0 ];
        then
            MESSAGE="retroarch build successful [$jobid]"
            echo $MESSAGE
	    else
                ERROR=`cat /tmp/log/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
                HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR" | cut --fields=4 --delimiter='"'`
		        MESSAGE="retroarch build failed [$jobid] LOG: http://hastebin.com/$HASTE"
            echo $MESSAGE
		fi
        buildbot_log "$MESSAGE"
        echo BUILDBOT JOB: $MESSAGE >> /tmp/log/${LOGDATE}.log
        cd ..

	fi

             		echo "Packaging"
			echo ============================================
			cp retroarch.cfg retroarch.default.cfg
			mkdir -p ngc/pkg/
			mkdir -p ngc/pkg/cheats
			mkdir -p ngc/pkg/remaps
#			mkdir -p ngc/pkg/database
#			mkdir -p ngc/pkg/database/cursors
#			mkdir -p ngc/pkg/database/rdb
			mkdir -p ngc/pkg/overlays
#			cp -rf media/libretrodb/cht/* ngc/pkg/cheats
#			cp -rf media/libretrodb/rdb/* ngc/pkg/database/rdb
#			cp -rf media/libretrodb/cursors/* ngc/pkg/database/cursors
                        cp -rf media/overlays/wii/* ngc/pkg/overlays



	fi

fi

PATH=$ORIGPATH
