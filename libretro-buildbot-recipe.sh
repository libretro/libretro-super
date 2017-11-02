#!/bin/bash
# vim: set ts=3 sw=3 noet ft=sh : bash
# ----- setup -----

# This will use an overridden value from the command-line if provided, otherwise just use the current date
LOGDATE=${LOGDATE:-`date +%Y-%m-%d`}

ORIGPATH=$PATH
WORK=$PWD
RECIPE=$1
BRANCH=""
ENTRY_ID=""

# ----- read variables from recipe config -----
while read line; do
	KEY=`echo $line | cut -f 1 -d " "`
	VALUE=`echo $line | cut -f 2 -d " "`
	rm $TMPDIR/vars
	if [ "${KEY}" = "PATH" ]; then
		export PATH=${VALUE}:${ORIGPATH}
		echo PATH=${VALUE}:${ORIGPATH} >> $TMPDIR/vars
	else
		export ${KEY}=${VALUE}
		echo ${KEY}=${VALUE} >> $TMPDIR/vars
	fi
	echo Setting: ${KEY} ${VALUE}
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

convert_xmb_assets()
{
	local src_dir=$1
	local dst_dir=$2
	local scale_icon=$3
	local scale_bg=$4
	# dots per inch, a value of 90 seems to produce a 64x64 resolution for most icons
	local density=$5

	mkdir -p "$dst_dir"
	IFS_old=$IFS
	IFS=$(echo -en "\n\b")
	for theme in `ls $src_dir`; do
		if [ -d $src_dir/$theme ] ; then
			theme=`basename "$theme"`
			cp $src_dir/$theme/*.* $dst_dir/$theme/
			mkdir -p "$dst_dir/$theme/png"
			for png in `ls $src_dir/$theme/png/*.png -d`; do
				local name=`basename "$png" .png`
				local src_file="$src_dir/$theme/src/$name.svg"
				local is_svg=1
				if [ ! -e $src_file ] ; then
					src_file="$src_dir/$theme/png/$name.png"
					is_svg=
				fi
				local dst_file="$dst_dir/$theme/png/$name.png"
				if [ ! -e $src_file ] || [ $src_file -nt $dst_file ] ; then
					local scale_factor=$scale_icon
					if [ $name = "bg" ] ; then
						scale_factor=$scale_bg
					fi
					if [ $is_svg ] ; then
					echo convert -background none -density $density "$src_file" -resize $scale_factor "$dst_file"
					convert -background none -density $density "$src_file" -resize $scale_factor "$dst_file"
					else
					echo convert -background none "$src_file" -resize $scale_factor "$dst_file"
					convert -background none "$src_file" -resize $scale_factor "$dst_file"
					fi
				fi
			done
		fi
	done
	IFS=$IFS_old
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
		if [ -n "$ABI_OVERRIDE" ]; then
			echo ABIS-pre: $TARGET_ABIS
			echo OVERRIDE: ${ABI_OVERRIDE}
			TARGET_ABIS=${ABI_OVERRIDE}
			export TARGET_ABIS=${ABI_OVERRIDE}
			echo ABIS-post: $TARGET_ABIS
		fi
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

	if [ -z "${HELPER} ${MAKE}" ]; then
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
			CXX11=clang++
		elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
			CXX=mingw32-g++f
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

	if  [ -n "$LOGURL" ]; then
		HASH=`echo -n "$MESSAGE" | openssl sha1 -hmac $SIG | cut -f 2 -d " "`
		curl --max-time 30 --data "message=$MESSAGE&sign=$HASH" $LOGURL
	fi
}

buildbot_handle_message() {
	RET=$1
	ENTRY_ID=$2
	NAME=$3
	jobid=$4
	ERROR=$5

	if [ $RET -eq 0 ]; then
		if [ -n "$LOGURL" ]; then
			curl -X POST -d type="finish" -d index="$ENTRY_ID" -d status="done" http://buildbot.fiveforty.net/build_entry/
		fi
		MESSAGE="$NAME:	[status: done] [$jobid]"
	else
		if [ -n "$LOGURL" ]; then
			gzip -9fk $ERROR
			HASTE=`curl -X POST http://p.0bl.net/ --data-binary @${ERROR}.gz`
			MESSAGE="$NAME:	[status: fail] [$jobid] LOG: $HASTE"
			curl -X POST -d type="finish" -d index="$ENTRY_ID" -d status="fail" -d log="$HASTE" http://buildbot.fiveforty.net/build_entry/
		else
			MESSAGE="$NAME:	[status: fail] [$jobid]"
		fi
	fi

	echo buildbot job: $MESSAGE
	buildbot_log "$MESSAGE"

	# used by Travis-CI to exit immediately if a core build fails, instead of trying to build RA anyways (for static/console builds)
	if [ $RET -ne 0 ] && [ "$EXIT_ON_ERROR" = "1" ]; then
		exit 1
	fi
}

build_libretro_generic_makefile() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6
	JOBS=$JOBS

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	if [ "${COMMAND}" = "CMAKE" ]; then
		mkdir -p $DIR/$SUBDIR
	fi

	cd $DIR
	cd $SUBDIR
	JOBS_ORIG=$JOBS

	if [ "${NAME}" == "mame2003" ]; then
		JOBS=1
	fi
	if [ "${NAME}" == "mame2010" ]; then
		JOBS=1
	fi

	echo --------------------------------------------------| tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cat $TMPDIR/vars | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log

	cd ${DIR}/${SUBDIR}
	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	if [ -z "${NOCLEAN}" ]; then
		if [ "${COMMAND}" = "CMAKE" ]; then
			echo "CLEANUP CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		else
			if [ -z "${ARGS}" ]; then
				echo "CLEANUP CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
				${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			else
				echo "CLEANUP CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
				${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			fi
		fi

		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	if [ "${NAME}" == "mame2010" ]; then
		echo "BUILD CMD: PLATFORM="" platform="" ${HELPER} ${MAKE} -f ${MAKEFILE} "VRENDER=soft" "NATIVE=1" buildtools -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		PLATFORM="" platform="" ${HELPER} ${MAKE} -f ${MAKEFILE} "VRENDER=soft" "NATIVE=1" buildtools -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		JOBS=$JOBS_ORIG
	fi

	if [ "${COMMAND}" = "CMAKE" ]; then
		if [ "${PLATFORM}" = "android" ]; then
			EXTRAARGS="-DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=${API_LEVEL} -DCMAKE_ANDROID_ARCH_ABI=${ABI_OVERRIDE} -DCMAKE_ANDROID_NDK=${NDK_ROOT}"
		fi
		if [ -z "${ARGS}" ]; then
			echo "BUILD CMD: ${CMAKE}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			${CMAKE} | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		else
			echo "BUILD CMD: ${CMAKE} ${EXTRAARGS} ${ARGS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			echo ${EXTRAARGS} ${ARGS} | xargs ${CMAKE} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		fi

		find . -mindepth 2 -name "${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" -exec cp -f "{}" . \;
	else
		if [ -z "${ARGS}" ]; then
			echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		else
			echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
			${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		fi
	fi

	if [ "${MAKEPORTABLE}" == "YES" ]; then
		echo "BUILD CMD $WORK/retrolink.sh ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		$WORK/retrolink.sh ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	if [ "${PLATFORM}" == "windows" -o "${PLATFORM}" == "unix" ]; then
		if [ -z "${STRIP}" ]; then
			STRIP=strip
		fi

		${STRIP} -s ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
	fi

	echo "COPY CMD: cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}

	RET=$?
	ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	buildbot_handle_message "$RET" "$ENTRY_ID" "$NAME" "$jobid" "$ERROR"

	ENTRY_ID=""
	JOBS=$JOBS_ORIG
}

build_libretro_leiradel_makefile() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	ARG1=`echo ${ARGS} | cut -f 1 -d " "`
	mkdir -p $RARCH_DIST_DIR/${DIST}/${ARG1}

	cd $DIR
	cd $SUBDIR
	JOBS_ORIG=$JOBS

	echo --------------------------------------------------| tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
	cat $TMPDIR/vars | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log

	cd ${DIR}/${SUBDIR}
	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
	if [ -z "${NOCLEAN}" ]; then
		echo "CLEANUP CMD: ${HELPER} ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		${HELPER} ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	${HELPER} ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARGS} platform=${PLATFORM}_${ARGS} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log

	echo "COPY CMD: cp -v ${NAME}_libretro.${PLATFORM}_${ARG1}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${ARG1}/${NAME}_libretro${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro.${PLATFORM}_${ARG1}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${ARG1}/${NAME}_libretro${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro.${PLATFORM}_${ARG1}.${FORMAT_EXT} $RARCH_DIST_DIR/${DIST}/${ARG1}/${NAME}_libretro${LIBSUFFIX}.${FORMAT_EXT}

	RET=$?
	ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	buildbot_handle_message "$RET" "$ENTRY_ID" "$NAME" "$jobid" "$ERROR"

	ENTRY_ID=""
	JOBS=$JOBS_ORIG
}

build_libretro_generic_gl_makefile() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6

	check_opengl

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	cd $DIR
	cd $SUBDIR

	echo --------------------------------------------------| tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
	cat $TMPDIR/vars | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log

	cd ${DIR}/${SUBDIR}
	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
	if [ -z "${NOCLEAN}" ]; then
		echo "CLEANUP CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	if [ -z "${ARGS}" ]; then
		echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	else
		echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} ${COMPILER} -j${JOBS} ${ARGS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
		${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${ARGS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	fi

	echo "COPY CMD: cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	cp -v ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}

	RET=$?
	ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}.log
	buildbot_handle_message "$RET" "$ENTRY_ID" "$NAME" "$jobid" "$ERROR"

	ENTRY_ID=""

	reset_compiler_targets
}

build_libretro_generic_jni() {
	NAME=$1
	DIR=$2
	SUBDIR=$3
	MAKEFILE=$4
	PLATFORM=$5
	ARGS=$6

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	echo --------------------------------------------------| tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
	cat $TMPDIR/vars | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log

	cd ${DIR}/${SUBDIR}
	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
	for a in "${ABIS[@]}"; do
		if [ -z "${NOCLEAN}" ]; then
			echo "CLEANUP CMD: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $a $1 cleanup success!
			else
				echo buildbot job: $jobid $a $1 cleanup failed!
			fi
		fi

		echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		if [ -z "${ARGS}" ]; then
			echo "BUILD CMD: ${NDK} -j${JOBS} APP_ABI=${a}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} APP_ABI=${a} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		else
			echo "BUILD CMD: ${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} " 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} APP_ABI=${a} ${ARGS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		fi


		if [ "${NAME}" == "mupen64plus" ]; then
			echo "COPY CMD: cp -v ../libs/${a}/libparallel_retro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/parallel_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			cp -v ../libs/${a}/libparallel_retro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/parallel_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			cp -v ../libs/${a}/libparallel_retro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/parallel_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
		fi
		echo "COPY CMD: cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		cp -v ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}

		RET=$?
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "$NAME" "$jobid" "$ERROR"

		ENTRY_ID=""

		if [ -z "${NOCLEAN}" ]; then
			echo "CLEANUP CMD: ${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} ${ARGS} APP_ABI=${a} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PLATFORM}_${a}.log
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

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	cd ${DIR}/${SUBDIR}
	echo -------------------------------------------------- 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
	for a in "${ABIS[@]}"; do
		if [ -z "${NOCLEAN}" ]; then
			echo "CLEANUP CMD: ${NDK} -j${JOBS} APP_ABI=${a} clean" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} APP_ABI=${a} clean 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $1 cleanup success!
			else
				echo buildbot job: $jobid $1 cleanup failed!
			fi
		fi

		echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
		if [ -z "${ARGS}" ]; then
			echo "BUILD CMD: ${NDK} -j${JOBS} APP_ABI=${a} profile=${PROFILE}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} APP_ABI=${a} profile=${PROFILE} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
		else
			echo "BUILD CMD: ${NDK} -j${JOBS} APP_ABI=${a} profile=${PROFILE}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
			${NDK} -j${JOBS} APP_ABI=${a} profile=${PROFILE} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
		fi

		echo "COPY CMD: cp -v ../libs/${a}/libretro_${NAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
		cp -v ../libs/${a}/libretro_${NAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
		cp -v ../libs/${a}/libretro_${NAME}_${PROFILE}.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}

		RET=$?
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}_${a}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "$NAME" "$jobid" "$ERROR"

		ENTRY_ID=""
	done
}

build_libretro_bsnes() {
	NAME=$1
	DIR=$2
	PROFILE=$3
	MAKEFILE=$4
	PLATFORM=$5
	BSNESCOMPILER=$6

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	cd $DIR
	echo -------------------------------------------------- 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
	if [ -z "${NOCLEAN}" ]; then

		rm -f obj/*.{o,"${FORMAT_EXT}"} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		rm -f out/*.{o,"${FORMAT_EXT}"} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log

		if [ "${PROFILE}" = "cpp98" -o "${PROFILE}" = "bnes" ]; then
			${HELPER} ${MAKE} clean 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		fi

		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
	if [ "${PROFILE}" = "cpp98" ]; then
		${HELPER} ${MAKE} platform="${PLATFORM}" ${COMPILER} "-j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
	elif [ "${PROFILE}" = "bnes" ]; then
		echo "BUILD CMD: ${HELPER} ${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler=${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		${HELPER} ${MAKE} -f Makefile ${COMPILER} "-j${JOBS}" compiler="${BSNESCOMPILER}" platform=${FORMAT_COMPILER_TARGET} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
	else
		echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} compiler=${BSNESCOMPILER} ui='target-libretro' profile=${PROFILE} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
	fi

	if [ "${PROFILE}" = "cpp98" ]; then
		echo "COPY CMD: cp -fv out/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		cp -fv "out/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		cp -fv "out/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1
	elif [ "${PROFILE}" = "bnes" ]; then
		echo "COPY CMD cp -fv ${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		cp -fv "${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		cp -fv "${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}"
	else
		echo "COPY CMD cp -fv "out/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		cp -fv "out/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
		cp -fv "out/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}
	fi

	RET=$?
	ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLATFORM}.log
	buildbot_handle_message "$RET" "$ENTRY_ID" "${NAME}-${PROFILE}" "$jobid" "$ERROR"

	ENTRY_ID=""
}

build_libretro_higan() {
	NAME=$1
	DIR=$2
   SUBDIR=$3
	MAKEFILE=$4
   PLAT=$5
	BSNESCOMPILER=$7
   ARGS=$8

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	cd $DIR/$SUBDIR
	echo -------------------------------------------------- 2>&1 | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
	if [ -z "${NOCLEAN}" ]; then

		rm -f obj/*.{o,"${FORMAT_EXT}"} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
		rm -f out/*.{o,"${FORMAT_EXT}"} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log

		if [ $? -eq 0 ]; then
			echo buildbot job: $jobid $1 cleanup success!
		else
			echo buildbot job: $jobid $1 cleanup failed!
		fi
	fi

   unset $platform
   unset $PLATFORM
   platform=""
   PLATFORM=""

	echo -------------------------------------------------- 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
	echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} compiler=${BSNESCOMPILER} ${ARGS} -j${JOBS}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
	${HELPER} ${MAKE} -f ${MAKEFILE} compiler=${BSNESCOMPILER} ${ARGS} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log

	echo "COPY CMD cp -fv" "out/${NAME}_${PROFILE}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_${PROFILE}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
   cp -fv "out/${NAME}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
	cp -fv "out/${NAME}_libretro${FORMAT}.${FORMAT_EXT}" $RARCH_DIST_DIR/${NAME}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}

	RET=$?
	ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${NAME}_${PROFILE}_${PLAT}.log
	buildbot_handle_message "$RET" "$ENTRY_ID" "${NAME}-${PROFILE}" "$jobid" "$ERROR"

	ENTRY_ID=""
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
	GIT_BRANCH=`echo $line | cut -f 4 -d " "`
	TYPE=`echo $line | cut -f 5 -d " "`
	ENABLED=`echo $line | cut -f 6 -d " "`
	COMMAND=`echo $line | cut -f 7 -d " "`
	MAKEFILE=`echo $line | cut -f 8 -d " "`
	SUBDIR=`echo $line | cut -f 9 -d " "`

	if [ "$SINGLE_CORE" ]; then
		if [ "$NAME" != "$SINGLE_CORE" ]; then
			continue
		fi
	fi

	if [ "${ENABLED}" = "YES" ]; then
		echo -ne "buildbot job started at: "
		date
		echo
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

		TEMP=`echo $line | cut -f 10 -d " "`
		if [ -n ${TEMP} ]; then
			ARGS="${TEMP}"
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
			TEMP=""
			TEMP=`echo $line | cut -f 30 -d " "`
			if [ -n ${TEMP} ]; then
				ARGS="${ARGS} ${TEMP}"
			fi

		ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"
		BUILD="NO"

		if [ "${TYPE}" = "PROJECT" ]; then
			if [ -d "${DIR}/.git" ]; then
				if [ "${CLEANUP}" == "YES" ]; then
					rm -rfv $DIR
					echo "cloning repo $URL..."
					git clone --depth=1 -b "$GIT_BRANCH" "$URL" "$DIR"
					BUILD="YES"
				else
					cd $DIR

					if [ -f .forcebuild ]; then
						echo "found .forcebuild file, building $NAME"
						BUILD="YES"
					fi

					echo "pulling changes from repo $URL... "
					OUT=`git pull`
					echo $OUT

					if [[ $OUT == *"Already up-to-date"* ]] && [ ! "${BUILD}" = "YES" ]; then
						BUILD="NO"
					else
						echo "resetting repo state... "
						git reset --hard FETCH_HEAD
						git clean -xdf
						BUILD="YES"
					fi

				fi

				FORCE_ORIG=$FORCE
				OLDBUILD=$BUILD

				if [ "${PREVCORE}" = "bsnes" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "bsnes" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES_JNI" ]; then
					FORCE="YES"
					BUILD="YES"
				fi
				
				if [ "${PREVCORE}" = "bsnes_mercury" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES" ]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "bsnes_mercury" -a "${PREVBUILD}" = "YES" -a "${COMMAND}" = "BSNES_JNI" ]; then
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

				if [[ "${PREVCORE}" == *fbalpha2012* ]] && [[ "${PREVBUILD}" = "YES" ]] && [[ "${NAME}" == *fbalpha2012* ]]; then
					FORCE="YES"
					BUILD="YES"
				fi

				if [ "${PREVCORE}" = "mame2010" -a "${PREVBUILD}" = "YES" -a "${NAME}" = "mame2010" ]; then
					FORCE="YES"
					BUILD="YES"
				fi
				cd $WORK
			else
				echo "cloning repo $URL..."
				git clone --depth=1 -b "$GIT_BRANCH" "$URL" "$DIR"
				BUILD="YES"
			fi
		elif [ "${TYPE}" = "psp_hw_render" ]; then
			if [ -d "${DIR}/.git" ]; then
				cd $DIR

				if [ -f .forcebuild ]; then
					echo "found .forcebuild file, building $NAME"
					BUILD="YES"
				fi

				echo "pulling changes from repo $URL... "
				OUT=`git pull`
				echo $OUT

				if [[ $OUT == *"Already up-to-date"* ]] && [ ! "${BUILD}" = "YES" ]; then
					BUILD="NO"
				else
					echo "resetting repo state... "
					git reset --hard FETCH_HEAD
					git clean -xdf
					BUILD="YES"
				fi
				cd $WORK

			else
				echo "pulling changes from repo... "
				git clone -b "$GIT_BRANCH" "$URL" "$DIR"
				cd $DIR
				git checkout $TYPE
				cd $WORK
				BUILD="YES"
			fi
		elif [ "${TYPE}" == "SUBMODULE" ]; then
			if [ -d "${DIR}/.git" ]; then
				cd $DIR

				if [ -f .forcebuild ]; then
					echo "found .forcebuild file, building $NAME"
					BUILD="YES"
				fi

				echo "pulling changes from repo $URL... "
				OUT=`git pull`
				echo $OUT

				if [[ $OUT == *"Already up-to-date"* ]] && [ ! "${BUILD}" = "YES" ]; then
					BUILD="NO"
				else
					echo "resetting repo state $URL... "
					git reset --hard FETCH_HEAD
					git clean -xdf
					BUILD="YES"
				fi
				OUT=`git submodule update --init --recursive`
				cd $WORK
		else
				echo "cloning repo $URL..."
				git clone --depth=1 -b "$GIT_BRANCH" "$URL" "$DIR"
				cd $DIR
				git submodule update --init --recursive
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
			elif [ "${COMMAND}" = "CMAKE" ]; then
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
         elif [ "${COMMAND}" = "HIGAN" ]; then
            build_libretro_higan $NAME $DIR $SUBDIR $MAKEFILE $PLATFORM ${FORMAT_COMPILER_TARGET} ${CXX11} "${ARGS}"
			fi
		else
			echo "buildbot job: building $NAME up-to-date"
		fi
		echo
		echo -ne "buildbot job finished at: "
		date
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

				if [ -f .forcebuild ]; then
					echo "found .forcebuild file, building $NAME"
					BUILD="YES"
				fi

				echo "pulling changes from repo $URL... "
				OUT=`git pull`
				echo $OUT

				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]] && [ ! "${BUILD}" = "YES" ]; then
						BUILD="NO"
					else
						echo "resetting repo state $URL... "
						git reset --hard FETCH_HEAD
						git clean -xdf
						BUILD="YES"
					fi
				elif [ "${TYPE}" = "SUBMODULE" ]; then
					RADIR=$DIR
					if [[ $OUT == *"Already up-to-date"* ]] && [ ! "${BUILD}" = "YES" ]; then
						BUILD="NO"
					else
						echo "resetting repo state $URL... "
						git reset --hard FETCH_HEAD
						git clean -xdf
						BUILD="YES"
						git submodule update --init --recursive
						#git submodule foreach git pull origin master
					fi
				fi
				cd $WORK
			else
				echo "cloning repo $URL..."
				cd $PARENTDIR
				if [ ! -z "$BRANCH" -a "${NAME}" == "retroarch" ]; then
					git clone "$URL" "$DIR"
					cd $DIR
					git checkout "$BRANCH"
				elif [ ! -z "$GIT_BRANCH" ]; then
					git clone -b "$GIT_BRANCH" "$URL" "$DIR" --depth=1
				else
					git clone -b master "$URL" "$DIR" --depth=1
				fi
				cd $WORK
				if [ "${TYPE}" = "PROJECT" ]; then
					BUILD="YES"
					RADIR=$DIR
				elif [ "${TYPE}" == "SUBMODULE" ]; then
					cd $PARENTDIR
					cd $DIR
					RADIR=$DIR
					echo "updating submodules..."
					git submodule update --init --recursive
					#git submodule foreach git pull origin master
					BUILD="YES"
				fi
				cd $WORK
			fi
		fi

		echo
		echo RADIR=$RADIR
	if [ -e {$RECIPE}.ra ]; then
		done < {$RECIPE}.ra
	else
		done < $RECIPE
	fi
	cd $WORK
}

compile_audio_filters()
{
  HELPER=$1
  MAKE=$2
	echo "compiling audio filters"
	cd libretro-common/audio/dsp_filters
	echo "audio filter BUILD CMD: ${HELPER} ${MAKE}"
	${HELPER} ${MAKE}
	if [ $? -eq 0 ]; then
		echo buildbot job: $jobid audio filter build success!
	else
		echo buildbot job: $jobid audio filter:	[status: fail]!
	fi
	cd ..
	cd ..
}

compile_video_filters()
{
  HELPER=$1
  MAKE=$2
  echo "compiling video filters"
  cd gfx/video_filters
  echo "audio filter BUILD CMD: ${HELPER} ${MAKE}"
  ${HELPER} ${MAKE}
  if [ $? -eq 0 ]; then
	  echo buildbot job: $jobid video filter build success!
  else
	  echo buildbot job: $jobid video filter:	[status: fail]!
  fi
  cd ..
  cd ..
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
		cd $RADIR
		git clean -xdf
		echo WORKINGDIR=$PWD
		echo RELEASE=$RELEASE
		echo FORCE=$FORCE_RETROARCH_BUILD
		echo RADIR=$RADIR

		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd pkg/apple

		xcodebuild -project RetroArch.xcodeproj -target RetroArch -configuration Release | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=$?
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		xcodebuild -project RetroArch.xcodeproj -target "RetroArch Cg" -configuration Release | tee $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_CG_${PLATFORM}.log

		RET=$?
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_CG_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

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
		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd pkg/apple
		xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project RetroArch_iOS.xcodeproj -configuration Release &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=$?
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""
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
		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd pkg/apple
		xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project RetroArch_iOS.xcodeproj -configuration Release -target "RetroArch iOS9" &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=$?

		if [ $RET -eq 0 ]; then
			touch $TMPDIR/built-frontend
			cd build/Release-iphoneos
			security unlock-keychain -p buildbot /Users/buildbot/Library/Keychains/login.keychain
			codesign -fs "buildbot" RetroArch.app
		fi

		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""
		cd $WORK/$RADIR

		echo "Packaging"

	fi
fi


if [ "${PLATFORM}" = "android" ] && [ "${RA}" = "YES" ]; then

	echo WORKINGDIR=$PWD
	echo RELEASE=$RELEASE
	echo FORCE=$FORCE_RETROARCH_BUILD
	echo RADIR=$RADIR
	echo BRANCH=$BRANCH

	buildbot_pull

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" ]; then
		echo "buildbot job: $jobid compiling shaders"
		echo
		cd $RADIR
		git clean -xdf
		echo WORKINGDIR=$PWD
		echo RELEASE=$RELEASE
		echo FORCE=$FORCE_RETROARCH_BUILD
		echo RADIR=$RADIR
		#${HELPER} ${MAKE} -f Makefile.griffin shaders-convert-glsl PYTHON3=$PYTHON

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
		mkdir -p pkg/android/phoenix/assets/assets/xmb/monochrome
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
		cp -rf media/assets/xmb/monochrome pkg/android/phoenix/assets/assets/xmb
		cp -rf media/assets/zarch pkg/android/phoenix/assets/assets/
		cp -rf media/assets/s* pkg/android/phoenix/assets/assets/
		cp -rf media/autoconfig/* pkg/android/phoenix/assets/autoconfig/
		cp -rf media/overlays/* pkg/android/phoenix/assets/overlays/
		cp -rf media/shaders_glsl/* pkg/android/phoenix/assets/shaders/shaders_glsl/
		cp -rf media/libretrodb/cursors/* pkg/android/phoenix/assets/database/cursors/
		cp -rf media/libretrodb/rdb/* pkg/android/phoenix/assets/database/rdb/
		cp -rf libretro-common/audio/dsp_filters/*.dsp pkg/android/phoenix/assets/filters/audio/
		cp -rf gfx/video_filters/*.filt pkg/android/phoenix/assets/filters/video/
		find pkg/android/phoenix/assets/assets/ -type d -name src -exec rm -rf {} \;


		#cp -rf media/shaders_glsl $TMPDIR/
		touch pkg/android/phoenix/assets/cheats/.empty-folder
		touch pkg/android/phoenix/assets/saves/.empty-folder
		touch pkg/android/phoenix/assets/states/.empty-folder
		touch pkg/android/phoenix/assets/system/.empty-folder

		cp -rf $RARCH_DIR/info/* pkg/android/phoenix/assets/info/

		echo "buildbot job: $jobid Building"
		echo
		cd pkg/android/phoenix
		rm bin/*.apk

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

cat << EOF > local.properties
sdk.dir=/home/buildbot/tools/android/android-sdk-linux
key.store=/home/buildbot/.android/release.keystore
key.alias=buildbot
key.store.password=buildbot
key.alias.password=buildbot

EOF

		if [ "${RELEASE}" == "NO" ]; then
			python ./version_increment.py
		else
			git reset --hard
		fi
		ant clean | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path . --target android-24 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path libs/googleplay --target android-24 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		android update project --path libs/appcompat --target android-24 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		ant release | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		if [ -z "$BRANCH" ]; then
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-release.apk | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-release.apk
		else
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-$BRANCH-release.apk | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-$BRANCH-release.apk
		fi

		RET=$?
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		if [ $RET -eq 0 ]; then
			touch $TMPDIR/built-frontend
		fi

		ENTRY_ID=""
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
		cd $RADIR
		RADIR=$PWD
		echo RetroArch Directory: $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		compile_audio_filters ${HELPER} ${MAKE}
		cd $RADIR
		compile_video_filters ${HELPER} ${MAKE}
		cd $RADIR

		echo "configuring..."
		echo "configure command: $CONFIGURE $ARGS"
		${CONFIGURE} ${ARGS}


		echo "cleaning up..."
		echo "CLEANUP CMD: ${HELPER} ${MAKE} clean"
		${HELPER} ${MAKE} clean

		rm -rf windows
		mkdir -p windows

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
		echo "BUILD CMD: ${HELPER} ${MAKE} -j${JOBS}"
		${HELPER} ${MAKE} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		if [ -n ${CUSTOM_BUILD} ]; then
			${CUSTOM_BUILD} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		fi

		strip -s retroarch.exe
		cp -v retroarch.exe.manifest windows/retroarch.exe.manifest 2>/dev/null
		cp -v retroarch.exe windows/retroarch.exe | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		cp -v retroarch.exe windows/retroarch.exe

		status=$?
		echo $status

		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$status" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		if [ $status -eq 0 ]; then
			touch $TMPDIR/built-frontend
			echo buildbot job: $MESSAGE >>$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

			${HELPER} ${MAKE} clean

			if [ -n "$LOGURL" ]; then
				ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch-debug" http://buildbot.fiveforty.net/build_entry/`
			fi

			${HELPER} ${MAKE} -j${JOBS} DEBUG=1 GL_DEBUG=1 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			for i in $(seq 3); do for bin in $(ntldd -R *exe | grep -i mingw | cut -d">" -f2 | cut -d" " -f2); do cp -vu "$bin" . ; done; done

			if [ -n ${CUSTOM_BUILD_DEBUG} ]; then
				${CUSTOM_BUILD_DEBUG} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			fi

			cp -v retroarch.exe.manifest windows/retroarch_debug.exe.manifest 2>/dev/null
			cp -v retroarch.exe windows/retroarch_debug.exe	| tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			cp -v *.dll windows/
			cp -v retroarch.exe windows/retroarch_debug.exe

			status=$?
			ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			buildbot_handle_message "$status" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

			if [ $status -eq 0 ]; then
				MESSAGE="retroarch debug:	[status: done] [$jobid]"
				echo buildbot job: $MESSAGE >>$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
				buildbot_log "$MESSAGE"
			else
				MESSAGE="retroarch-debug:	[status: fail] [$jobid]"
				echo buildbot job: $MESSAGE >>$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			fi

			ENTRY_ID=""

			echo "Packaging"
			cp retroarch.cfg retroarch.default.cfg
			mkdir -p windows/filters
			mkdir -p windows/filters/video
			mkdir -p windows/filters/audio
			mkdir -p windows/saves
			mkdir -p windows/states
			mkdir -p windows/system
			mkdir -p windows/screenshots

			cp -v retroarch.default.cfg windows/
			cp -v tools/*.exe windows/
			cp -rf libretro-common/audio/dsp_filters/*.dll windows/filters/audio
			cp -rf libretro-common/audio/dsp_filters/*.dsp windows/filters/audio
			cp -rf gfx/video_filters/*.dll windows/filters/video
			cp -rf gfx/video_filters/*.filt windows/filters/video

		else
			MESSAGE="retroarch:	[status: fail] [$jobid]"
			ENTRY_ID=""
			echo buildbot job: $MESSAGE >>$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
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

		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh psp1 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		if [ $RET -eq 0 ]; then
			touch $TMPDIR/built-frontend
		fi

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
		cp retroarch.cfg retroarch.default.cfg

		mkdir -p pkg/psp1/
		mkdir -p pkg/psp1/info
		cp -v $RARCH_DIST_DIR/../info/*.info pkg/psp1/info/

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
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh wii 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
		cp retroarch.cfg retroarch.default.cfg
		mkdir -p pkg/wii/
		mkdir -p pkg/wii/cheats
		mkdir -p pkg/wii/remaps
		mkdir -p pkg/wii/overlays
		cp -v $RARCH_DIST_DIR/../info/*.info pkg/
		cp -rf media/overlays/wii/* pkg/wii/overlays
	fi
fi

if [ "${PLATFORM}" == "wiiu" ] && [ "${RA}" == "YES" ]; then
	echo WORKINGDIR=$PWD
	echo RELEASE=$RELEASE
	echo FORCE=$FORCE_RETROARCH_BUILD
	echo RADIR=$RADIR

	buildbot_pull
	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .
		cp -v $RARCH_DIST_DIR/../info/*.info .
		cp -v ../media/assets/pkg/wiiu/*.png .

		time sh ./wiiu-cores.sh 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
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
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh ngc 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
		cp retroarch.cfg retroarch.default.cfg
		mkdir -p pkg/ngc/
		mkdir -p pkg/ngc/cheats
		mkdir -p pkg/ngc/remaps
		mkdir -p pkg/ngc/overlays
		cp -v $RARCH_DIST_DIR/../info/*.info pkg/
		cp -rf media/overlays/ngc/* pkg/ngc/overlays
	fi
fi

if [ "${PLATFORM}" == "ctr" ] && [ "${RA}" == "YES" ]; then
	buildbot_pull
	echo WORKINGDIR=$PWD $WORK
	echo RELEASE=$RELEASE
	echo FORCE=$FORCE_RETROARCH_BUILD
	echo RADIR=$RADIR

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh ctr 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""

		cd $WORK/$RADIR
		echo $PWD

		echo "Packaging"

		cp retroarch.cfg retroarch.default.cfg

		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/cores
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/cores/info
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/remaps
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/cheats
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/filters
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/filters/audio
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/filters/video
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/database
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/database/rdb
		mkdir -p $WORK/$RADIR/pkg/3ds/retroarch/database/cursors


		cp -v $WORK/$RADIR/gfx/video_filters/*.filt $WORK/$RADIR/pkg/3ds/retroarch/filters/video/
		cp -v $WORK/$RADIR/libretro-common/audio/dsp_filters/*.dsp $WORK/$RADIR/pkg/3ds/retroarch/filters/audio/
		cp -v $RARCH_DIST_DIR/../info/*.info $WORK/$RADIR/pkg/3ds/retroarch/cores/info/
		cp -v $WORK/$RADIR/media/libretrodb/rdb/*.rdb $WORK/$RADIR/pkg/3ds/retroarch/database/rdb/
		cp -v $WORK/$RADIR/media/libretrodb/cursors/*.dbc $WORK/$RADIR/pkg/3ds/retroarch/database/cursors/

		convert_xmb_assets $WORK/$RADIR/media/assets/xmb $WORK/$RADIR/pkg/3ds/retroarch/media/xmb 64x32! 400x240! 90
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
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .
		cp -v $RARCH_DIST_DIR/arm/*.a .

		time sh ./dist-cores.sh vita 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
		cp retroarch.cfg retroarch.default.cfg

		mkdir -p pkg/vita
		mkdir -p pkg/vita/remaps
		mkdir -p pkg/vita/cheats
		cp -rf media/overlays/* pkg/vita/overlays/
	fi
fi

if [ "${PLATFORM}" == "ps3" ] && [ "${RA}" == "YES" ]; then
	echo WORKINGDIR=$PWD
	echo RELEASE=$RELEASE
	echo FORCE=$FORCE_RETROARCH_BUILD
	echo RADIR=$RADIR

	buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh dex-ps3 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}_dex.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}_dex.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch-dex" "$jobid" "$ERROR"


		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		time sh ./dist-cores.sh cex-ps3 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}_cex.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}_cex.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch-cex" "$jobid" "$ERROR"

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		time sh ./dist-cores.sh ode-ps3 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}_ode.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}_ode.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch-ode" "$jobid" "$ERROR"
		ENTRY_ID=""
	fi
fi

if [ "${PLATFORM}" = "emscripten" ] && [ "${RA}" = "YES" ]; then
	echo WORKINGDIR=$PWD
	echo RELEASE=$RELEASE
	echo FORCE=$FORCE_RETROARCH_BUILD
	echo RADIR=$RADIR

	buildbot_pull

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then
		touch $TMPDIR/built-frontend
		cd $RADIR
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.bc .

		echo "BUILD CMD $HELPER ./dist-cores.sh emscripten" &> $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		$HELPER ./dist-cores.sh emscripten 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		RET=${PIPESTATUS[0]}
		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"
		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
	fi
fi

if [ "${PLATFORM}" = "unix" ]; then
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
		git clean -xdf
		echo "buildbot job: $jobid Building"
		echo

		ENTRY_ID=""

		if [ -n "$LOGURL" ]; then
			ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/`
		fi

		compile_audio_filters ${HELPER} ${MAKE}
		cd $RADIR
		compile_video_filters ${HELPER} ${MAKE}
		cd $RADIR

		echo "configuring..."
		echo "configure command: $CONFIGURE $ARGS"
		${CONFIGURE} ${ARGS}


		echo "cleaning up..."
		echo "CLEANUP CMD: ${HELPER} ${MAKE} clean"
		${HELPER} ${MAKE} clean

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
		echo "BUILD CMD: ${HELPER} ${MAKE} -j${JOBS}"
		${HELPER} ${MAKE} -j${JOBS} 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log

		status=$?
		echo $status

		ERROR=$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		buildbot_handle_message "$status" "$ENTRY_ID" "retroarch" "$jobid" "$ERROR"

		if [ $status -eq 0 ]; then
			MESSAGE="retroarch:	[status: done] [$jobid]"
			echo buildbot job: $MESSAGE >>$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
			echo "Packaging"
		else
			MESSAGE="retroarch:	[status: fail] [$jobid]"
			echo buildbot job: $MESSAGE >>$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${PLATFORM}.log
		fi
	fi
fi

PATH=$ORIGPATH
