# vim: set ts=3 sw=3 noet ft=sh : bash

# The platform variable is normally not set at the time libretro-config is
# included by libretro-build.sh.  Other platform scripts may begin to include
# libretro-config as well if they define their platform-specific code in the
# case block below.  This is a band-aid fix that we will address after 1.1 is
# released.

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

#Statically link cores
#export STATIC_LINKING=1

#ANDROID DEFINES
#================

export TARGET_ABIS="armeabi-v7a arm64-v8a x86 x86_64"

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
		Power*|ppc|ppc64)
			export ARCHFLAGS="-arch ppc -arch ppc64"
			;;
		*)
			echo "Will not build universal binaries for unknown ARCH=\"$ARCH\""
			;;
	esac
fi

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

case "$platform" in
	##
	## Configs that did not use libretro-config originally
	## TODO: Integrate this with everything else (post-1.1)
	##

   emscripten)
		DIST_DIR="emscripten"
		FORMAT_EXT=bc
		FORMAT=_emscripten
      FORMAT_COMPILER_TARGET=emscripten
		FORMAT_COMPILER_TARGET_ALT=emscripten
		;;
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
		MIN_IOS5="-miphoneos-version-min=5.0"
		MIN_IOS7="-miphoneos-version-min=7.0"

		# Use generic names rather than gcc/clang to better support both
		CC="cc -arch armv7 -marm -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX="c++ -arch armv7 -marm -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch armv7 -marm -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		;;

	ios9)
		# NOTE: This config requires a Mac with an Xcode installation.  These
		#       scripts will work at least as far as 10.5 that we're sure of, but
		#       we build with clang targeting iOS >= 5.  We'll accept patches for
		#       older versions of iOS.

		DIST_DIR="ios9"
		FORMAT_EXT=dylib
		IOS=1
		ARCH=armv7
		FORMAT=_ios
		FORMAT_COMPILER_TARGET=ios9
		FORMAT_COMPILER_TARGET_ALT=ios9
		export IOSSDK=$(xcodebuild -version -sdk iphoneos Path)
		MIN_IOS5="-miphoneos-version-min=5.0"
		MIN_IOS7="-miphoneos-version-min=7.0"

		# Use generic names rather than gcc/clang to better support both
		CC="cc -arch armv7 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX="c++ -arch armv7 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch armv7 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		;;

	ios10)
		DIST_DIR="ios10"
		FORMAT_EXT=dylib
		IOS=1
		ARCH=armv7 arm64
		FORMAT=_ios
		FORMAT_COMPILER_TARGET=ios10
		FORMAT_COMPILER_TARGET_ALT=ios10
		export IOSSDK=$(xcodebuild -version -sdk iphoneos Path)

		# Use generic names rather than gcc/clang to better support both
		CC="cc -arch armv7 -arch arm64 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX="c++ -arch armv7 -arch arm64 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch armv7 -arch arm64 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		;;

	ios-arm64)
		DIST_DIR="ios-arm64"
		FORMAT_EXT=dylib
		IOS=1
		ARCH=arm64
		FORMAT=_ios
		FORMAT_COMPILER_TARGET=ios-arm64
		FORMAT_COMPILER_TARGET_ALT=ios-arm64
		export IOSSDK=$(xcodebuild -version -sdk iphoneos Path)

		# Use generic names rather than gcc/clang to better support both
		CC="cc -arch arm64 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX="c++ -arch arm64 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch arm64 -marm -miphoneos-version-min=8.0 -isysroot $IOSSDK"
		CXX17="clang++ -std=c++17 -stdlib=libc++ -arch arm64 -isysroot $IOSSDK"
		;;

        tvos-arm64)
		DIST_DIR="tvos-arm64"
		FORMAT_EXT=dylib
		IOS=1
		ARCH=arm64
		FORMAT=_tvos
		FORMAT_COMPILER_TARGET=tvos-arm64
		FORMAT_COMPILER_TARGET_ALT=tvos-arm64
		export IOSSDK=$(xcodebuild -version -sdk appletvos Path)

		# Use generic names rather than gcc/clang to better support both
		CC="cc -arch arm64 -marm -mtvos-version-min=9.0 -isysroot $IOSSDK"
		CXX="c++ -arch arm64 -marm -mtvos-version-min=9.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch arm64 -marm -mtvos-version-min=9.0 -isysroot $IOSSDK"
		CXX17="clang++ -std=c++17 -stdlib=libc++ -arch arm64 -isysroot $IOSSDK"
		;;


   android-x86_64)
		FORMAT_ABI="x86_64"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_${FORMAT_ABI}
		FORMAT_COMPILER_TARGET_ALT=android_${FORMAT_ABI}
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/x86_64-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/x86_64-linux-android-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/x86_64-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/x86_64-linux-android-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/x86_64-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/x86_64-linux-android-g++"
		;;

   android-x86)
		FORMAT_ABI="x86"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_${FORMAT_ABI}
		FORMAT_COMPILER_TARGET_ALT=android_${FORMAT_ABI}
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/x86-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/i686-linux-android-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/x86-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/i686-linux-android-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/x86-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/i686-linux-android-g++"
		;;

   android-armeabi)
		FORMAT_ABI="armeabi"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_${FORMAT_ABI}
		FORMAT_COMPILER_TARGET_ALT=android_${FORMAT_ABI}
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/arm-linux-androideabi-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/arm-linux-androideabi-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/arm-linux-androideabi-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/arm-linux-androideabi-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/arm-linux-androideabi-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/arm-linux-androideabi-g++"
		;;

   android-armeabi_v7a)
		FORMAT_ABI="armeabi-v7a"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_armeabi-v7a
		FORMAT_COMPILER_TARGET_ALT=android_armeabi-v7a
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/arm-linux-androideabi-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/arm-linux-androideabi-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/arm-linux-androideabi-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/arm-linux-androideabi-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/arm-linux-androideabi-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/arm-linux-androideabi-g++"
		;;

   android-arm64_v8a)
		FORMAT_ABI="arm64-v8a"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_arm64-v8a
		FORMAT_COMPILER_TARGET_ALT=android_arm64-v8a
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/aarch64-linux-android-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/aarch64-linux-android-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/aarch64-linux-android-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/aarch64-linux-android-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/aarch64-linux-android-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/aarch64-linux-android-g++"
		;;

   android-mips)
		FORMAT_ABI="mips"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_${FORMAT_ABI}
		FORMAT_COMPILER_TARGET_ALT=android_${FORMAT_ABI}
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/mipsel-linux-android-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/mipsel-linux-android-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/mipsel-linux-android-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/mipsel-linux-android-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/mipsel-linux-android-4.8/prebuilt/${HOST_PLATFORM}-x86_64/bin/mipsel-linux-android-g++"
		;;

   android-mips64)
		FORMAT_ABI="mips64"
		DIST_DIR="android/${FORMAT_ABI}"
		FORMAT_EXT=so
		FORMAT=".android_${FORMAT_ABI}"
		FORMAT_COMPILER_TARGET=android_${FORMAT_ABI}
		FORMAT_COMPILER_TARGET_ALT=android_${FORMAT_ABI}
		FORMAT_ABI_ANDROID=yes
		UNAME_PLATFORM="$(uname)"
		HOST_PLATFORM="linux"

		case "$UNAME_PLATFORM" in
			osx|*Darwin*)
				HOST_PLATFORM="darwin"
				;;
			win|*mingw32*|*MINGW32*|*MSYS_NT*)
				HOST_PLATFORM="windows"
				;;
			win64|*mingw64*|*MINGW64*)
				HOST_PLATFORM="windows"
				;;
		esac
		export NDK_ROOT_DIR
		CC="$NDK_ROOT_DIR/toolchains/mips64el-linux-android-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/mips64el-linux-android-gcc"
		CXX="$NDK_ROOT_DIR/toolchains/mips64el-linux-android-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/mips64el-linux-android-g++"
		CXX11="$NDK_ROOT_DIR/toolchains/mips64el-linux-android-4.9/prebuilt/${HOST_PLATFORM}-x86_64/bin/mips64el-linux-android-g++"
		;;

	qnx)
		DIST_DIR="qnx"
		FORMAT_EXT=so
		FORMAT=_qnx
		FORMAT_COMPILER_TARGET=qnx
		FORMAT_COMPILER_TARGET_ALT=qnx

		CC="qcc -Vgcc_ntoarmv7le"
		CXX="QCC -Vgcc_ntoarmv7le_cpp"
		CXX11="QCC -Vgcc_ntoarmv7le_cpp"
		;;

	psp1)
		DIST_DIR="psp1"
		FORMAT_EXT=a
		FORMAT=_psp1
		FORMAT_COMPILER_TARGET=psp1
		FORMAT_COMPILER_TARGET_ALT=psp1

		CC="psp-gcc${BINARY_EXT}"
		CXX="psp-g++${BINARY_EXT}"
		;;

        psl1ght)
		DIST_DIR="psl1ght"
		FORMAT_EXT=a
		FORMAT=_psl1ght
		FORMAT_COMPILER_TARGET=psl1ght
		FORMAT_COMPILER_TARGET_ALT=psl1ght

		CC="powerpc64-ps3-elf-gcc${BINARY_EXT}"
		CXX="powerpc64-ps3-elf-g++${BINARY_EXT}"
		;;

	ps2)
		DIST_DIR="ps2"
		FORMAT_EXT=a
		FORMAT=_ps2
		FORMAT_COMPILER_TARGET=ps2
		FORMAT_COMPILER_TARGET_ALT=ps2

		CC="ee-gcc${BINARY_EXT}"
		CXX="ee-g++${BINARY_EXT}"
		;;

	ctr)
		DIST_DIR="ctr"
		FORMAT_EXT=a
		FORMAT=_ctr
		FORMAT_COMPILER_TARGET=ctr
		FORMAT_COMPILER_TARGET_ALT=ctr

		CC="$DEVKITARM/bin/arm-none-eabi-gcc$BINARY_EXT"
		CXX="$DEVKITARM/bin/arm-none-eabi-g++$BINARY_EXT"
		AR="$DEVKITARM/bin/arm-none-eabi-ar$BINARY_EXT"
		;;

	vita)
		DIST_DIR="vita"
		FORMAT_EXT=a
		FORMAT=_vita
		FORMAT_COMPILER_TARGET=vita
		FORMAT_COMPILER_TARGET_ALT=vita

		CC="arm-vita-eabi-gcc${BINARY_EXT}"
		CXX="arm-vita-eabi-g++${BINARY_EXT}"
		;;

	ps3)
		DIST_DIR="ps3"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=ps3
		FORMAT_COMPILER_TARGET_ALT=sncps3
		FORMAT=_ps3

		CC="ppu-lv2-gcc.exe"
		CXX="ppu-lv2-g++.exe"
		;;

	ngc)
		DIST_DIR="ngc"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=ngc
		FORMAT_COMPILER_TARGET_ALT=ngc
		FORMAT=_ngc

		CC="$DEVKITPPC/bin/powerpc-eabi-gcc$BINARY_EXT"
		CXX="$DEVKITPPC/bin/powerpc-eabi-g++$BINARY_EXT"
		AR="$DEVKITPPC/bin/powerpc-eabi-ar$BINARY_EXT"
		;;
	
	wii)
		DIST_DIR="wii"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=wii
		FORMAT_COMPILER_TARGET_ALT=wii
		FORMAT=_wii

		CC="$DEVKITPPC/bin/powerpc-eabi-gcc$BINARY_EXT"
		CXX="$DEVKITPPC/bin/powerpc-eabi-g++$BINARY_EXT"
		AR="$DEVKITPPC/bin/powerpc-eabi-ar$BINARY_EXT"
		;;

	xbox1)
		DIST_DIR="xbox1"
		FORMAT_EXT=lib
		FORMAT_COMPILER_TARGET=xbox1_msvc2003
		FORMAT_COMPILER_TARGET_ALT=xbox1_msvc2003
		FORMAT=_xdk1
		BINARY_EXT=.exe

		CC="cl.exe"
		CXX="cl.exe"

		;;

	xbox360)
		DIST_DIR="xbox360"
		FORMAT_EXT=lib
		FORMAT_COMPILER_TARGET=xbox360_msvc2010
		FORMAT_COMPILER_TARGET_ALT=xbox360_msvc2010
		FORMAT=_xdk360
		BINARY_EXT=.exe

		CC="cl.exe"
		CXX="cl.exe"

		;;

	wiiu)
		DIST_DIR="wiiu"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=wiiu
		FORMAT_COMPILER_TARGET_ALT=wiiu
		FORMAT=_wiiu

		CC="$DEVKITPPC/bin/powerpc-eabi-gcc$BINARY_EXT"
		CXX="$DEVKITPPC/bin/powerpc-eabi-g++$BINARY_EXT"
		AR="$DEVKITPPC/bin/powerpc-eabi-ar$BINARY_EXT"
		;;

	switch)
		DIST_DIR="switch"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=switch
		FORMAT_COMPILER_TARGET_ALT=switch
		FORMAT=_switch

		CC="clang$BINARY_EXT" 
		CXX="clang++$BINARY_EXT"
		AR="llvm-ar$BINARY_EXT"

		;;

	libnx)
		DIST_DIR="libnx"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=libnx
		FORMAT_COMPILER_TARGET_ALT=libnx
		FORMAT=_libnx
		
		CC="$DEVKITPRO/devkitA64/bin/aarch64-none-elf-gcc$BINARY_EXT"
		CXX="$DEVKITPRO/devkitA64/bin/aarch64-none-elf-g++$BINARY_EXT"
		AR="$DEVKITPRO/devkitA64/bin/aarch64-none-elf-ar$BINARY_EXT"

		;;

	sncps3)
		DIST_DIR="ps3"
		FORMAT_EXT=a
		FORMAT_COMPILER_TARGET=sncps3
		FORMAT=_ps3

		CC="$CELL_SDK/host-win32/sn/bin/ps3ppusnc.exe"
		CXX="$CELL_SDK/host-win32/sn/bin/ps3ppusnc.exe"
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
					BINARY_EXT=""
					FORMAT_COMPILER_TARGET="unix"
					DIST_DIR="bsd"
					;;
				*Haiku*)
					platform=haiku
					FORMAT_EXT="so"
					BINARY_EXT=""
					FORMAT_COMPILER_TARGET="unix"
					DIST_DIR="haiku"
					;;
				osx|*Darwin*)
					platform=osx
					FORMAT_EXT="dylib"
					BINARY_EXT=""
					FORMAT_COMPILER_TARGET="osx"
					case "$ARCH" in
						x86_64|i386|Power*|ppc*)
							DIST_DIR="osx-$ARCH"
							;;
						*)
							DIST_DIR="osx-unknown"
							;;
					esac
					;;
				msvc2003_x86)
					platform=windows_msvc2003_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2003_x86"
					DIST_DIR="msvc2003_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2005_x86)
					platform=windows_msvc2005_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2005_x86"
					DIST_DIR="msvc2005_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2008_x86)
					platform=windows_msvc2008_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2008_x86"
					DIST_DIR="msvc2008_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2010_x86)
					platform=windows_msvc2010_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2010_x86"
					DIST_DIR="msvc2010_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2010_x64)
					platform=windows_msvc2010_x64
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2010_x64"
					DIST_DIR="msvc2010_x64"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2015_x86)
					platform=windows_msvc2015_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2015_x86"
					DIST_DIR="msvc2015_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2015_x64)
					platform=windows_msvc2015_x64
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2015_x64"
					DIST_DIR="msvc2015_x64"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2017_desktop_x86)
					platform=windows_msvc2017_desktop_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2017_desktop_x86"
					DIST_DIR="msvc2017_desktop_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2017_desktop_x64)
					platform=windows_msvc2017_desktop_x64
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2017_desktop_x64"
					DIST_DIR="msvc2017_desktop_x64"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2017_uwp_x86)
					platform=windows_msvc2017_uwp_x86
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2017_uwp_x86"
					DIST_DIR="msvc2017_uwp_x86"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2017_uwp_x64)
					platform=windows_msvc2017_uwp_x64
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2017_uwp_x64"
					DIST_DIR="msvc2017_uwp_x64"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				msvc2017_uwp_arm)
					platform=windows_msvc2017_uwp_arm
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="windows_msvc2017_uwp_arm"
					DIST_DIR="msvc2017_uwp_arm"
					CC="cl.exe"
					CXX="cl.exe"
					CXX11="cl.exe"
					;;
				win|*mingw32*|*MINGW32*|*MSYS_NT*)
					platform=win
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="win"
					DIST_DIR="win_x86"
					;;
				win64|*mingw64*|*MINGW64*)
					platform=win
					FORMAT_EXT="dll"
					BINARY_EXT=".exe"
					FORMAT_COMPILER_TARGET="win"
					DIST_DIR="win_x64"
					;;
				*psp1*)
					platform=psp1
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="psp1"
					DIST_DIR="psp1"
					;;
				*ctr*)
					platform=ctr
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="ctr"
					DIST_DIR="ctr"
					;;
				*emscripten*)
   				platform=emscripten
   				FORMAT_EXT="bc"
   				FORMAT_COMPILER_TARGET="emscripten"
   				DIST_DIR="emscripten"
   				;;
				*vita*)
					platform=vita
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="vita"
					DIST_DIR="vita"
					;;
				*ps3*)
					platform=ps3
					FORMAT_EXT="a"
					FORMAT_COMPILER_TARGET="ps3"
					FORMAT_COMPILER_TARGET_ALT="sncps3"
					DIST_DIR="ps3"
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
				android-x86_64)
					platform=android-x86_64
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/x86_64"
					;;
				android-x86)
					platform=android-x86
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/x86"
					;;
				android-armeabi)
					platform=android-armeabi
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/armeabi"
					;;
				android-armeabi_v7a)
					platform=android-armeabi_v7a
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/armeabi-v7a"
					;;
				android-arm64_v8a)
					platform=android-arm64_v8a
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/arm64-v8a"
					;;
				android-mips)
					platform=android-mips
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/mips"
					;;
				android-mips64)
					platform=android-mips64
					FORMAT_EXT="so"
					FORMAT_COMPILER_TARGET="${platform}"
					DIST_DIR="android/mips64"
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
                                linux-armv7-neon)
                                        FORMAT_EXT="so"
                                        FORMAT_COMPILER_TARGET="unix-armv7-hardfloat-neon"
                                        DIST_DIR="unix"
                                       ;;
				*)
					BINARY_EXT=""
					FORMAT_COMPILER_TARGET="unix"
					if [ -n "$STATIC_LINKING" ]; then
						FORMAT=_unix
						FORMAT_EXT="a"
						DIST_DIR="unix-static"
					else
						FORMAT_EXT="so"
						DIST_DIR="unix"
					fi
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
			elif [ "$platform" = "osx" ] && command -v sysctl >/dev/null; then
				JOBS="$(sysctl -n hw.physicalcpu)"
			else
				JOBS=1
			fi
		fi
		;;
esac
