#!/bin/bash
# vim: set ts=3 sw=3 noet ft=sh : bash
# ----- setup -----

# This will use an overridden value from the command-line if provided, otherwise just use the current date
BOT="${BOT:-.}"
LOGDATE="${LOGDATE:-$(date +%Y-%m-%d)}"
TMPDIR="${TMPDIR:-/tmp}"

if [ -z "${1}" ]; then
	echo 'No recipe target, exiting.' >&2
	exit 1
fi

mkdir -p -- "$TMPDIR/log/${BOT}/${LOGDATE}"

ORIGPATH=$PATH
WORK=$PWD
RECIPE=$1
BRANCH=""
ENTRY_ID=""

# ----- read variables from recipe config -----
while read line; do
	[ -z "${line}" ] && continue
	KEY="${line% *}"
	VALUE="${line#* }"
	rm -f -- "$TMPDIR/vars"
	if [ "${KEY}" = "PATH" ]; then
		export PATH=${VALUE}:${ORIGPATH}
		echo PATH=${VALUE}:${ORIGPATH} >> $TMPDIR/vars
	else
		export ${KEY}=${VALUE}
		echo ${KEY}=${VALUE} >> $TMPDIR/vars
	fi
	echo "Setting: ${KEY} ${VALUE}"
done < $RECIPE.conf

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
				mkdir -p $RARCH_DIST_DIR/${a}
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

	TMP_MAKE="${HELPER} ${MAKE}"
	if [ -z "${TMP_MAKE}" ]; then
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
JOBS="${JOBS:-6}"

# ----- set forceful rebuild on/off  -----
FORCE="${FORCE:-NO}"
FORCE_RETROARCH_BUILD="${FORCE_RETROARCH_BUILD:-NO}"

# ----- set release on/off  -----
RELEASE="${RELEASE:-NO}"

