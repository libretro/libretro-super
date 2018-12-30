#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

libretro_version="1.1"
default_actions="fetch clean compile"

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


####################################################################
##
## NEW TOOLCHAIN STUFF
## FIXME: This stuff is incomplete and won't quite work as I've done it here.
##        Doing it right is going to depend on the config submodule which isn't
##        written yet.  Probably after 1.1...  :/
##
####################################################################
#
##register_toolchain osx x86 x86_64
#toolchain_osx_CC="cc"
#toolchain_osx_CXX="c++"
#toolchain_osx_CXX11="clang++"
#toolchain_osx_CXX11_args="-std=c++11 -stdlib=libc++"
#toolchain_osx_x86_args=" -arch i386"
#toolchain_osx_x86_64_args=" -arch x86_64"
#toolchain_osx_platform="osx"
#
##register_toolchain ios armv7 # x86?
#toolchain_ios_CC="cc"
#toolchain_ios_CXX="c++"
#toolchain_ios_CXX11="clang++"
#toolchain_ios_CXX11_args="-std=c++11 -stdlib=libc++"
#toolchain_ios_armv7_args="-arch armv7 -marm -miphoneos-version-min=5.0 -isysroot \$IOSSDK"
#toolchain_ios_platform="ios"
#toolchain_ios_configure() {
#	if [ -z "$IOSSDK" ]; then
#		if [ -z "${xcodebuild:-$(find_tool xcodebuild)}" ]; then
#			lsecho "You must set IOSSDK or have xcodebuild in your path for ios"
#			return 1
#		fi
#		export IOSSDK=$(xcodebuild -version -sdk iphoneos Path)
#	fi
#
#	if [ ! -d "$IOSSDK/usr" ]; then
#		lsecho "\"$IOSSDK\" does not appear to be a valid iOS SDK."
#		return 1
#	fi
#}
#
#toolchain_guess() {
#	if [ -z "${UNAME:+$(find_tool $LIBRETRO_UNAME uname)}" ]; then
#		lsecho "toolchain_guess: cannot find the uname program to guess your platform"
#		return 1
#	fi
#
#	local cpu="$(uname -m)"
#	case "$cpu" in
#		x86_64) ;;
#		i[3456]86) ;;
#		armv4) ;;
#		armv7) ;;
#	esac
#
#	local os="$(uname -s)"
#
#	case "$(uname -s)" in
#		# uname will find these
#
#		*BSD*) os="bsd" ;;
#		linux) os="linux" ;;
#		*mingw*|*MINGW*|*MSYS_NT*) os="win" ;;
#
#		Darwin)
#			# TODO: This won't support iOS simulator, add something that will
#			if [ "$cpu" = arm* ]; then
#				os="ios"
#			else
#				os="osx"
#			fi
#			;;
#
#		# Consoles and mobile, uname won't usually report these
#		android) os="android" ;;
#		ios) os="ios" ;;
#		ngc) os="ngc" ;;
#		psp1) os="psp1" ;;
#		wii) os="wii" ;;
#	esac
#}
#
#toolchain_setup() {
#	if [[ "$1" != *-* ]]; then
#		lsecho "toolchain_setup: Invalid platform \"$1\""
#		return 1
#	fi
#	local os="${1%%-*}"
#	local cpu="${1#*-}"
#
#	eval "local cpu_prefix=\"\$toolchain_${os}_${cpu}_prefix\""
#	eval "local cpu_suffix=\"\$toolchain_${os}_${cpu}_suffix\""
#	eval "local cpu_args=\"\$toolchain_${os}_${cpu}_args\""
#	toolchain_platform="$1"
#
#	if [ "$(type -t toolchain_${os}_configure)" ]; then
#		toolchain_configure=toolchatarget_in_${os}_configure
#	else
#		toolchain_configure=do_nothing
#	fi
#
#	for compiler in CC CXX CXX11; do
#		eval "cmdline=\"\$toolchain_${os}_${cpu}_prefix\$toolchain_${os}_${compiler}\$toolchain_${os}_${cpu}_suffix\""
#		eval "compiler_args=\"\$toolchain_${os}_${compiler}_args\""
#		if command -v $cmdline > /dev/null; then
#			eval "toolchain_$compiler=\"\$cmdline\${cpu_args:+ \$cpu_args}\${compiler_args:+ \$compiler_args}\""
#		else
#			eval "toolchain_$compiler=\"\""
#		fi
#	done
#}

