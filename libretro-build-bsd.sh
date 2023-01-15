#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR="$PWD"
# CFLAGS="$CFLAGS -fno-common"

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
elif [[ "$0" != /* ]]; then
	# Make the path absolute
	BASE_DIR="$WORKDIR/$BASE_DIR"
fi

. "$BASE_DIR/libretro-config.sh"

if [ -z "$RARCH_DIST_DIR" ]; then
	RARCH_DIR="$WORKDIR/dist"
	RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi

JOBS=${JOBS:-7}

CC=gcc10
CXX=g++10
# CXX=c++
# CXX11=g++10
CXX11="clang++ -std=c++11 -stdlib=libc++"
# CXX17=g++10
CXX17="clang++ -std=c++17 -stdlib=libc++"
STRIP=strip
MAKE=gmake

. "$BASE_DIR/libretro-build-common.sh"

# These are cores which only work properly right
# now on little-endian architecture systems

build_default_cores_little_endian_only() {
	libretro_build_core tgbdual
	if [ $platform != "psp1" ]; then
		libretro_build_core gpsp
		libretro_build_core o2em
	fi
	libretro_build_core opera

	if [ $platform != "qnx" ]; then
		if [ $platform != "psp1" ]; then
			libretro_build_core desmume
			libretro_build_core desmume2015
		fi
		libretro_build_core picodrive
	fi

	# TODO - Verify endianness compatibility - for now exclude
	libretro_build_core virtualjaguar
}

# These are C++11 cores

build_default_cores_cpp11() {
	libretro_build_core dinothawr
	libretro_build_core stonesoup
	libretro_build_core bsnes_accuracy
	libretro_build_core bsnes_balanced
	libretro_build_core bsnes_performance
	libretro_build_core bsnes_mercury_accuracy
	libretro_build_core bsnes_mercury_balanced
	libretro_build_core bsnes_mercury_performance
	libretro_build_core mame2015
	libretro_build_core mame2016
	libretro_build_core mame
}

# These are cores intended for platforms with a limited
# amount of RAM, where the full version would not fit
# into memory

build_default_cores_small_memory_footprint() {
	libretro_build_core fb_alpha_cps1
	libretro_build_core fb_alpha_cps2
	libretro_build_core fb_alpha_neo
}

build_default_cores_libretro_gl() {
	# Reasons for not compiling this yet on these targets (other than endianness issues)
	# 1) Wii/NGC - no PPC dynarec, no usable graphics plugins that work with GX
	# 2) PS3     - no PPC dynarec, PSGL is GLES 1.0 while graphics plugins right now require GL 2.0+/GLES2
	# 3) QNX     - Compilation issues, ARM NEON compiler issues
	if [ $platform != "qnx" ]; then
		libretro_build_core mupen64plus
	fi

	# Graphics require GLES 2/GL 2.0
	if [ $platform != "psp1" ]; then
		libretro_build_core 3dengine
	fi
}

# These build everywhere libretro-build.sh works
# (They also use rules builds, which will help later)

build_default_cores() {
	if [ $platform == "wii" ] || [ $platform == "ngc" ] || [ $platform == "psp1" ]; then
		build_default_cores_small_memory_footprint
	fi
	libretro_build_core 2048
	libretro_build_core bluemsx

	if [ $platform != "psp1" ] && [ $platform != "ngc" ] && [ $platform != "wii" ] && [ $platform != "ps3" ] && [ $platform != "sncps3" ] && [ $platform != "vita" ]; then
		libretro_build_core dosbox
	fi

	libretro_build_core snes9x2005
	libretro_build_core chimerasnes
	if [ $platform != "psp1" ]; then
		# Excluded for binary size reasons
		libretro_build_core fbneo
	fi
	libretro_build_core fceumm
	libretro_build_core fmsx
	libretro_build_core gambatte
	libretro_build_core handy
	libretro_build_core stella
	libretro_build_core nestopia
	libretro_build_core numero
	libretro_build_core nxengine
	libretro_build_core prboom
	libretro_build_core quicknes
	libretro_build_core snes9x2010
	libretro_build_core tyrquake
	libretro_build_core vba_next
	libretro_build_core vecx

	if [ $platform != "psp1" ]; then
		# (PSP) Compilation issues
		libretro_build_core mgba
		# (PSP) Performance issues
		libretro_build_core genesis_plus_gx
	fi

	if [ $platform != "psp1" ] && [ $platform != "wii" ] && [ $platform != "ngc" ] && [ $platform != "vita" ]; then
		# (PSP/NGC/Wii/Vita) Performance and/or binary size issues
		libretro_build_core bsnes_cplusplus98
		libretro_build_core mame2003
		libretro_build_core mednafen_gba
	fi

	libretro_build_core mednafen_lynx
	libretro_build_core mednafen_ngp
	libretro_build_core mednafen_pce_fast

	libretro_build_core mednafen_supergrafx
	libretro_build_core mednafen_vb
	libretro_build_core mednafen_wswan
	libretro_build_core mu

	libretro_build_core gw
	libretro_build_core prosystem

	if [ $platform != "ps3" ] && [ $platform != "sncps3" ] && [ $platform != "vita" ]; then
		libretro_build_core 81
		libretro_build_core fuse
		libretro_build_core lutro
	fi

	if [ $platform != "ps3" ] && [ $platform != "sncps3" ] && [ $platform != "wii" ] && [ $platform != "wiiu" ] && [ $platform != "ngc" ] && [ $platform != "vita" ]; then
		build_default_cores_little_endian_only

		build_default_cores_libretro_gl

		if [ $platform != "psp1" ]; then
			# (PS3/NGC/Wii/PSP) Excluded for performance reasons
			libretro_build_core snes9x
			libretro_build_core vbam

			# The only reason ScummVM won't be compiled in yet is
			# 1) Wii/NGC/PSP - too big in binary size
			# 2) PS3 - filesystem API issues
			libretro_build_core scummvm

			# Excluded for performance reasons
			libretro_build_core mednafen_pcfx
			libretro_build_core mednafen_psx
			libretro_build_core mednafen_psx_hw
			if [ $platform != "qnx" ]; then
				libretro_build_core mednafen_snes
			fi
		fi

		# Could work on PS3/Wii right now but way too slow right now,
		# and messed up big-endian colors
		libretro_build_core yabause

		# Compilation/port status issues
		libretro_build_core hatari
		libretro_build_core meteor


		if [ $platform != "qnx" ] && [ $platform != "psp1" ] && [ $platform != "vita" ]; then
			libretro_build_core mame2010

			build_default_cores_cpp11

			# Just basic compilation issues right now for these platforms
			libretro_build_core emux

			if [ $platform != "win" ]; then
				# Reasons for not compiling this on Windows yet -
				# (Windows) - Doesn't work properly
				# (QNX)     - Compilation issues
				# (PSP1)    - Performance/compilation issues
				# (Wii)     - Performance/compilation issues
				# (PS3)     - Performance/compilation issues
				libretro_build_core pcsx_rearmed
			fi

			if [ $platform != "ios" ] || [ $platform != "ios9" ]; then
				# Would need ffmpeg libraries baked in
				libretro_build_core ffmpeg
				libretro_build_core ppsspp

				libretro_build_core bnes
			fi
		fi

		build_libretro_test
	fi
}


mkdir -p "$RARCH_DIST_DIR"

if [ -n "$SKIP_UNCHANGED" ]; then
	[ -z "$BUILD_REVISIONS_DIR" ] && BUILD_REVISIONS_DIR="$WORKDIR/build-revisions"
	echo "mkdir -p \"$BUILD_REVISIONS_DIR\""
	mkdir -p "$BUILD_REVISIONS_DIR"
fi

if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		case "$1" in
			--nologs)
				LIBRETRO_LOG_SUPER=""
				LIBRETRO_LOG_CORE=""
				;;
			*)
				# New style (just generic cores for now)
				want_cores="$want_cores $1"
				;;
		esac
		shift
	done
fi

libretro_log_init
if [ -n "$want_cores" ]; then
	for core in $want_cores; do
		libretro_build_core $core
	done
else
	build_default_cores
fi
summary