# ----- set cleanup rules -----
CLEANUP=NO
DAY=$(date '+%d')
HOUR=$(date '+%H')
if [ "${DAY}" = 01 ] && [ "${HOUR}" = 06 ]; then
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
	CORE_NAME=$3
	jobid=$4
	ERROR=$5

	if [ $RET -eq 0 ]; then
		if [ -n "$LOGURL" ]; then
			curl -X POST -d type="finish" -d index="$ENTRY_ID" -d status="done" http://buildbot.fiveforty.net/build_entry/
		fi
		MESSAGE="$CORE_NAME: [status: done] [$jobid]"
	else
		if [ -n "$LOGURL" ]; then
			HASTE="n/a"

			if [ -n "$ERROR" ]; then
				gzip -9fk $ERROR
				HASTE=`curl -X POST http://p.0bl.net/ --data-binary @${ERROR}.gz`
			fi
			MESSAGE="$CORE_NAME: [status: fail] [$jobid] LOG: $HASTE"
			curl -X POST -d type="finish" -d index="$ENTRY_ID" -d status="fail" -d log="$HASTE" http://buildbot.fiveforty.net/build_entry/
		else
			MESSAGE="$CORE_NAME: [status: fail] [$jobid]"
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
	NAME="$1"
	DIR="$2"
	SUBDIR="$3"
	MAKEFILE="$4"
	PLATFORM="$5"
	ARGS="$6"
	CORES="${7:-$NAME}"

	ENTRY_ID=""

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	cd "${DIR}"

	if [ "${COMMAND}" = "CMAKE" ] && [ "${SUBDIR}" != . ]; then
		rm -rf -- "$SUBDIR"
		mkdir -p -- "$SUBDIR"
	elif [ "${COMMAND}" = "GENERIC_GL" ] && [ "${BUILD_LIBRETRO_GL}" ]; then
		if [ "${ENABLE_GLES}" ]; then
			export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
			export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
		else
			export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
			export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
		fi
	fi

	case "{$NAME}" in
		*higan_sfc*|*bsnes* ) OUT="out" ;;
		* ) OUT=. ;;
	esac

	cd "${SUBDIR}"

	eval "set -- $CORES"
	for i do
		core="${i%:*}"
		arg="${i##*:}"

		if [ "$arg" != "$core" ]; then
			CORE_ARGS="${ARGS} ${arg}"
		else
			CORE_ARGS="${ARGS}"
		fi

		CORE_ARGS="${CORE_ARGS#"${CORE_ARGS%%[! ]*}"}"
		CORENAM="${core}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}"

		if [ "${COMMAND}" = "LEIRADEL" ]; then
			ARG1="${CORE_ARGS%% *}"
			LOGFILE="$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${core}_${PLATFORM}_${ARG1}.log"
			ORIGNAM="${core}_libretro.${PLATFORM}_${ARG1}.${FORMAT_EXT}"
			OUTPUT="$RARCH_DIST_DIR/${DIST}/${ARG1}/${CORENAM}"
			mkdir -p -- "$RARCH_DIST_DIR/${DIST}/${ARG1}"
		else
			LOGFILE="$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${core}_${PLATFORM}.log"
			ORIGNAM="${CORENAM}"
			OUTPUT="$RARCH_DIST_DIR/${DIST}/${CORENAM}"
		fi

		echo -------------------------------------------------- | tee "$LOGFILE"
		cat $TMPDIR/vars | tee -a "$LOGFILE"

		echo -------------------------------------------------- | tee -a "$LOGFILE"
		if [ -z "${NOCLEAN}" ] && [ -f "${MAKEFILE}" ] && [ "${COMMAND}" != "CMAKE" ]; then
			if [ "${NAME}" = "higan_sfc" ] || [ "${NAME}" = "higan_sfc_balanced" ]; then
				rm -fv obj/*.{o,"${FORMAT_EXT}"} 2>&1 | tee -a "$LOGFILE"
				rm -fv out/*.{o,"${FORMAT_EXT}"} 2>&1 | tee -a "$LOGFILE"
			elif [ "${COMMAND}" = "LEIRADEL" ]; then
				eval "set -- ${HELPER} ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARG1} platform=${PLATFORM}_${CORE_ARGS} -j${JOBS} clean"
				echo "CLEANUP CMD: $*" 2>&1 | tee -a "$LOGFILE"
				"$@" 2>&1 | tee -a "$LOGFILE"
			else
				eval "set -- ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${CORE_ARGS} clean"
				echo "CLEANUP CMD: $*" 2>&1 | tee -a "$LOGFILE"
				"$@" 2>&1 | tee -a "$LOGFILE"
			fi

			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid ${core} cleanup success!
			else
				echo buildbot job: $jobid ${core} cleanup failed!
			fi
		fi

		echo -------------------------------------------------- | tee -a "$LOGFILE"
		if [ "${COMMAND}" = "CMAKE" ]; then
			if [ "${PLATFORM}" = "android" ]; then
				EXTRAARGS="-DANDROID_PLATFORM=android-${API_LEVEL} \
					-DANDROID_ABI=${ABI_OVERRIDE} \
					-DCMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake"
			fi			
			if [ "${platform}" = "msvc2017_desktop_x86" ]; then
				EXTRAARGS="-G\"Visual Studio 15 2017\""
			fi
			if [ "${platform}" = "msvc2017_desktop_x64" ]; then
				EXTRAARGS="-G\"Visual Studio 15 2017 Win64\""
			fi
			if [ "${platform}" = "msvc2010_x86" ]; then
				EXTRAARGS="-G\"Visual Studio 10 2010\""
			fi
			if [ "${platform}" = "msvc2010_x64" ]; then
				EXTRAARGS="-G\"Visual Studio 10 2010 Win64\""
			fi
			if [ "${platform}" = "msvc2005_x86" ]; then
				EXTRAARGS="-G\"Visual Studio 8 2005\""
			fi
			if [ "${platform}" = "msvc2005_x64" ]; then
				EXTRAARGS="-G\"Visual Studio 8 2005 Win64\""
			fi
			if [ "${platform}" = "msvc2003_x86" ]; then
				EXTRAARGS="-G\"Visual Studio 7\""
			fi

			eval "set -- ${EXTRAARGS} \${CORE_ARGS} -DCMAKE_VERBOSE_MAKEFILE=ON"
			echo "BUILD CMD: ${CMAKE} $*" 2>&1 | tee -a "$LOGFILE"
			echo "$@" .. | xargs ${CMAKE} 2>&1 | tee -a "$LOGFILE"
			echo "BUILD CMD: ${CMAKE} --build . --target ${core}_libretro --config Release -- -j${JOBS}" 2>&1 | tee -a "$LOGFILE"
			${CMAKE} --build . --target ${core}_libretro --config Release -- -j${JOBS} 2>&1 | tee -a "$LOGFILE"

			find . -mindepth 2 -name "${CORENAM}" -exec cp -f "{}" . \;
		elif [ "${COMMAND}" = "LEIRADEL" ]; then
			eval "set -- ${HELPER} ${MAKE} -f ${MAKEFILE}.${PLATFORM}_${ARG1} platform=${PLATFORM}_${CORE_ARGS} -j${JOBS}"
			echo "BUILD CMD: $*" 2>&1 | tee -a "$LOGFILE"
			"$@" 2>&1 | tee -a "$LOGFILE"
		elif [ "${NAME}" = "higan_sfc" ] || [ "${NAME}" = "higan_sfc_balanced" ]; then
			platform=""
			echo "BUILD CMD: ${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS}" ${CORE_ARGS} 2>&1 | tee -a "$LOGFILE"
			${HELPER} ${MAKE} -f ${MAKEFILE} -j${JOBS} ${CORE_ARGS} 2>&1 | tee -a "$LOGFILE"
		else
			eval "set -- ${HELPER} ${MAKE} -f ${MAKEFILE} platform=${PLATFORM} -j${JOBS} ${CORE_ARGS}"
			echo "BUILD CMD: $*" 2>&1 | tee -a "$LOGFILE"
			"$@" 2>&1 | tee -a "$LOGFILE"
		fi

		if [ "${MAKEPORTABLE}" == "YES" ]; then
			echo "BUILD CMD $WORK/retrolink.sh ${OUT}/${CORENAM}" 2>&1 | tee -a "$LOGFILE"
			$WORK/retrolink.sh ${OUT}/${CORENAM} 2>&1 | tee -a "$LOGFILE"
		fi

		if [ "${PLATFORM}" = "windows" ] || [ "${PLATFORM}" = "unix" ]; then
			${STRIP:=strip} -s ${OUT}/${CORENAM}
		elif [ "${PLATFORM}" = "android" -a ! -z "${STRIPPATH+x}" ]; then
			${NDK_ROOT}/${STRIPPATH} -s ${OUT}/${CORENAM}
		fi

		echo "COPY CMD: cp -v ${OUT}/${ORIGNAM} ${OUTPUT}" 2>&1 | tee -a "$LOGFILE"
		cp -v "${OUT}/${ORIGNAM}" "${OUTPUT}" 2>&1 | tee -a "$LOGFILE"
		cp -v "${OUT}/${ORIGNAM}" "${OUTPUT}"

		RET=$?
		buildbot_handle_message "$RET" "$ENTRY_ID" "$core" "$jobid" "$LOGFILE"
	done

	if [ "${COMMAND}" = "GENERIC_GL" ]; then
		export FORMAT_COMPILER_TARGET=$RESET_FORMAT_COMPILER_TARGET
		export FORMAT_COMPILER_TARGET_ALT=$RESET_FORMAT_COMPILER_TARGET_ALT
	fi

	ENTRY_ID=""
}

build_libretro_generic_jni() {
	NAME="$1"
	DIR="$2"
	SUBDIR="$3"
	MAKEFILE="$4"
	PLATFORM="$5"
	ARGS="$6"
	CORES="${7:-$NAME}"

	ENTRY_ID=""
	LIBNAM="libretro"

	if [ -n "$LOGURL" ]; then
		ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="$NAME" http://buildbot.fiveforty.net/build_entry/`
	fi

	cd ${DIR}
	cd ${SUBDIR}

	ABILIST=$(sed -n 's/APP_ABI *[:?]*= *//p' Application.mk)
	if [ -z ${ABILIST} -o "${ABILIST}" == "all" ]; then
		APPABIS=("${ABIS[@]}")
	else
		IFS=' ' read -ra APPABIS <<< "${ABILIST}"
	fi

	eval "set -- $CORES"
	for i do
		core="${i%:*}"
		arg="${i##*:}"

		if [ "$arg" != "$core" ]; then
			CORE_ARGS="${arg} ${ARGS}"
		else
			CORE_ARGS="${ARGS}"
		fi

		CORENAM="${core}_libretro${FORMAT}${LIBSUFFIX}.${FORMAT_EXT}"

		if [ "${NAME}" = "bsnes" ] || [ "${NAME}" = "bsnes_mercury" ]; then
			LIBNAM="libretro_${core}"
		fi

		LOGFILE="$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_${core}_${PLATFORM}.log"
		echo -------------------------------------------------- | tee "$LOGFILE"
		cat $TMPDIR/vars | tee -a "$LOGFILE"

		echo -------------------------------------------------- | tee -a "$LOGFILE"
		if [ -z "${NOCLEAN}" ]; then
			echo "CLEANUP CMD: ${NDK} -j${JOBS} ${CORE_ARGS} clean" 2>&1 | tee -a "$LOGFILE"
			${NDK} -j${JOBS} ${CORE_ARGS} clean 2>&1 | tee -a "$LOGFILE"

			if [ $? -eq 0 ]; then
				echo buildbot job: $jobid $a ${core} cleanup success!
			else
				echo buildbot job: $jobid $a ${core} cleanup failed!
			fi
		fi

		echo -------------------------------------------------- | tee -a "$LOGFILE"
		eval "set -- ${NDK} -j${JOBS} ${CORE_ARGS}"
		echo "BUILD CMD: $*" 2>&1 | tee -a "$LOGFILE"
		"$@" 2>&1 | tee -a "$LOGFILE"

		RET=0
		for a in "${APPABIS[@]}"; do
			if [ -f ../libs/${a}/$LIBNAM.${FORMAT_EXT} ]; then
				echo "COPY CMD: cp -v ../libs/${a}/$LIBNAM.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAM}" 2>&1 | tee -a "$LOGFILE"
				cp -v ../libs/${a}/$LIBNAM.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAM} 2>&1 | tee -a "$LOGFILE"
			else
				echo "$LIBNAM.${FORMAT_EXT} for ${a} not found" 2>&1 | tee -a "$LOGFILE"
				RET=1
			fi
		done

		buildbot_handle_message "$RET" "$ENTRY_ID" "$core" "$jobid" "$LOGFILE"
	done

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
	eval "set -- \$line"

	NAME="$1"
	DIR="$2"
	URL="$3"
	GIT_BRANCH="$4"
	ENABLED="$5"
	COMMAND="$6"
	MAKEFILE="$7"
	SUBDIR="$8"
	ARGS=""
	CORES=""

	if [ -z "${SINGLE_CORE:-}" ]; then
		CORE=""
	elif [ "$NAME" != "$SINGLE_CORE" ]; then
		continue
	fi

	shift 8
	while [ $# -gt 0 ]; do
		arg="$1"; shift
		[ "$arg" = \| ] && break
		ARGS="${ARGS} ${arg}"
	done

	for i do
		if [ -z "${CORE}" ] || [ "${CORE}" = "${i%:*}" ]; then
			CORES="${CORES} $i"
		fi
	done

	ARGS="${ARGS# }"
	ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"

	[ "${ENABLED}" != "YES" ] && { echo "${NAME} is disabled, skipping"; continue; }

	echo "buildbot job started at: $(date)"
	echo
	echo "buildbot job: $jobid processing $NAME"
	echo --------------------------------------------------
	echo Variables:
	echo URL		  $URL
	echo ENABLED	 $ENABLED
	echo COMMAND	 $COMMAND
	echo MAKEFILE	$MAKEFILE
	echo DIR		  $DIR
	echo SUBDIR	  $SUBDIR
	echo
	echo

	BUILD="NO"
	BUILD_ORIG=$BUILD
	FORCE_ORIG=$FORCE

	if [ ! -d "${DIR}/.git" ] || [ "${CLEANUP}" = "YES" ]; then
		rm -rfv -- "$DIR"
		echo "cloning repo $URL..."
		git clone --depth=1 -b "$GIT_BRANCH" "$URL" "$DIR"
		BUILD="YES"
	else
		if [ -f "$DIR/.forcebuild" ]; then
			echo "found $DIR/.forcebuild file, building $NAME"
			BUILD="YES"
		fi

		HEAD="$(git --work-tree="$DIR" --git-dir="$DIR/.git" rev-parse HEAD)" || \
			{ echo "git directory broken, removing $DIR and skipping $NAME."; \
			rm -rfv -- "$DIR" && continue; }

		if [ -z "${NOCLEAN}" ]; then
			echo "fetching changes from repo $URL..."
			git --work-tree="$DIR" --git-dir="$DIR/.git" fetch --depth 1 origin "${GIT_BRANCH}"

			echo "resetting repo state $URL..."
			git --work-tree="." --git-dir=".git" -C "$DIR" reset --hard FETCH_HEAD
			git --work-tree="$DIR" --git-dir="$DIR/.git" clean -xdf -e .libretro-core-recipe
		fi

		if [ "$HEAD" = "$(git --work-tree="$DIR" --git-dir="$DIR/.git" rev-parse HEAD)" ] && [ "${BUILD}" != "YES" ]; then
			BUILD="NO"
		else
			BUILD="YES"
		fi
	fi

	if [ -f "$DIR/.libretro-core-recipe" ]; then
		recipe="$(cat "$DIR/.libretro-core-recipe")"
		if [ "$line" != "$recipe" ]; then
			rm -f -- "$DIR/.libretro-core-recipe"
			echo "$line" > "$DIR/.libretro-core-recipe"
			BUILD="YES"
		fi
	else
		echo "$line" > "$DIR/.libretro-core-recipe"
	fi

	CURRENT_BRANCH="$(git --work-tree="$DIR" --git-dir="$DIR/.git" rev-parse --abbrev-ref HEAD)"

	if [ "${GIT_BRANCH}" != "${CURRENT_BRANCH}" ] && [ "${TRAVIS:-0}" = "0" ]; then
		echo "Changing to the branch ${GIT_BRANCH} from ${CURRENT_BRANCH}"
		git --work-tree="$DIR" --git-dir="$DIR/.git" remote set-branches origin "${GIT_BRANCH}"
		git --work-tree="$DIR" --git-dir="$DIR/.git" fetch --depth 1 origin "${GIT_BRANCH}"
		git --work-tree="$DIR" --git-dir="$DIR/.git" checkout "${GIT_BRANCH}"
		git --work-tree="$DIR" --git-dir="$DIR/.git" branch -D "${CURRENT_BRANCH}"
		BUILD="YES"
	fi

	if git config --file "$DIR/.gitmodules" --name-only --get-regexp path >/dev/null 2>&1; then
		git --work-tree="." --git-dir=".git" -C "$DIR" submodule update --init --recursive
	fi

	if [ "${BUILD}" = "YES" ] || [ "${FORCE}" = "YES" ]; then
		touch $TMPDIR/built-cores
		CORES_BUILT=YES
		echo "buildbot job: building $NAME"
		case "${COMMAND}" in
			CMAKE|GENERIC|GENERIC_GL )
			              build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET} "${ARGS}" "${CORES}" ;;
			GENERIC_JNI ) build_libretro_generic_jni $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}" "${CORES}"  ;;
			GENERIC_ALT ) build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${FORMAT_COMPILER_TARGET_ALT} "${ARGS}"        ;;
			LEIRADEL )    build_libretro_generic_makefile $NAME $DIR $SUBDIR $MAKEFILE ${PLATFORM} "${ARGS}" "${CORES}"               ;;
			* )           :                                                                                                           ;;
		esac

		if [ -z "${NOCLEAN}" ]; then
			echo "Cleaning repo state after build $URL..."
			git --work-tree="${BASE_DIR}/${DIR}" --git-dir="${BASE_DIR}/${DIR}/.git" clean -xdf -e .libretro-core-recipe
		fi
	else
		echo "buildbot job: building $NAME up-to-date"
	fi

	echo
	echo "buildbot job finished at: $(date)"

	cd "${BASE_DIR}"

	BUILD=$BUILD_ORIG
	FORCE=$FORCE_ORIG
