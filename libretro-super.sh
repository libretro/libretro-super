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

shopt -q nullglob || reset_nullglob=1

. "$BASE_DIR/libretro-config.sh"

. "$BASE_DIR/script-modules/log.sh"
. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/modules.sh"

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
				--help) ;;

				--license|--licence)
					show_license=1
					LIBRETRO_LOG_SUPER=""
					LIBRETRO_LOG_MODULE=""
					;;

				--nologs)
					LIBRETRO_LOG_SUPER=""
					LIBRETRO_LOG_MODULE=""
					;;

				#
				# Scope controls
				#

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
This script ant its components are a work that is licensed under the
Creative Commons Attribution 4.0 International License. To view a copy of
this license, visit http://creativecommons.org/licenses/by/4.0/ or send a
letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA."
	exit 0
fi
lsecho "Licensed under CC-BY-4.0 (--license for details)"


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
# MODULE PROCESSING
#
###################################################################

module_set_vars() {
	module_varname="$1"
	eval "module_name=\${libretro_${1}_name:-$1}"
	eval "module_dir=\${libretro_${1}_dir:-libretro-$1}"

	for func in configure preclean prepackage; do
		if [ "$(type -t libretro_${1}_$func 2> /dev/null)" = "function" ]; then
			eval "module_$func=libretro_${1}_$func"
		else
			eval "module_$func=do_nothing"
		fi
	done

	eval "module_fetch_rule=\${libretro_${1}_fetch_rule:-git}"
	case "$module_fetch_rule" in
		git)
			eval "git_url=\$libretro_${1}_git_url"
			eval "git_submodules=\$libretro_${1}_git_submodules"
			;;

		none) ;;

		*)
			echo "Unknown fetch rule for $1: \"$module_fetch_rule\"."
			;;
	esac

	eval "module_build_rule=\${libretro_${1}_build_rule:-generic_makefile}"

	# TODO: Do OpenGL better
	eval "module_build_opengl=\$libretro_${1}_build_opengl"
	module_opengl_type=""
	if [ -n "$module_build_opengl" ]; then
		if [ -n "$ENABLE_GLES" ]; then
			module_opengl_type="-gles"
		else
			module_opengl_type="-opengl"
		fi
	fi

	module_build_subdir=""
	case "$module_build_rule" in
		generic_makefile)
			eval "module_build_makefile=\$libretro_${1}_build_makefile"
			eval "module_build_subdir=\$libretro_${1}_build_subdir"
			eval "module_build_makefile_targets=\"\$libretro_${1}_build_makefile_targets\""
			eval "module_build_args=\$libretro_${1}_build_args"

			# TODO: change how $platform is done
			eval "module_build_platform=\${libretro_${1}_build_platform:-$FORMAT_COMPILER_TARGET}$opengl_type"

			eval "module_build_cores=\${libretro_${1}_build_cores:-$1}"
			eval "module_build_products=\$libretro_${1}_build_products"
			;;

		legacy)
			eval "module_build_legacy=\$libretro_${1}_build_legacy"
			;;

		none) ;;

		*)
			echo "Unknown build rule for $1: \"$module_build_rule\"."
			;;
	esac

	module_build_dir="$WORKDIR/$module_dir${module_build_subdir:+/$module_build_subdir}"
}

module_fetch() {
	lsecho "Fetching ${module_varname}..."

	case "$module_fetch_rule" in
		git)
			if [ -z "$git_url" ]; then
				echo "module_fetch: No URL set to fetch $1 via git."
				exit 1
			fi
			fetch_git "$git_url" "$module_dir" "$git_submodules"
			;;

		none)
			# This module doesn't get fetched
			;;

		*)
			secho "module_fetch: Unknown fetch rule for $module_varname: \"$module_fetch_rule\"."
			return 1
			;;
	esac
}

module_clean() {
	if [ -z "$force" ] && ! can_build_module $1; then
		lsecho "Skipping clean, $module_varname is disabled on ${platform}..."
		return 0
	fi

	case "$module_build_rule" in
		generic_makefile)
			lsecho "Cleaning ${module_varname}..."
			echo_cmd "cd \"$module_build_dir\""

			make_cmdline="$MAKE"
			if [ -n "$module_build_makefile" ]; then
				make_cmdline="$make_cmdline -f $module_build_makefile"
			fi

			# TODO: Do $platform type stuff better (requires modding each core)
			make_cmdline="$make_cmdline platform=\"$module_build_platform\""

			[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"
			echo_cmd "$make_cmdline $module_build_args clean"
			return $?
			;;

		legacy)
			lsecho "Legacy rules cannot be cleaned separately, skipping..."
			;;

		none) 
			lsecho "No rule to clean ${module_varname}."
			;;

		*) ;;
	esac
}

