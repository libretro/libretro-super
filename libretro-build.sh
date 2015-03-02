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
	RARCH_DIR="$WORKDIR/dist"
	RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi

if [ -z "$JOBS" ]; then
	JOBS=7
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
		# FIXME: Do this right later.
		if [ "$ARCH" = "i386" ]; then
			CC="cc -arch i386"
			CXX="c++ -arch i386"
			CXX11="clang++ -arch i386 -std=c++11 -stdlib=libc++"
		fi
	elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
		CXX=mingw32-g++
		CXX11=mingw32-g++
	else
		CXX=g++
		CXX11=g++
	fi
fi

FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET


if [ "$FORMAT_COMPILER_TARGET" = "ios" ]; then
	echo "iOS path: ${IOSSDK}"
	echo "iOS version: ${IOSVER}"
fi
echo "CC = $CC"
echo "CXX = $CXX"
echo "CXX11 = $CXX11"
echo "STRIP = $STRIP"


. "$BASE_DIR/libretro-build-common.sh"

mkdir -p "$RARCH_DIST_DIR"

if [ -n "$SKIP_UNCHANGED" ]; then
	[ -z "$BUILD_REVISIONS_DIR" ] && BUILD_REVISIONS_DIR="$WORKDIR/build-revisions"
	echo "mkdir -p \"$BUILD_REVISIONS_DIR\""
	mkdir -p "$BUILD_REVISIONS_DIR"
fi

if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		case "$1" in
			build_libretro_*)
				# "Old"-style
				$1
				;;
			*)
				# New style (just generic cores for now)
				libretro_build_core $1
				;;
		esac
		shift
	done
else
	libretro_build_core 2048
	libretro_build_core 4do
	libretro_build_core bluemsx
	libretro_build_core fmsx
	build_libretro_bsnes_cplusplus98
	build_libretro_bsnes
	build_libretro_bsnes_mercury
	libretro_build_core beetle_lynx
	libretro_build_core beetle_gba
	libretro_build_core beetle_ngp
	libretro_build_core beetle_pce_fast
	libretro_build_core beetle_supergrafx
	libretro_build_core beetle_pcfx
	libretro_build_core beetle_vb
	libretro_build_core beetle_wswan
	libretro_build_core mednafen_psx
	libretro_build_core beetle_snes
	libretro_build_core catsfc
	libretro_build_core snes9x
	libretro_build_core snes9x_next
	libretro_build_core genesis_plus_gx
	libretro_build_core fb_alpha
	libretro_build_core vbam
	libretro_build_core vba_next
	libretro_build_core fceumm
	libretro_build_core gambatte
	libretro_build_core meteor
	libretro_build_core nxengine
	libretro_build_core prboom
	libretro_build_core stella
	libretro_build_core quicknes
	libretro_build_core nestopia
	libretro_build_core tyrquake
	libretro_build_core mame078
	build_libretro_mame
	libretro_build_core dosbox
	libretro_build_core scummvm
	libretro_build_core picodrive
	libretro_build_core handy
	libretro_build_core desmume
	if [ $FORMAT_COMPILER_TARGET != "win" ]; then
		libretro_build_core pcsx_rearmed
	fi
	if [ $FORMAT_COMPILER_TARGET = "ios" ]; then
		# For self-signed iOS (without jailbreak)
		build_libretro_pcsx_rearmed_interpreter
	fi
	libretro_build_core yabause
	libretro_build_core vecx
	libretro_build_core tgbdual
	libretro_build_core prosystem
	libretro_build_core dinothawr
	libretro_build_core virtualjaguar
	build_libretro_mupen64
	libretro_build_core 3dengine
	if [ $FORMAT_COMPILER_TARGET != "ios" ]; then
		# These don't currently build on iOS
		build_libretro_bnes
		build_libretro_core ffmpeg
		build_libretro_core ppsspp
	fi
	libretro_build_core o2em
	libretro_build_core hatari
	libretro_build_core gpsp
	build_libretro_emux
	libretro_build_core fuse
	libretro_build_core stonesoup
	libretro_build_core nxengine
	libretro_build_core gw

	build_libretro_test
fi
build_summary