###################################################################
#
# OLD TOOLCHAIN STUFF (basically libretro-config.sh)
# For now, if you want to build for other than the detected default
# you're going to have to do it the old way.  Something like this:
#
#    platform=<foo> ARCH=<bar> ./libretro-super.sh
#
# This will be replaced by a rules-based solution (similar to how
# cores are handled, but not yet.
#
###################################################################

# The platform variable is normally not set at the time libretro-config is
# included by libretro-build.sh.  Other platform scripts may begin to include
# libretro-config as well if they define their platform-specific code in the
# case block below.  This is a band-aid fix that we will address after 1.1 is
# released.

case "$platform" in
	##
	## Configs that did not use libretro-config originally
	## TODO: Integrate this with everything else (post-1.1)
	##

	ios)
		# NOTE: This config requires a Mac with an Xcode installation.  These
		#       scripts will work at least as far as 10.5 that we're sure of, but
		#       we build with clang targeting iOS >= 5.  We'll accept patches for
		#       older versions of iOS.

		DIST_DIR="ios"
		FORMAT_EXT=dylib
		IOS=1
		ARCH=armv7
		FORMAT=_ios
		FORMAT_COMPILER_TARGET=ios
		FORMAT_COMPILER_TARGET_ALT=ios
		export IOSSDK=$(xcodebuild -version -sdk iphoneos Path)
		iosver=$(xcodebuild -version -sdk iphoneos ProductVersion)
		IOSVER_MAJOR=${iosver%.*}
		IOSVER_MINOR=${iosver#*.}
		IOSVER=${IOSVER_MAJOR}${IOSVER_MINOR}
		MIN_IOS5="-miphoneos-version-min=5.0"
		MIN_IOS7="-miphoneos-version-min=7.0"

		# Use generic names rather than gcc/clang to better support both
		CC="cc -arch armv7 -marm -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX="c++ -arch armv7 -marm -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch armv7 -marm -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		;;

	##
	## Original libretro-config path
	##
	*)

		# Architecture Assignment
		config_cpu() {
			[ -n "$2" ] && ARCH="$1"
			[ -z "$ARCH" ] && ARCH="$(uname -m)"
			case "$ARCH" in
				x86_64)
					X86=true
					X86_64=true
					;;
				i386|i686)
					X86=true
					;;
				armv*)
					ARM=true
					export FORMAT_COMPILER_TARGET=armv
					export RARCHCFLAGS="$RARCHCFLAGS -marm"
					case "$ARCH" in
						armv5tel) ARMV5=true ;;
						armv6l)	ARMV6=true ;;
						armv7l)	ARMV7=true ;;
					esac
					;;
			esac
			if [ -n "$PROCESSOR_ARCHITEW6432" -a "$PROCESSOR_ARCHITEW6432" = "AMD64" ]; then
				ARCH=x86_64
				X86=true && X86_64=true
			fi
		}

		# Platform Assignment
		config_platform() {
			[ -n "$1" ] && platform="$1"
			[ -z "$platform" ] && platform="$(uname)"
			case "$platform" in
				*BSD*)
					platform=bsd
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="unix"
					DIST_DIR="bsd"
					;;
				*Haiku*)
					platform=haiku
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="unix"
					DIST_DIR="haiku"
					;;
				osx|*Darwin*)
					platform=osx
					FORMAT_EXT="dylib"
					FORMAT_COMPILER_TARGET="osx"
					case "$ARCH" in
						x86_64|i386|ppc*)
							DIST_DIR="osx-$ARCH"
							;;
						*)
							DIST_DIR="osx-unknown"
							;;
					esac
					;;
				win|*mingw32*|*MINGW32*|*MSYS_NT*)
					platform=win
					FORMAT_EXT="dll"
					FORMAT_COMPILER_TARGET="win"
					DIST_DIR="win_x86"
					;;
				win64|*mingw64*|*MINGW64*)
					platform=win
					FORMAT_EXT="dll"
					FORMAT_COMPILER_TARGET="win"
					DIST_DIR="win_x64"
					;;
				*psp1*)
					platform=psp1
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="psp1"
					DIST_DIR="psp1"
					;;
				*ps2*)
					platform=ps2
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="ps2"
					DIST_DIR="ps2"
					;;
				*wii*)
					platform=wii
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="wii"
					DIST_DIR="wii"
					;;
				*ngc*)
					platform=ngc
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="ngc"
					DIST_DIR="ngc"
					;;
				theos_ios*)
					platform=theos_ios
					FORMAT_EXT="dylib"
					FORMAT_COMPILER_TARGET="theos_ios"
					DIST_DIR="theos_ios"
					;;
				android)
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="android"
					DIST_DIR="android"
					;;
				android-armv7)
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="android-armv7"
					DIST_DIR="android/armeabi-v7a"
					;;
				*)
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="unix"
					DIST_DIR="unix"
					;;
			esac
			export FORMAT_COMPILER_TARGET_ALT="$FORMAT_COMPILER_TARGET"
		}

		config_log_build_host() {
			echo "PLATFORM: $platform"
			echo "ARCHITECTURE: $ARCH"
			echo "TARGET: $FORMAT_COMPILER_TARGET"
		}

		config_cpu
		config_platform
		config_log_build_host

		if [ -z "$JOBS" ]; then
			# nproc is generally Linux-specific.
			if command -v nproc >/dev/null; then
				JOBS="$(nproc)"
			elif [ "$pltaform" = "osx" ] && command -v sysctl >/dev/null; then
				JOBS="$(sysctl -n hw.physicalcpu)"
			else
				JOBS=1
			fi
		fi
		;;
