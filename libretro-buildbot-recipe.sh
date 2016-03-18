# vim: set ts=3 sw=3 noet ft=sh : bash

# ----- setups -----

LOGDATE=`date +%Y-%m-%d`
ORIGPATH=$PATH
WORK=$PWD

# ----- read variables from recipe config -----
while read line; do
	KEY=`echo $line | cut -f 1 -d " "`
	VALUE=`echo $line | cut -f 2 -d " "`

	if [ "${KEY}" = "PATH" ]; then
		export PATH=${VALUE}:${ORIGPATH}
	else
		export ${KEY}=${VALUE}
	fi
done < $1.conf

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


if [ "${CORE_JOB}" == "YES" ]; then
# ----- set target  -----
	[[ "${ARM_NEON}" ]] && echo 'ARM NEON opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
	[[ "${CORTEX_A8}" ]] && echo 'Cortex A8 opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
	[[ "${CORTEX_A9}" ]] && echo 'Cortex A9 opts enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
	[[ "${ARM_HARDFLOAT}" ]] && echo 'ARM hardfloat ABI enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
	[[ "${ARM_SOFTFLOAT}" ]] && echo 'ARM softfloat ABI enabled...' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"
	[[ "${IOS}" ]] && echo 'iOS detected...'

	. $WORK/libretro-config.sh

# ----- create dirs -----
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

# ----- set compilers  -----
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
		COMPILER="CC="\""${CC}"\"" CXX="\""${CXX}"\"""
	else
		COMPILER=""
	fi

	RESET_FORMAT_COMPILER_TARGET=$FORMAT_COMPILER_TARGET
	RESET_FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET_ALT

	check_opengl() {
		if [ "${BUILD_LIBRETRO_GL}" ]; then
			if [ "${ENABLE_GLES}" ]; then
				export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
				export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
			else
				export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
				export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
			fi
		fi
	}

	reset_compiler_targets() {
		export FORMAT_COMPILER_TARGET=$RESET_FORMAT_COMPILER_TARGET
		export FORMAT_COMPILER_TARGET_ALT=$RESET_FORMAT_COMPILER_TARGET_ALT
	}
else
	SCRIPT=$(read_link "$0")
	echo "SCRIPT: $SCRIPT"
	BASE_DIR=$(dirname "$SCRIPT")
	if [ -z "$RARCH_DIST_DIR" ]; then
		RARCH_DIR="$BASE_DIR/dist"
		RARCH_DIST_DIR="$RARCH_DIR/$PLATFORM"
	fi
fi

# ----- set jobs  -----
if [ -z "$JOBS" ]; then
	JOBS=6
fi

# ----- set forceful rebuild on/off  -----
if [ -z "$FORCE" ]; then
	FORCE=NO
fi
if [ -z "$FORCE_RETROARCH_BUILD" ]; then
	FORCE_RETROARCH_BUILD=NO
fi

# ----- set release on/off  -----
if [ -z "$RELEASE" ]; then
	RELEASE=NO
fi

# ----- set cleanup rules -----
CLEANUP=NO
DAY=`date '+%d'`
HOUR=`date '+%H'`
if [ $DAY == 01 -a $HOUR == 06 ]; then
	FORCE=YES
	CLEANUP=NO
fi

# ----- use to keep track of built cores -----
CORES_BUILT=NO

FORCE_ORIG=$FORCE
JOBS_ORIG=$JOBS

cd "${BASE_DIR}"

buildbot_log() {

	echo buildbot message: $MESSAGE
	MESSAGE=`echo -e $1`

	HASH=`echo -n "$MESSAGE" | openssl sha1 -hmac $SIG | cut -f 2 -d " "`
	curl --max-time 30 --data "message=$MESSAGE&sign=$HASH" $LOGURL
}

