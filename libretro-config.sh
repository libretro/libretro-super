# vim: set ts=3 sw=3 noet ft=sh : bash

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

		# Tell system clang to build for iOS
		CC="clang -arch armv7 -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX="clang++ -arch armv7 -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch armv7 -miphoneos-version-min=5.0 -isysroot $IOSSDK"

		;;

	theos_ios)
		DIST_DIR="theos_ios"
		BUILD_PRODUCT_PREFIX="objs/obj"
		FORMAT_EXT=dylib
		IOS=1
		ARCH=armv7
		FORMAT=_ios
		FORMAT_COMPILER_TARGET=theos_ios
		FORMAT_COMPILER_TARGET_ALT=theos_ios

		# Make sure that the cross bins you need are first in your path
		CXX11="clang++ -std=c++11 -stdlib=libc++ -miphoneos-version-min=5.0"

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
					case "${ARCH}" in
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
				osx|*Darwin*)
					platform=osx
					FORMAT_EXT="dylib"
					FORMAT_COMPILER_TARGET="osx"
					DIST_DIR="osx"
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
				*wii*)
					platform=wii
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="wii"
					DIST_DIR="wii"
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
				*android-armv7*)
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
			if command -v nproc >/dev/null; then
				JOBS="$(nproc)"
			else
				JOBS=1
			fi
		fi
		;;
esac


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

# Define this to skip the universal build
# export NOUNIVERSAL=1

# ARCHFLAGS is a very convenient way of doing this for simple/obvious cores
# that don't need anything defined on the command line for 32 vs 64 bit
# systems, however it won't work for anything that does.  For that, you need
# to do two separate builds, one for each arch, and then do something like:
#  lipo -create core_i386.dylib core_x86_64.dylib -output core_ub.dylib
#
# If building on 10.5/10.6, it's possible that you could actually build a UB
# for Intel/PowerPC, but please don't. ;) Consider this a proof of concept
# for now just to test a few cores.

if [[ "$FORMAT_COMPILER_TARGET" = "osx" && -z "$NOUNIVERSAL" ]]; then
	case "$ARCH" in
		i386|x86_64)
			export ARCHFLAGS="-arch i386 -arch x86_64"
			;;
		ppc|ppc64)
			export ARCHFLAGS="-arch ppc -arch ppc64"
			;;
		*)
			echo "Will not build universal binaries for unknown ARCH=\"$ARCH\""
			;;
	esac
fi

#CORE BUILD SUMMARY
#==================

# Uncomment this to disable the core build summary
# NOBUILD_SUMMARY=1

BUILD_SUMMARY="$WORKDIR/build-summary.log"


# BUILD_REVISIONS
# ===============
#
# libretro-super can save a revision string (e.g., the git sha hash) for any
# core it has compiled.  If this feature is enabled, it will check if the
# revison string has changed before it compiles the core.  This can speed up
# the build process for end-users and buildbots, and it also results in nightly
# build directories being smaller.  It is not enabled by default because it
# cannot know about uncommitted changes in a working directory.

# Set this to enable the feature
#SKIP_UNCHANGED=1

# Set this if you don't like the default
#BUILD_REVISIONS_DIR="$WORKDIR/build-revisions"


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