done < $RECIPE

buildbot_pull(){
	[ ! -f "$RECIPE.ra" ] && return 0

	while read line; do
		eval "set -- \$line"

		NAME="$1"
		DIR="$2"
		URL="$3"
		TYPE="$4"
		ENABLED="$5"
		PARENTDIR="$6"
		ARGS=""

		shift 6
		while [ $# -gt 0 ]; do
			ARGS="${ARGS} ${1}"
			shift
		done

		ARGS="${ARGS# }"
		ARGS="${ARGS%"${ARGS##*[![:space:]]}"}"

		if [ "${ENABLED}" = "YES" ]; then
			echo "buildbot job: $jobid Processing $NAME"
			echo
			echo NAME: $NAME
			echo DIR: $DIR
			echo PARENT: $PARENTDIR
			echo URL: $URL
			echo REPO TYPE: $TYPE
			echo ENABLED: $ENABLED

			if [ -d "${PARENTDIR}/${DIR}/.git" ]; then
				cd $PARENTDIR
				cd $DIR

				if [ -f .forcebuild ]; then
					echo "found .forcebuild file, building $NAME"
					BUILD="YES"
				fi

				echo "pulling changes from repo $URL... "
				HEAD="$(git rev-parse HEAD)"
				git pull

				if [ "${TYPE}" = "PROJECT" ]; then
					RADIR=$DIR
					if [ "$HEAD" = "$(git rev-parse HEAD)" ] && [ "${BUILD}" != "YES" ]; then
						BUILD="NO"
					else
						echo "resetting repo state $URL... "
						git reset --hard FETCH_HEAD
						git clean -xdf
						BUILD="YES"
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
				fi
				cd $WORK
			fi
		fi

		echo
		echo RADIR=$RADIR
	done < $RECIPE.ra
	cd $WORK
}

compile_filters()
{
	FILTER="$1"
	HELPER="$2"
	MAKE="$3"

	case "$FILTER" in
		audio ) FILTERDIR='libretro-common/audio/dsp_filters' ;;
		video ) FILTERDIR='gfx/video_filters' ;;
	esac

	echo "compile $FILTER filters"
	echo "$FILTER filter BUILD CMD: ${HELPER} ${MAKE}"
	( cd "$FILTERDIR"; ${HELPER} ${MAKE} )
	if [ $? -eq 0 ]; then
		echo "buildbot job: $jobid $FILTER filter build success!"
	else
		echo "buildbot job: $jobid $FILTER filter: [status: fail]!"
	fi
}