module_compile() {
	if [ -z "$force" ] && ! can_build_module $1; then
		lsecho "Skipping compile, $module_varname is disabled on ${platform}..."
		return 0
	fi

	case "$module_build_rule" in
		generic_makefile)
			lsecho "Compiling ${module_varname}..."
			echo_cmd "cd \"$module_build_dir\""

			make_cmdline="$MAKE"
			if [ -n "$module_build_makefile" ]; then
				make_cmdline="$make_cmdline -f $module_build_makefile"
			fi

			# TODO: Do $platform type stuff better (requires modding each core)
			make_cmdline="$make_cmdline platform=\"$module_build_platform\""

			[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"

			make_cmdline="$make_cmdline $COMPILER"
			if [ -n "$module_build_makefile_targets" ]; then
				for target in $module_build_makefile_targets; do
					echo_cmd "$make_cmdline $module_build_args $target"
				done
			else
				echo_cmd "$make_cmdline $module_build_args"
			fi
			if [ $? -gt 0 ]; then
				for core in $module_build_cores; do
					build_summary_log 1 $core
				done
				return 1
			fi

			modules_copied=""
			for module in $module_build_cores; do
				module_src="${module_build_products:+$module_build_products/}$module$CORE_SUFFIX"
				module_dest="$module$CORE_SUFFIX"
				if [ -f "$module_src" ]; then
					build_summary_log 0 $module
					echo_cmd "cp \"$module_src\" \"$RARCH_DIST_DIR/$module_dest\""
					modules_copied="$modules_copied $module_dest"
				else
					build_summary_log 1 $module
				fi
			done
			return 0
			;;

		legacy)
			if [ -n "$module_build_legacy" ]; then
				lsecho "Warning: $module_varname hasn't been ported to a modern build rule yet."
				lsecho "Compiling $module_varname using legacy \"$module_build_legacy\"..."
				$module_build_legacy
				return $?
			else
				lsecho "module_compile: No legacy build rule for ${module_varname}."
				return 1
			fi
			;;

		none)
			lsecho "No rule to compile ${module_varname}."
			;;

		*) ;;
	esac
}

module_package() {
	if [ -n "$modules_copied" ]; then
		lsecho "Packaging ${module_varname}..."
		cd "$RARCH_DIST_DIR"
		for module in $modules_copied; do
			# TODO: Support more than zip here
			zip -m9 "${module}.zip" $module
		done
	fi
}

module_process() {
	local module_changed

	if [[ "$libretro_modules" != *$1* ]]; then
		secho "$(color 34)=== $(color 1)$1 $(color 31)not found$(color)"
		lecho "=== $1 not found"
		lsecho ""
		return 1
	fi
	if module_set_vars ${1%%:*}; then
		secho "$(color 34)=== $(color 1)$module_name$(color)"
		lecho "=== $module_name"
	else
		secho "$(color 34)=== $color 1)$1 $(color 31)rule error$(color)"
		lecho "=== $1 rule error"
		return 1
	fi

	log_module_start $module_varname

	module_revision_old="$(module_get_revision)"
	if [[ "$actions" = *fetch* ]]; then
		if ! module_fetch $1; then
			log_module_stop "module_process: Unable to fetch ${module_varname}."
			return 1
		fi
	fi
	module_revision="$(module_get_revision 1)"
	if [ "0$skip_unchanged" -eq 1 ]; then
		if [ "$module_revision_old" != "$module_revision" ]; then
			module_changed=1
		else
			module_changed=""
		fi
	else
		module_changed=1
	fi

	if [[ -n "$module_changed" && "$actions" = *clean* ]]; then
		if ! $module_preclean; then
			log_module_stop "module_process: module_preclean for $module_varname failed."
			return 1
		fi
		if ! module_clean $1; then
			log_module_stop "module_process: Unable to clean ${module_varname}."
			return 1
		fi
	fi

	if [[ -n "$module_changed" && "$actions" = *compile* ]]; then
		if ! $module_configure; then
			log_module_stop "module_process: module_configure for $module_varname failed."
			return 1
		fi
		if ! module_compile $1; then
			log_module_stop "module_process: Unable to compile ${module_varname}."
			return 1
		fi
	fi

	if [[ -n "$module_changed" && "$actions" = *package* ]]; then
		if ! $module_prepackage; then
			log_module_stop "module_process: module_prepackage for $module_varname failed."
			return 1
		fi
		if ! module_package $1; then
			log_module_stop "module_process: Unable to package ${module_varname}."
			return 1
		fi
	fi

	log_module_stop
}

#################################
# Borrowed from original libretro-build
# TODO: Replace this code using find_tool

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

. "$BASE_DIR/libretro-build-common.sh"

# End of borrowed code
#################################

for target in $process; do
	module_process $target
done

summary