esac

# Taken from LIBRETRO-BUILD-COMMON.SH
[[ "${ARM_NEON}" ]] && echo '=== ARM NEON opts enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-neon"
[[ "${CORTEX_A8}" ]] && echo '=== Cortex A8 opts enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-cortexa8"
[[ "${CORTEX_A9}" ]] && echo '=== Cortex A9 opts enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo '=== ARM hardfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo '=== ARM softfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-softfloat"
[[ "$X86" ]] && echo '=== x86 CPU detected... ==='
[[ "$X86" ]] && [[ "$X86_64" ]] && echo '=== x86_64 CPU detected... ==='

#if uncommented, will build experimental cores as well which are not yet fit for release.
#export BUILD_EXPERIMENTAL=1

#ARM DEFINES
#===========

#if uncommented, will build cores with Cortex A8 compiler optimizations
#export CORTEX_A8=1

#if uncommented, will build cores with Cortex A9 compiler optimizations
#export CORTEX_A9=1

#if uncommented, will build cores with ARM hardfloat ABI
#export ARM_HARDFLOAT=1

#if uncommented, will build cores with ARM softfloat ABI
#export ARM_SOFTFLOAT=1

#if uncommented, will build cores with ARM NEON support (ARMv7+ only)
#export ARM_NEON=1

#OPENGL DEFINES
#==============

#if uncommented, will build libretro GL cores. Ignored for mobile platforms - GL cores will always be built there.
export BUILD_LIBRETRO_GL=1

#if uncommented, will build cores with OpenGL ES 2 support. Not needed
#for platform-specific cores - only for generic core builds (ie. libretro-build.sh)
#export ENABLE_GLES=1

#ANDROID DEFINES
#================

export TARGET_ABIS="armeabi armeabi-v7a x86"

#uncomment to define NDK standalone toolchain for ARM
#export NDK_ROOT_DIR_ARM = 

#uncomment to define NDK standalone toolchain for MIPS
#export NDK_ROOT_DIR_MIPS = 

#uncomment to define NDK standalone toolchain for x86
#export NDK_ROOT_DIR_X86 =

# android version target if GLES is in use
export NDK_GL_HEADER_VER=android-18

# android version target if GLES is not in use
export NDK_NO_GL_HEADER_VER=android-9

# Retroarch target android API level
export RA_ANDROID_API=android-18

# Retroarch minimum API level (defines low end android version compatability)
export RA_ANDROID_MIN_API=android-9