if [ "${RA}" = "YES" ]; then
	echo "buildbot job: $jobid Building Retroarch-$PLATFORM"
	echo --------------------------------------------------
	echo
	BUILD=""

	echo WORKINGDIR=$PWD
	echo RELEASE=$RELEASE
	echo FORCE=$FORCE_RETROARCH_BUILD
	echo RADIR=$RADIR
	echo BRANCH=$BRANCH

	buildbot_pull

	if [ "${BUILD}" = "YES" ] || [ "${FORCE}" = "YES" ] || [ "${FORCE_RETROARCH_BUILD}" = "YES" ] || [ "${CORES_BUILT}" = "YES" ]; then
		cd "$RADIR"
		git clean -xdf
		echo WORKINGDIR=$PWD
		echo RADIR=$RADIR

		echo "buildbot job: $jobid Building"
		echo

		if [ -n "${LOGURL}" ]; then
			ENTRY_ID="$(curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch" http://buildbot.fiveforty.net/build_entry/)"
		fi

		LOGFILE="$TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_${RECIPE##*/}.log"
	fi
fi

if [ "${PLATFORM}" == "osx" ] && [ "${RA}" == "YES" ]; then

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		cd pkg/apple

		xcodebuild -project RetroArch.xcodeproj -target RetroArch -configuration Release | tee "$LOGFILE"

		RET=$?
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

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

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		cd pkg/apple
		xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project RetroArch_iOS11.xcodeproj -configuration Release &> "$LOGFILE"
		RET=$?

		if [ $RET -eq 0 ]; then
			touch $TMPDIR/built-frontend
		fi

		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		ENTRY_ID=""
		cd $WORK/$RADIR

		echo "Packaging"

	fi