build_libretro_generic_makefile() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6
	JOBS=$JOBS
	buildbot_log "$1:	[status: build] [$jobid]"

	cd $DIR
	cd $SUBDIR
	JOBS_ORIG=$JOBS

	if [ "${NAME}" == "mame2003" ]; then
		JOBS=1
	fi
	if [ "${NAME}" == "mame2010" ]; then
		JOBS=1
	fi

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo "compiling..."
	echo --------------------------------------------------
	if [ "${NAME}" == "mame2010" ]; then
		echo "build command: ${MAKE} -f ${MAKEFILE} "VRENDER=soft" "NATIVE=1" buildtools -j${JOBS}"
		PLATFORM="" platform="" ${MAKE} -f ${MAKEFILE} "VRENDER=soft" "NATIVE=1" buildtools -j${JOBS} | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		JOBS=$JOBS_ORIG
	fi

	if [ -z "${ARGS}" ]; then
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	if [ "${MAKEPORTABLE}" == "YES" ]; then
		echo "$1 running retrolink [$jobid]"
		$WORK/retrolink.sh ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
	fi

	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
	if [ $? -eq 0 ]; then
		MESSAGE="$1:	[status:   ok ] [$jobid]"
		if [ "${PLATFORM}" == "windows" -o "${PLATFORM}" == "unix" ]; then
			strip -s ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
		fi
	else
		ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
		HASTE=`echo $HASTE | cut -d"\"" -f4`
		MESSAGE="$1:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
	fi

	echo buildbot job: $MESSAGE
	echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
	buildbot_log "$MESSAGE"
	JOBS=$JOBS_ORIG

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi
}

build_libretro_leiradel_makefile() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6
	buildbot_log "$1:	[status: build] [$jobid]"

	ARG1=`echo ${ARGS} | cut -f 1 -d " "`
	mkdir -p $RARCH_DIST_DIR/${DIST}/${ARG1}

	cd $DIR
	cd $SUBDIR
	JOBS_ORIG=$JOBS

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo "compiling..."
	echo --------------------------------------------------
		echo "build command: ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS}"
		${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log

		cp -v ${NAME}_libretro.${PLATFORM}_${ARG1}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${ARG1}/${NAME}_libretro${LIBSUFFIX}.${FORMAT_EXT}
		if [ $? -eq 0 ]; then
			MESSAGE="$1:	[status:   ok ] [$jobid]"
		else
		ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
		HASTE=`echo $HASTE | cut -d"\"" -f4`
		MESSAGE="$1:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo buildbot job: $MESSAGE
	echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
	buildbot_log "$MESSAGE"
	JOBS=$JOBS_ORIG

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi
}

build_libretro_generic_jni() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6
	buildbot_log "$1:	[status: build] [$jobid]"

	cd ${DIR}/${SUBDIR}

	for a in "${ABIS[@]}"; do
		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $a $1 cleanup success!
			else
				echo buildbot job: $jobid $a $1 cleanup failed!
			fi
		fi

		echo "compiling for ${a}..."
		echo --------------------------------------------------
		if [ -z "${ARGS}" ]; then
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a}"
			${NDK} -j${JOBS} APP_ABI=${a} 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		else
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} "
			${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		fi

		cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
		if [ $? -eq 0 ]; then
			MESSAGE="$1-$a:	[status:   ok ] [$jobid]"
			echo buildbot job: $MESSAGE
			buildbot_log "$MESSAGE"
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="$1-$a:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo buildbot job: $MESSAGE
			buildbot_log "$MESSAGE"
		fi
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log

		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $a $1 cleanup success!
			else
				echo buildbot job: $jobid $a $1 cleanup failed!
			fi
		fi
	done
	for a in "${ABIS[@]}"; do
		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $a $1 cleanup success!
			else
				echo buildbot job: $jobid $a $1 cleanup failed!
			fi
		fi
	done
}