#OSX DEFINES
#===========

# [snip]
# Let's disable universal builds completely for now.  We don't use it, the new
# toolchain code won't need it, and most of the cores don't currently support
# it anyway.  We'll revisit this later.
export NOUNIVERSAL=1

# OUTPUT AND LOGGING
# ==================
#
# This is kind of an inline design document that'll be changed for basic user
# instructions when the logging system is finished and tested.
#
# libretro-super has two kinds of output, the basic kind showing what the
# script is doing in a big-picture sense, and the commands and output from
# individual commands.  End-users don't necessarily need to see this more
# detailed output, except when we're talking about huge cores like mame.
#
# If each can be directed to null, to the screen, to a log file, or to both
# the screen and a log file, you end up with a matrix os 16 possibilities.  Of
# those, only a few are truly useful:
#
# 	Basic		Detailed		Useful to
#	screen	screen		developer/end-user w/ space issues
#	screen	both			developer
#	both		both			developer
#	screen	log			end-user
#	log		log			buildbot
#
# What this tells me is that we need to log by default, as long as we kill
# old logfiles to avoid filling your HD with gigabytes of mame build logs.
# Output should go to both screen and log for developers, but users don't need
# to see the make commands, etc.  Being able to disable both would be useful,
# but that a near-term TODO item.  That just leaves being able to squelch the
# screen output for buildbot usage, and that's just > /dev/null on the command
# line, so not our problem here.
#
# Again, the ability to turn OFF these logs will be wanted very soon.

# Uncomment this to avoid clobbering logs
#LIBRETRO_LOG_APPEND=1

# Change this to adjust where logs are written
#LIBRETRO_LOG_DIR="$WORKDIR/log"

# Change this to rename the libretro-super main log file
#LIBRETRO_LOG_SUPER="libretro-super.log"

# Change this to rename core log files (%s for core's "safe" name)
#LIBRETRO_LOG_CORE="%s.log"

# Comment this if you don't need to see developer output
LIBRETRO_DEVELOPER=1


# COLOR IN OUTPUT
# ===============
#
# If you don't like ANSI-style color in your output, uncomment this line.
#NO_COLOR=1

# If you want to force it even in log files, uncomment this line.
#FORCE_COLOR=1

#USER DEFINES
#------------
#These options should be defined inside your own
#local libretro-config-user.sh file rather than here.
#The following below is just a sample.

if [ -f "$WORKDIR/libretro-config-user.sh" ]; then
	. "$WORKDIR/libretro-config-user.sh"
fi

###################################################################
#
# LIBRETRO-BUILD-COMMON
# Summary already re-written, CORE_SUFFIX def may be moved
# RARCH_DIST_DIR stuff will change with new toolchain code
#
###################################################################

CORE_SUFFIX="_libretro${FORMAT}.$FORMAT_EXT"

summary() {
	# fmt is external and may not be available
	fmt_output="$(find_tool "fmt")"
	local num_success="$(numwords $build_success)"
	local fmt_success="${fmt_output:+$(echo "	$build_success" | $fmt_output)}"
	local num_fail="$(numwords $build_fail)"
	local fmt_fail="${fmt_output:+$(echo "	$build_fail" | $fmt_output)}"

	if [[ -z "$build_success" && -z "$build_fail" ]]; then
		lsecho "No build actions performed."
		return
	fi

	if [ -n "$build_success" ]; then
		secho "$(color 32)$num_success module(s)$(color) compiled successfully:"
		lecho "$num_success module(s) successfully processed:"
		lsecho "$fmt_success"
	fi
	if [ -n "$build_fail" ]; then
		secho "$(color 31)$num_fail module(s)$(color) failed to compile:"
		lecho "$num_fail module(s) failed:"
		lsecho "$fmt_fail"
	fi
}

create_dist_dir() {
	mkdir -p "$RARCH_DIST_DIR"
}

if [ -z "$RARCH_DIST_DIR" ]; then
	RARCH_DIR="$WORKDIR/dist"
	RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi
create_dist_dir


# The following bits are from libretro-build.sh
# Will replace with new toolchain code later

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
	if uname -s | grep -i MINGW > /dev/null 2>&1; then
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