fi


if [ "${PLATFORM}" == "ios9" ] && [ "${RA}" == "YES" ]; then

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		cd pkg/apple
		xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project RetroArch_iOS9.xcodeproj -configuration Release -target "RetroArch iOS9" &> "$LOGFILE"

		RET=$?

		if [ $RET -eq 0 ]; then
			touch $TMPDIR/built-frontend
			cd build/Release-iphoneos
			security unlock-keychain -p buildbot /Users/buildbot/Library/Keychains/login.keychain
			codesign -fs "buildbot" RetroArch.app
		fi

		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		ENTRY_ID=""
		cd $WORK/$RADIR

		echo "Packaging"

	fi
fi


if [ "${PLATFORM}" = "android" ] && [ "${RA}" = "YES" ]; then

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" ]; then

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
		ant clean | tee -a "$LOGFILE"
		android update project --path . --target android-24 | tee -a "$LOGFILE"
		android update project --path libs/googleplay --target android-24 | tee -a "$LOGFILE"
		android update project --path libs/appcompat --target android-24 | tee -a "$LOGFILE"
		TARGET_ABIS=${TARGET_ABIS/arm64-v8a /} ant release | tee -a "$LOGFILE"
		if [ -z "$BRANCH" ]; then
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-release.apk | tee -a "$LOGFILE"
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-release.apk
		else
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-$BRANCH-release.apk | tee -a "$LOGFILE"
			cp -rv bin/retroarch-release.apk $RARCH_DIR/retroarch-$BRANCH-release.apk
		fi

		RET=$?
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		if [ $RET -eq 0 ]; then
			touch $TMPDIR/built-frontend
		fi

		ENTRY_ID=""
	fi