build_libretro_bsnes_jni() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	PROFILE=$6
	buildbot_log "$1:	[status: build] [$jobid]"

	cd ${DIR}/${SUBDIR}

	for a in "${ABIS[@]}"; do
		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $1 cleanup success!
			else
				echo buildbot job: $jobid $1 cleanup failed!
			fi
		fi

		echo "compiling for ${a}..."
		echo --------------------------------------------------
		if [ -z "${ARGS}" ]; then
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a}"
			${NDK} -j${JOBS} APP_ABI=${a}
		else
			echo "build command: ${NDK} -j${JOBS} APP_ABI=${a}"
			${NDK} -j${JOBS} APP_ABI=${a} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		fi

		cp -v ../libs/${a}/libretro_${NAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
		if [ $? -eq 0 ]; then
			MESSAGE="$1-$a:	[status:   ok ] [$jobid]"
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="$1-$a:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
		fi
		echo buildbot job: $MESSAGE
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		buildbot_log "$MESSAGE"
	done
	for a in "${ABIS[@]}"; do
		if [ -z "${NOCLEAN}" ]; then
			echo "cleaning up..."
			echo "cleanup command: ${NDK} -j${JOBS} APP_ABI=${a} clean"
			${NDK} -j${JOBS} APP_ABI=${a} clean
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $1 $a cleanup success!
			else
				echo buildbot job: $jobid $1 $a cleanup failed!
			fi
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
	buildbot_log "$1:	[status: build] [$jobid]"

	check_opengl

	cd $DIR
	cd $SUBDIR

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo "compiling..."
	echo --------------------------------------------------
	if [ -z "${ARGS}" ]; then
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
	if [ $? -eq 0 ]; then
		MESSAGE="$1:	[status:   ok ] [$jobid]"
	else
		ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
		HASTE=`echo $HASTE | cut -d"\"" -f4`
		MESSAGE="$1:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo buildbot job: $MESSAGE
	echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
	buildbot_log "$MESSAGE"

	reset_compiler_targets
	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."
		echo "cleanup command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi
}