###################################################################
#
# END OF INSERTED OLD SCRIPT BITS
#
###################################################################

shopt -q nullglob || reset_nullglob=1

. "$BASE_DIR/script-modules/log.sh"
. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/cpu.sh"
. "$BASE_DIR/script-modules/module_base.sh"
. "$BASE_DIR/script-modules/module_process.sh"

# Read all of the rules file
shopt -s nullglob
cd "$BASE_DIR" # Cope with whitespace in $BASE_DIR
for rules_file in rules.d/*; do
	. $rules_file
done
[ -n "$reset_noglob" ] && shopt -u nullglob

skip_unchanged=""
libretro_log_init
if [ -n "$1" ]; then
	opt_terminator=""
	actions=""
	types=""
	process=""

	while [ -n "$1" ]; do
		if [[ "$1" = -* && -z "$opt_terminator" ]]; then
			case "$1" in

				#
				# Informational
				#

				# TODO
				--help) 
					info_only=1
					;;

				--license|--licence)
					info_only=1
					show_license=1
					LIBRETRO_LOG_SUPER=""
					LIBRETRO_LOG_MODULE=""
					;;

				--nologs)
					LIBRETRO_LOG_SUPER=""
					LIBRETRO_LOG_MODULE=""
					;;

				#
				# Configuration controls
				#

				# TODO
				--config|--configure) ;;

				--devel) LIBRETRO_DEVELOPER=1 ;;
				--no-devel) LIBRETRO_DEVELOPER="" ;;

				--force) force=1 ;;
				--skip-unchanged) skip_unchanged=1 ;;
				--no-skip-unchanged) skip_unchanged=0 ;;

				#
				# Action controls
				#

				--default)
					actions="$default_actions"
					;;

				--fetch)
					actions="$actions fetch"
					;;

				--clean)
					actions="$actions clean"
					;;

				--compile)
					actions="$actions compile"
					;;

				--build)
					actions="$actions clean compile"
					;;

				--package)
					actions="$actions package"
					;;


				#
				# Toolchain controls
				#

				# TODO, requires configuration system

				#
				# Module type controls
				#

				--cores) modtypes="$modtypes cores" ;;
				--devkit) modtypes="$modtypes devkits" ;;
				--players) modtypes="$modtypes players" ;;

				#
				# Script plumbing
				#

				# In case there's ever a need for an option terminator
				--) opt_terminator=1 ;;

				# Something starting with - that we don't recognize
				*)
					echo "Unknown command \"$1\""
					exit 1
					;;
			esac
			shift
			continue
		fi

		# Non-commands are operating targets
		process="$process $1"
		shift
	done
fi

lsecho "libretro-super v$libretro_version
Script Copyright (C) 2015 by The Libretro Team"
if [ -n "$show_license" ]; then
	lsecho "
This script and its components are a work that is licensed under the
Creative Commons Attribution 4.0 International License. To view a copy of
this license, visit http://creativecommons.org/licenses/by/4.0/ or send a
letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA."
	exit 0
fi
lsecho "Licensed under CC-BY-4.0 (--license for details)"

if [ -n "$info_only" ]; then
	exit 0
fi

# Configure some defaults
[ -z "$actions" ] && actions="$default_actions"
[ -z "$modtypes" ] && modtypes="cores players ${LIBRETRO_DEVELOPER:+devkits}"
[ -n "$process" ] && force=1

# If user didn't ask for anything, they want "everything" (new, at least)
if [ -z "$process" ]; then
	[ -z "$skip_unchanged" ] && skip_unchanged=1
	if [[ "$modtypes" = *cores* ]]; then
		for target in $libretro_cores; do
			if [ -n "$LIBRETRO_DEVELOPER" ] || can_build_module $target; then
				process="$process $target"
			fi
		done
	fi

	# TODO: players and devkits
else
	# If user has asked for something specific, don't skip it
	[ -z "$skip_unchanged" ] && skip_unchanged=0
fi

###################################################################
#
# DO STUFF
# The bit of this script that actually does all the work is here
#
###################################################################

for target in $process; do
	module_process $target
done

summary