fi

if [ "${PLATFORM}" = "MINGW64" ] || [ "${PLATFORM}" = "MINGW32" ] || [ "${PLATFORM}" = "windows" ] && [ "${RA}" = "YES" ]; then

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" ]; then

		compile_filters audio ${HELPER} ${MAKE}
		compile_filters video ${HELPER} ${MAKE}

		echo "configuring..."
		echo "configure command: $CONFIGURE"
		${CONFIGURE}


		echo "cleaning up..."
		echo "CLEANUP CMD: ${HELPER} ${MAKE} ${ARGS} clean"
		${HELPER} ${MAKE} ${ARGS} clean

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
		echo "BUILD CMD: ${HELPER} ${MAKE} -j${JOBS} ${ARGS}"
		${HELPER} ${MAKE} -j${JOBS} ${ARGS} 2>&1 | tee -a "$LOGFILE"

		if [ "${CUSTOM_BUILD}" ]; then
			"${CUSTOM_BUILD}" 2>&1 | tee -a "$LOGFILE"
		fi

		strip -s retroarch.exe
		cp -v retroarch.exe.manifest windows/retroarch.exe.manifest 2>/dev/null
		cp -v retroarch.exe windows/retroarch.exe | tee -a "$LOGFILE"
		cp -v retroarch.exe windows/retroarch.exe

		status=$?
		echo $status

		buildbot_handle_message "$status" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		if [ $status -eq 0 ]; then
			touch $TMPDIR/built-frontend
			echo buildbot job: $MESSAGE >> "$LOGFILE"

			${HELPER} ${MAKE} ${ARGS} clean

			if [ -n "$LOGURL" ]; then
				ENTRY_ID=`curl -X POST -d type="start" -d master_log="$MASTER_LOG_ID" -d platform="$jobid" -d name="retroarch-debug" http://buildbot.fiveforty.net/build_entry/`
			fi

			${HELPER} ${MAKE} -j${JOBS} ${ARGS} DEBUG=1 GL_DEBUG=1 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			for i in $(seq 3); do for bin in $(ntldd -R *exe | grep -i mingw | cut -d">" -f2 | cut -d" " -f2); do cp -vu "$bin" . ; done; done

			if [ "${CUSTOM_BUILD_DEBUG}" ]; then
				"${CUSTOM_BUILD_DEBUG}" 2>&1 | tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			fi

			cp -v retroarch.exe.manifest windows/retroarch_debug.exe.manifest 2>/dev/null
			cp -v retroarch.exe windows/retroarch_debug.exe	| tee -a $TMPDIR/log/${BOT}/${LOGDATE}/${LOGDATE}_RetroArch_DEBUG_${PLATFORM}.log
			cp -v *.dll windows/
			cp -v retroarch.exe windows/retroarch_debug.exe

			(cd windows && windeployqt --release --no-patchqt --no-translations retroarch.exe)
			(cd windows && for i in $(seq 3); do for bin in $(ntldd -R imageformats/*dll | grep -i mingw | cut -d">" -f2 | cut -d" " -f2); do cp -vu "$bin" . ; done; done)

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
			echo buildbot job: $MESSAGE >> "$LOGFILE"
		fi
	fi
fi

if [ "${PLATFORM}" = "psp1" ] && [ "${RA}" = "YES" ]; then

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh psp1 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

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

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh wii 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

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

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .
		cp -v $RARCH_DIST_DIR/../info/*.info .
		cp -v ../media/assets/pkg/wiiu/*.png .

		time sh ./wiiu-cores.sh 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
	fi
fi

if [ "${PLATFORM}" == "ngc" ] && [ "${RA}" == "YES" ]; then

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh ngc 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

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

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .

		time sh ./dist-cores.sh ctr 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		ENTRY_ID=""

		cd $WORK/$RADIR
		echo $PWD

		echo "Packaging"

		cp retroarch.cfg retroarch.default.cfg

		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/cores
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/cores/info
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/remaps
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/cheats
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/filters
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/filters/audio
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/filters/video
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/database
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/database/rdb
		mkdir -p $WORK/$RADIR/pkg/ctr/build/retroarch/database/cursors


		cp -v $WORK/$RADIR/gfx/video_filters/*.filt $WORK/$RADIR/pkg/ctr/build/retroarch/filters/video/
		cp -v $WORK/$RADIR/libretro-common/audio/dsp_filters/*.dsp $WORK/$RADIR/pkg/ctr/build/retroarch/filters/audio/
		cp -v $RARCH_DIST_DIR/../info/*.info $WORK/$RADIR/pkg/ctr/build/retroarch/cores/info/
		cp -v $WORK/$RADIR/media/libretrodb/rdb/*.rdb $WORK/$RADIR/pkg/ctr/build/retroarch/database/rdb/
		cp -v $WORK/$RADIR/media/libretrodb/cursors/*.dbc $WORK/$RADIR/pkg/ctr/build/retroarch/database/cursors/

		convert_xmb_assets $WORK/$RADIR/media/assets/xmb $WORK/$RADIR/pkg/ctr/build/retroarch/media/xmb 64x32! 400x240! 90
	fi
fi

if [ "${PLATFORM}" == "vita" ] && [ "${RA}" == "YES" ]; then

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.a .
		cp -v $RARCH_DIST_DIR/arm/*.a .

		time sh ./dist-cores.sh vita 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
		cp retroarch.cfg retroarch.default.cfg
		
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/info
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/remaps
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/cheats
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/filters
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/filters/audio
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/filters/video
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/database
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/database/rdb
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/database/cursors
		mkdir -p $WORK/$RADIR/pkg/vita/retroarch/assets/glui


		cp -v $WORK/$RADIR/gfx/video_filters/*.filt $WORK/$RADIR/pkg/vita/retroarch/filters/video/
		cp -v $WORK/$RADIR/libretro-common/audio/dsp_filters/*.dsp $WORK/$RADIR/pkg/vita/retroarch/filters/audio/
		cp -v $RARCH_DIST_DIR/../info/*.info $WORK/$RADIR/pkg/vita/retroarch/info/
		cp -v $WORK/$RADIR/media/libretrodb/rdb/*.rdb $WORK/$RADIR/pkg/vita/retroarch/database/rdb/
		cp -v $WORK/$RADIR/media/libretrodb/cursors/*.dbc $WORK/$RADIR/pkg/vita/retroarch/database/cursors/
		cp -v $WORK/$RADIR/media/libretrodb/cursors/*.dbc $WORK/$RADIR/pkg/vita/retroarch/database/cursors/
		cp -r $WORK/$RADIR/media/assets/glui $WORK/$RADIR/pkg/vita/retroarch/assets
		
		convert_xmb_assets $WORK/$RADIR/media/assets/xmb $WORK/$RADIR/pkg/vita/retroarch/assets/xmb 64x64! 960x544! 90
		
	fi
fi

if [ "${PLATFORM}" == "ps3" ] && [ "${RA}" == "YES" ]; then

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

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

	if [ "${BUILD}" == "YES" -o "${FORCE}" == "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" -o "${CORES_BUILT}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		cd dist-scripts
		rm *.a
		cp -v $RARCH_DIST_DIR/*.bc .

		echo "BUILD CMD $HELPER ./dist-cores.sh emscripten" &> "$LOGFILE"
		$HELPER ./dist-cores.sh emscripten 2>&1 | tee -a "$LOGFILE"

		RET=${PIPESTATUS[0]}
		buildbot_handle_message "$RET" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"
		ENTRY_ID=""

		echo "Packaging"

		cd $WORK/$RADIR
	fi
fi

if [ "${PLATFORM}" = "unix" ] && [ "${RA}" = "YES" ]; then

	if [ "${BUILD}" = "YES" -o "${FORCE}" = "YES" -o "${FORCE_RETROARCH_BUILD}" == "YES" ]; then

		touch $TMPDIR/built-frontend

		compile_filters audio ${HELPER} ${MAKE}
		compile_filters video ${HELPER} ${MAKE}

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

		echo "building..."
		echo "BUILD CMD: ${HELPER} ${MAKE} -j${JOBS}"
		${HELPER} ${MAKE} -j${JOBS} 2>&1 | tee -a "$LOGFILE"

		status=$?
		echo $status

		buildbot_handle_message "$status" "$ENTRY_ID" "retroarch" "$jobid" "$LOGFILE"

		if [ $status -eq 0 ]; then
			MESSAGE="retroarch:	[status: done] [$jobid]"
			echo buildbot job: $MESSAGE >> "$LOGFILE"
			echo "Packaging"
		else
			MESSAGE="retroarch:	[status: fail] [$jobid]"
			echo buildbot job: $MESSAGE >> "$LOGFILE"
		fi
	fi
fi

PATH=$ORIGPATH
