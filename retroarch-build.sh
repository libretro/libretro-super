#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR="$PWD"

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
else
	if [[ "$0" != /* ]]; then
		# Make the path absolute
		BASE_DIR="$WORKDIR/$BASE_DIR"
	fi
fi

. "$BASE_DIR/libretro-config.sh"

if [ -z "$RARCH_DIST_DIR" ]; then
	RARCH_DIR="$BASE_DIR/dist"
	RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi

die()
{
	echo $1
	#exit 1
}

if [ "$HOST_CC" ]; then
	CC="${HOST_CC}-gcc"
	CXX="${HOST_CC}-g++"
	STRIP="${HOST_CC}-strip"
fi

if [ -z "$MAKE" ]; then
	if [ "$(expr substr $(uname -s) 1 7)" = "MINGW32" ]; then
		MAKE=mingw32-make
	else
		MAKE=make
	fi
fi

if [ -z "$CC" ]; then
	if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
		CC=clang
	elif [ "$(expr substr $(uname -s) 1 7)" = "MINGW32" ]; then
		CC=mingw32-gcc
	else
		CC=gcc
	fi
fi

if [ -z "$CXX" ]; then
	if [ $FORMAT_COMPILER_TARGET = "osx" ]; then
		CXX=clang++
	elif [ "$(expr substr $(uname -s) 1 7)" = "MINGW32" ]; then
		CXX=mingw32-g++
	else
		CXX=g++
	fi
fi

echo "CC = $CC"
echo "CXX = $CXX"
echo "STRIP = $STRIP"

mkdir -p "$RARCH_DIST_DIR"

export RARCHCFLAGS=""

check_deps()
{
	if [ $ENABLE_GLES ]; then
		echo "=== Enabling OpenGL ES ==="
		export ENABLE_GLES="--enable-gles"
	fi
	if [ $ARM_NEON ]; then
		echo "=== Enabling ARM NEON support ==="
		export ENABLE_NEON="--enable-neon"
	fi

	if [ $ARM_HARDFLOAT ]; then
		echo "=== Enabling ARM Hard float ABI support ==="
		export RARCHCFLAGS="${RARCHCFLAGS} -mfloat-abi=hard"
	fi
	if [ $ARM_SOFTFLOAT ]; then
		echo "=== Enabling ARM Soft float ABI support ==="
		export RARCHCFLAGS="${RARCHCFLAGS} -mfloat-abi=softfp"
	fi
	if [ "$CORTEX_A8" ]; then
		echo "=== Enabling Cortex A8 CFLAGS ==="
		export RARCHCFLAGS="${RARCHCFLAGS} -mcpu=cortex-a8 -mtune=cortex-a8"
	fi
	if [ "$CORTEX_A9" ]; then
		echo "=== Enabling Cortex A9 CFLAGS ==="
		export RARCHCFLAGS="${RARCHCFLAGS} -mcpu=cortex-a9 -mtune=cortex-a9"
	fi

	if [ $ARM_NEON ]; then
		echo "=== Enabling ARM NEON support (CFLAGS) ==="
		export RARCHCFLAGS="${RARCHCFLAGS} -mfpu=neon"
	fi
}

build_retroarch()
{
	cd "$BASE_DIR"
	pwd
	if [ -d "retroarch" ]; then
		echo "=== Building RetroArch ==="
		cd retroarch
		check_deps
		
		if [ -z "${NOCLEAN}" ]; then
			./configure $ENABLE_GLES $ENABLE_NEON
			${MAKE} -f Makefile platform=${FORMAT_COMPILER_TARGET} CC="gcc ${RARCHCFLAGS}" $COMPILER -j$JOBS clean || die "Failed to clean RetroArch"
		fi
		${MAKE} -f Makefile platform=${FORMAT_COMPILER_TARGET} CC="gcc ${RARCHCFLAGS}" $COMPILER -j$JOBS || die "Failed to build RetroArch"
	else
		echo "RetroArch not fetched, skipping ..."
	fi
}

if [ $1 ]; then
	$1
else
	build_retroarch
fi