build_libretro_bsnes() {
	NAME=$1
	DIR=$2
	PROFILE=$3
	MAKEFILE=$4
	PLATFORM=$5
	BSNESCOMPILER=$6
	buildbot_log "$1:	[status: build] [$jobid]"

	cd $DIR

	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."

		rm -f obj/*.{o,"${FORMAT_EXT}"}
		rm -f out/*.{o,"${FORMAT_EXT}"}

		if [ "${PROFILE}" = "cpp98" -o "${PROFILE}" = "bnes" ]; then
			${MAKE} clean
		fi

		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo "compiling..."
	echo --------------------------------------------------

	if [ "${PROFILE}" = "cpp98" ]; then
		${MAKE} platform="${PLATFORM}" "${COMPILER}" "-j${JOBS}" 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	elif [ "${PROFILE}" = "bnes" ]; then
		echo "build command: ${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler=${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET}
		${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler="${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		echo "build command: ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}"
		${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	if [ "${PROFILE}" = "cpp98" ]; then
		cp -fv "out/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}"
	elif [ "${PROFILE}" = "bnes" ]; then
		cp -fv "${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}"
	else
		cp -fv "out/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
	fi
	if [ $? -eq 0 ]; then
		MESSAGE="$1:	[status:   ok ] [$jobid]"
	else
		ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log | tail -n 100`
		HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
		HASTE=`echo $HASTE | cut -d"\"" -f4`
		MESSAGE="$1:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
	fi
	echo buildbot job: $MESSAGE
	echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
	buildbot_log "$MESSAGE"
	if [ -z "${NOCLEAN}" ]; then
		echo "cleaning up..."

		rm -f obj/*.{o,"${FORMAT_EXT}"}
		rm -f out/*.{o,"${FORMAT_EXT}"}

		if [ "${PROFILE}" = "cpp98" -o "${PROFILE}" = "bnes" ]; then
			${MAKE} clean
		fi

		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi
}

# ----- buildbot -----

echo buildbot starting
echo --------------------------------------------------
echo Variables:
echo CC		$CC
echo CXX	  $CXX
echo STRIP	$STRIP
echo DISTDIR $RARCH_DIST_DIR
echo JOBS	 $JOBS
echo
echo

export jobid=$1

# ----- fetch a project -----
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
		echo "buildbot job: $jobid processing $NAME"
		echo --------------------------------------------------
		echo Variables:
		echo URL		  $URL
		echo REPO TYPE  $TYPE
		echo ENABLED	 $ENABLED
		echo COMMAND	 $COMMAND
		echo MAKEFILE	$MAKEFILE
		echo DIR		  $DIR
		echo SUBDIR	  $SUBDIR
		echo
		echo

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
			TEMP=""
			TEMP=`echo $line | cut -f 15 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 16 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 17 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 18 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 19 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 20 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 21 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 22 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 23 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 24 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 25 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 26 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 27 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 28 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi
			TEMP=""
			TEMP=`echo $line | cut -f 29 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi

		ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"

		if [ "${TYPE}" = "PROJECT" ]; then
			if [ -d "${DIR}/.git" ]; then
				if [ "${CLEANUP}" == "YES" ]; then
					rm -rfv $DIR
					echo "cloning repo..."
					git clone --depth=1 "$URL" "$DIR"
					BUILD="YES"
				else
					cd $DIR
					echo "pulling changes from repo... "
					OUT=`git pull`

					if [[ $OUT == *"Already up-to-date"* ]]; then
						BUILD="NO"
					else
						BUILD="YES"
					fi

				fi

				FORCE_ORIG=$FORCE
				OLDBUILD=$BUILD

				if [ "${PREVCORE}" = "bsnes" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "bsnes" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "bsnes" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "bsnes" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "bsnes-mercury" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "gw" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "gw" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "fuse" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "fuse" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "81" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "81" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "snes9x-next" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "snes9x-next" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "vba_next" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "vba_next" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "emux_nes" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "emux_nes" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "emux_sms" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "emux_sms" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mgba" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "mgba" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "snes9x_next" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "snes9x_next" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "bsnes_mercury" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mame2014" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "mess2014" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mess2014" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "ume2014" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [[ "${PREVCORE}" == *fb* ]] && [[ "${PREVBUILD}" = "YES" ]] && [[ "${NAME}" == *fb* ]]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mame2010" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "mame2010" ]; then
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
				echo "pulling changes from repo... "
				OUT=`git pull`

				if [[ $OUT == *"Already up-to-date"* ]]; then
					BUILD="NO"
				else
					BUILD="YES"
				fi
				cd $WORK

			else
				echo "pulling changes from repo... "
				git clone "$URL" "$DIR"
				cd $DIR
				git checkout $TYPE
				cd $WORK
				BUILD="YES"
			fi
		elif [ "${TYPE}" == "SUBMODULE" ]; then
			if [ -d "${DIR}/.git" ]; then

				cd $DIR
				echo "pulling changes from repo... "
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
			touch $TMPDIR/built-cores
			CORES_BUILT=YES
			echo "buildbot job: building $NAME"
			if [ "${COMMAND}" = "GENERIC" ]; then
				build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}"
			elif [ "${COMMAND}" = "LEIRADEL" ]; then
				build_libretro_leiradel_makefile $NAME $DIR $SUBDIR $MAKEFILE ${PLATFORM} "${ARGS}"
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
			echo "buildbot job: building $NAME up-to-date"
		fi
		echo
	fi

	cd "${BASE_DIR}"
	PREVCORE=$NAME
	PREVBUILD=$BUILD

	BUILD=$OLDBUILD
	FORCE=$FORCE_ORIG
done < $1

buildbot_pull(){
   while read line; do
		NAME=`echo $line | cut -f 1 -d " "`
		DIR=`echo $line | cut -f 2 -d " "`
		URL=`echo $line | cut -f 3 -d " "`
		TYPE=`echo $line | cut -f 4 -d " "`
		ENABLED=`echo $line | cut -f 5 -d " "`
		PARENTDIR=`echo $line | cut -f 6 -d " "`

		if [ "${ENABLED}" = "YES" ]; then
			echo "buildbot job: $jobid Processing $NAME"
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

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
				cd $PARENTDIR
				cd $DIR
				echo "pulling changes from repo... "
				git reset --hard
				OUT=`git pull`
				echo $OUT
				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
						BUILD="NO"
					else
						BUILD="YES"
					fi
				elif [ "${TYPE}" = "SUBMODULE" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]]; then
						BUILD="NO"
					else
						BUILD="YES"
						git submodule foreach git pull origin master
					fi
				fi
				cd $WORK
			else
				echo "cloning repo..."
				cd $PARENTDIR
				git clone "$URL" "$DIR" --depth=1
				if [ "${TYPE}" = "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR
				elif [ "${TYPE}" == "SUBMODULE" ]; then
					cd $PARENTDIR
					cd $DIR
					RADIR=$DIR
					echo "updating submodules..."
					git submodule update --init
					git submodule foreach git pull origin master
					BUILD="YES"
				fi
				cd $WORK
			fi
		fi

		echo
		echo
	done < $1.ra
}



echo "buildbot job: $jobid Building Retroarch-$PLATFORM"
echo --------------------------------------------------
echo
cd $WORK
BUILD=""

if [ "${PLATFORM}" == "osx" ] && [ "${RA}" == "YES" ]; then

   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		git clean -xdf
		echo WORKINGDIR=$PWD
		echo RELEASE=$RELEASE
		echo FORCE=$FORCE_RETROARCH_BUILD
		echo RADIR=$RADIR

		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd pkg/apple

		xcodebuild -project RetroArch.xcodeproj -target RetroArch -configuration Release | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi

		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log

		xcodebuild -project RetroArch.xcodeproj -target "RetroArch Cg" -configuration Release | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_CG_${PLATFORM}.log

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_CG_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi

		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		cd $WORK/$RADIR

		echo "Packaging"

	fi
fi
if [ "${PLATFORM}" == "ios" ] && [ "${RA}" == "YES" ]; then

   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd pkg/apple
		xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project RetroArch_iOS.xcodeproj -configuration Release &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi

		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		cd $WORK/$RADIR

		echo "Packaging"

	fi
fi


if [ "${PLATFORM}" == "ios9" ] && [ "${RA}" == "YES" ]; then

   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd pkg/apple
		xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project RetroArch_iOS.xcodeproj -configuration Release -target "RetroArch iOS9" &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			cd build/Release-iphoneos
			security unlock-keychain -p buildbot /Users/buildbot/Library/Keychains/login.keychain
			codesign -fs "buildbot" RetroArch.app

			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi

		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		cd $WORK/$RADIR

		echo "Packaging"

	fi
fi


if [ "${PLATFORM}" = "android" ] && [ "${RA}" = "YES" ]; then

   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		echo "buildbot job: $jobid compiling shaders"
		echo
      cd $RADIR
		git clean -xdf
		echo WORKINGDIR=$PWD
		echo RELEASE=$RELEASE
		echo FORCE=$FORCE_RETROARCH_BUILD
		echo RADIR=$RADIR
		$MAKE -f Makefile.griffin shaders-convert-glsl PYTHON3=$PYTHON

		echo "buildbot job: $jobid processing assets"
		echo

		rm -rf pkg/android/phoenix/assets/assets
		rm -rf pkg/android/phoenix/assets/cores
		rm -rf pkg/android/phoenix/assets/info
		rm -rf pkg/android/phoenix/assets/overlays
		rm -rf pkg/android/phoenix/assets/shaders/shaders_glsl/
		rm -rf pkg/android/phoenix/assets/database
		rm -rf pkg/android/phoenix/assets/autoconfig
		rm -rf pkg/android/phoenix/assets/cheats
		rm -rf pkg/android/phoenix/assets/playlists
		rm -rf pkg/android/phoenix/assets/dowloads
		rm -rf pkg/android/phoenix/assets/remaps
		rm -rf pkg/android/phoenix/assets/system

		mkdir -p pkg/android/phoenix/assets
		mkdir -p pkg/android/phoenix/assets/
		mkdir -p pkg/android/phoenix/assets/assets
		mkdir -p pkg/android/phoenix/assets/cores
		mkdir -p pkg/android/phoenix/assets/info
		mkdir -p pkg/android/phoenix/assets/overlays
		mkdir -p pkg/android/phoenix/assets/shaders/shaders_glsl
		mkdir -p pkg/android/phoenix/assets/database/cursors
		mkdir -p pkg/android/phoenix/assets/database/rdb
		mkdir -p pkg/android/phoenix/assets/autoconfig
		mkdir -p pkg/android/phoenix/assets/cheats
		mkdir -p pkg/android/phoenix/assets/playlists
		mkdir -p pkg/android/phoenix/assets/dowloads
		mkdir -p pkg/android/phoenix/assets/remaps
		mkdir -p pkg/android/phoenix/assets/saves/
		mkdir -p pkg/android/phoenix/assets/states/
		mkdir -p pkg/android/phoenix/assets/system/
		mkdir -p pkg/android/phoenix/assets/filters/video
		mkdir -p pkg/android/phoenix/assets/filters/audio

		cp -rf media/assets/glui pkg/android/phoenix/assets/assets/
		cp -rf media/assets/xmb	pkg/android/phoenix/assets/assets/
		cp -rf media/assets/zarch pkg/android/phoenix/assets/assets/
		cp -rf media/autoconfig/* pkg/android/phoenix/assets/autoconfig/
		cp -rf media/overlays/* pkg/android/phoenix/assets/overlays/
		cp -rf media/shaders_glsl/* pkg/android/phoenix/assets/shaders/shaders_glsl/
		cp -rf media/libretrodb/cursors/* pkg/android/phoenix/assets/database/cursors/
		cp -rf media/libretrodb/rdb/* pkg/android/phoenix/assets/database/rdb/
		cp -rf audio/audio_filters/*.dsp pkg/android/phoenix/assets/filters/audio/
		cp -rf gfx/video_filters/*.filt pkg/android/phoenix/assets/filters/video/


		cp -rf media/shaders_glsl $TMPDIR/
		touch pkg/android/phoenix/assets/cheats/.empty-folder
		touch pkg/android/phoenix/assets/saves/.empty-folder
		touch pkg/android/phoenix/assets/states/.empty-folder
		touch pkg/android/phoenix/assets/system/.empty-folder

		cp -rf $RARCH_DIR/info/* pkg/android/phoenix/assets/info/

		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo
		cd pkg/android/phoenix
		rm bin/*.apk

cat << EOF > local.properties
sdk.dir=/home/buildbot/tools/android/android-sdk-linux
key.store=/home/buildbot/.android/release.keystore
key.alias=buildbot
key.store.password=buildbot
key.alias.password=buildbot

EOF

		$NDK clean | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		$NDK -j${JOBS} | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ "${RELEASE}" == "NO" ]; then
			python ./version_increment.py
		else
		   git reset --hard
		fi
		ant clean | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path . --target android-22 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path libs/googleplay --target android-21 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path libs/appcompat --target android-21 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		ant release | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-release.apk | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-release.apk

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		buildbot_log "$MESSAGE"

		$NDK clean | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		$NDK -j${JOBS} DEBUG=1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		python ./version_increment.py
		ant clean | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		android update project --path . --target android-22 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		android update project --path libs/googleplay --target android-21 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		android update project --path libs/appcompat --target android-21 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		ant set-debuggable release | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-debug.apk | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
		cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-debug.apk


		if [ $? -eq 0 ]; then
			MESSAGE="retroarch debug:	[status:   ok ] [$jobid]"
			echo $MESSAGE $RARCH_DIR
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
			echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		buildbot_log "$MESSAGE"
	fi
fi

if [ "${PLATFORM}" = "MINGW64" ] || [ "${PLATFORM}" = "MINGW32" ] || [ "${PLATFORM}" = "windows" ] && [ "${RA}" = "YES" ]; then
   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	echo
	echo

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		echo "compiling audio filters"
		cd audio/audio_filters
		echo "audio filter build command: ${MAKE}"
		$MAKE
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid audio filter build success!
		else
			echo buildbot job: $jobid audio filter:	[status: fail ]!
		fi

		cd ..
		cd ..

		echo "compiling video filters"
		cd gfx/video_filters
		echo "audio filter build command: ${MAKE}"
		$MAKE
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid video filter build success!
		else
			echo buildbot job: $jobid video filter:	[status: fail ]!
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
			echo buildbot job: $jobid retroarch cleanup success!
		else
			echo buildbot job: $jobid retroarch cleanup failed!
		fi



		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid retroarch configure success!
		else
			echo buildbot job: $jobid retroarch configure failed!
		fi

		echo "building..."
		echo "build command: $MAKE -j${JOBS}"
		$MAKE -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		strip -s retroarch.exe

		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
			echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			buildbot_log "$MESSAGE"

			echo "Packaging"

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
joypad_autoconfig_dir = ":\autoconf"
libretro_directory = ":\cores"
libretro_info_path = ":\info"
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
system_directory = ":\system"

EOF

			cp -v retroarch.default.cfg windows/
			cp -v *.exe tools/*.exe windows/
			cp -rf audio/audio_filters/*.dll windows/filters/audio
			cp -rf audio/audio_filters/*.dsp windows/filters/audio
			cp -rf gfx/video_filters/*.dll windows/filters/video
			cp -rf gfx/video_filters/*.filt windows/filters/video

			$MAKE clean
			V=1 $MAKE -j${JOBS} DEBUG=1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			cp -v retroarch.exe windows/retroarch_debug.exe

		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
			echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			buildbot_log "$MESSAGE"
		fi
	fi
fi

if [ "${PLATFORM}" = "psp1" ] && [ "${RA}" = "YES" ]; then
   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		./dist-cores.sh psp1 &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log

		echo "Packaging"

		cd $WORK/$RADIR
		cp retroarch.cfg retroarch.default.cfg

		mkdir -p pkg/psp1/
		mkdir -p pkg/psp1/cheats
		cp -p $RARCH_DIST_DIR/../info/*.info pkg/psp1/cores/

	fi
fi

if [ "${PLATFORM}" == "wii" ] && [ "${RA}" == "YES" ]; then
   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull
	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" ]; then
			cd dist-scripts
			rm *.a
			cp -v $RARCH_DIST_DIR/*.a .

			sh ./dist-cores.sh wii &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			if [ $? -eq 0 ]; then
				MESSAGE="retroarch:	[status:   ok ] [$jobid]"
				echo $MESSAGE
			else
				ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
				HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
				HASTE=`echo $HASTE | cut -d"\"" -f4`
				MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
				echo $MESSAGE
			fi
			buildbot_log "$MESSAGE"
			echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
			cd $WORK/$RADIR
		fi

		echo "Packaging"

		cp retroarch.cfg retroarch.default.cfg

		mkdir -p pkg/wii
		mkdir -p pkg/wii/overlays
		mkdir -p pkg/wii/cheats
		mkdir -p pkg/wii/remaps
		cp -rf media/overlays/wii/* pkg/wii/overlays
	fi
fi

if [ "${PLATFORM}" == "ngc" ] && [ "${RA}" == "YES" ]; then
   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull
	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		sh ./dist-cores.sh ngc &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ $? -eq 0 ];
		then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		cd ..

		echo "Packaging"

		cp retroarch.cfg retroarch.default.cfg
		mkdir -p pkg/ngc/
		mkdir -p pkg/ngc/cheats
		mkdir -p pkg/ngc/remaps
		mkdir -p pkg/ngc/overlays
		cp -rf media/overlays/wii/* pkg/ngc/overlays
	fi

fi

if [ "${PLATFORM}" == "ctr" ] && [ "${RA}" == "YES" ]; then
   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		JOBS=1 sh ./dist-cores.sh ctr &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
			touch $TMPDIR/built-frontend
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		cd $WORK/$RADIR


		echo "Packaging"

		cp retroarch.cfg retroarch.default.cfg

		mkdir -p pkg/3ds
		mkdir -p pkg/3ds/remaps
		mkdir -p pkg/3ds/cheats
		cp -rf media/overlays/* pkg/3ds/overlays/
	fi
fi

if [ "${PLATFORM}" == "vita" ] && [ "${RA}" == "YES" ]; then
   echo WORKINGDIR=$PWD
   echo RELEASE=$RELEASE
   echo FORCE=$FORCE_RETROARCH_BUILD
   echo RADIR=$RADIR
   
   buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		echo "buildbot job: $jobid Building"
		buildbot_log "retroarch:	[status: build] [$jobid]"
		echo

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		JOBS=1 sh ./dist-cores.sh vita &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ $? -eq 0 ]; then
			MESSAGE="retroarch:	[status:   ok ] [$jobid]"
			echo $MESSAGE
		else
			ERROR=`cat $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log | tail -n 100`
			HASTE=`curl -XPOST http://hastebin.com/documents -d"$ERROR"`
			HASTE=`echo $HASTE | cut -d"\"" -f4`
			MESSAGE="retroarch:	[status: fail ] [$jobid] LOG: http://hastebin.com/$HASTE"
			echo $MESSAGE
		fi
		buildbot_log "$MESSAGE"
		echo buildbot job: $MESSAGE | tee -a $TMPDIR/log/${BOT}/${LOGDATE}.log
		cd $WORK/$RADIR


		echo "Packaging"

		cp retroarch.cfg retroarch.default.cfg

		mkdir -p pkg/vita
		mkdir -p pkg/vita/remaps
		mkdir -p pkg/vita/cheats
		cp -rf media/overlays/* pkg/vita/overlays/
	fi
fi


PATH=$ORIGPATH
