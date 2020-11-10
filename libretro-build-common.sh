# vim: set ts=3 sw=3 noet ft=sh : bash

. "$BASE_DIR/script-modules/log.sh"
. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/cpu.sh"
. "$BASE_DIR/script-modules/module_base.sh"

. "$BASE_DIR/rules.d/core-rules.sh"

die() {
	echo $1
	#exit 1
}

#
# Regarding COMPILER...  It didn't used to be safe.  Now it is, provided that
# you are using it in a command line passed to echo_cmd without additional
# quoting, like so:
#
#  echo_cmd "$MAKE TARGET=\"libretro\" $COMPILER OTHERVAR=\"$SOMETHING\""
#
if [ "${CC}" ] && [ "${CXX}" ]; then
	COMPILER="CC=\"${CC}\" CXX=\"${CXX}\""
else
	COMPILER=""
fi

echo "Compiler: CC=\"$CC\" CXX=\"$CXX\""

[[ "${ARM_NEON}" ]] && echo '=== ARM NEON opts enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-neon"
[[ "${CORTEX_A8}" ]] && echo '=== Cortex A8 opts enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-cortexa8"
[[ "${CORTEX_A9}" ]] && echo '=== Cortex A9 opts enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo '=== ARM hardfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo '=== ARM softfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-softfloat"
[[ "$X86" ]] && echo '=== x86 CPU detected... ==='
[[ "$X86" ]] && [[ "$X86_64" ]] && echo '=== x86_64 CPU detected... ==='
[[ "${IOS}" ]] && echo '=== iOS =='

echo "$FORMAT_COMPILER_TARGET"
echo "$FORMAT_COMPILER_TARGET_ALT"
RESET_FORMAT_COMPILER_TARGET=$FORMAT_COMPILER_TARGET
RESET_FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET_ALT

# FIXME: We should use the theos toolchain without their make system which is
#        buggy on Linux and doesn't do what we want anyway.  It'd remove need
#        for this and other hacks.
CORE_PREFIX=""
CORE_SUFFIX="_libretro${FORMAT}.$FORMAT_EXT"
if [ "$platform" = "theos_ios" ]; then
	CORE_PREFIX="objs/obj/"
fi

post_error_log() {
	error=`cat $WORKDIR/log/$1.log | tail -n 100`
	haste=`curl -s -XPOST http://paste.libretro.com/ -d"$error"`
	haste=`echo $haste | cut -d"\"" -f4`
	echo "$1:	[status: fail ] (platform: $FORMAT_COMPILER_TARGET) LOG: http://paste.libretro.com/$haste"
}

build_summary_log() {
	# Trailing spaces are intentional here
	if [ "$1" -eq "0" ]; then
		export build_success="$build_success$2 "
	else
		export build_fail="$build_fail$2 "
		#post_error_log $2
	fi
}

copy_core_to_dist() {
	[ -z "$1" ] && return 1
	dest="${2:-$1}"
	if [ "$FORMAT_ABI_ANDROID" = "yes" ]; then
		echo_cmd "cp \"$CORE_PREFIX$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR/${dest}_libretro_android.so\""
	else
		echo_cmd "cp \"$CORE_PREFIX$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR/$dest$CORE_SUFFIX\""
	fi
	ret=$?
	build_summary_log $ret "$dest"
	return $ret
}

build_should_skip() {
	[ -z "$SKIP_UNCHANGED" ] && return 1

	[ -z "$BUILD_REVISIONS_DIR" ] && BUILD_REVISIONS_DIR="$WORKDIR/build-revisions"
	build_revision_file="$BUILD_REVISIONS_DIR/$1"

	[ ! -r "$build_revision_file" ] && return 1

	read previous_revision < "$build_revision_file"
	[ "$previous_revision" != "$(fetch_revision $2)" ] && return 1

	return 0
}

build_save_revision() {
	[ -z "$SKIP_UNCHANGED" ] && return
	[ "$1" != "0" ] && return
	echo $(fetch_revision) > "$BUILD_REVISIONS_DIR/$2"
}


check_opengl() {
	if [ "$BUILD_LIBRETRO_GL" ]; then
		if [ "$ENABLE_GLES" ]; then
			echo '=== OpenGL ES enabled ==='
			export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-gles"
			export FORMAT_COMPILER_TARGET_ALT="$FORMAT_COMPILER_TARGET"
		else
			echo '=== OpenGL enabled ==='
			export FORMAT_COMPILER_TARGET="$FORMAT_COMPILER_TARGET-opengl"
			export FORMAT_COMPILER_TARGET_ALT="$FORMAT_COMPILER_TARGET"
		fi
	else
		echo '=== OpenGL disabled in build ==='
		return 1
	fi

	return 0
}

reset_compiler_targets() {
	export FORMAT_COMPILER_TARGET=$RESET_FORMAT_COMPILER_TARGET
	export FORMAT_COMPILER_TARGET_ALT=$RESET_FORMAT_COMPILER_TARGET_ALT
}

# $1 is corename
# $2 is subcorename
# $3 is subdir. In case there is no subdir, enter "." here
# $4 is Makefile name
# $5 is preferred platform
build_libretro_generic_makefile_subcore() {
	build_dir="$WORKDIR/libretro-$1"
	if [ -d "$build_dir" ]; then
		echo "=== Building $2 ==="
		echo_cmd "cd \"$build_dir/$3\""

		if [ -z "$NOCLEAN" ]; then
			echo_cmd "$MAKE -f \"$4\" platform=$5 -j$JOBS clean" || die "Failed to clean $2"
		fi
		echo_cmd "$MAKE -f $4 platform=$5 -j$JOBS" || die "Failed to build $2"
		copy_core_to_dist "$2"
	fi
}

build_libretro_generic() {
	echo_cmd "cd \"$5/$2\""

	if [ -z "$NOCLEAN" ]; then
		echo_cmd "$MAKE -f \"$3\" platform=\"$4\" \"-j$JOBS\" clean" || die "Failed to clean $1"
	fi
	echo_cmd "$MAKE -f \"$3\" platform=\"$4\" $COMPILER \"-j$JOBS\"" || die "Failed to build $1"
}

# build_libretro_generic_makefile
#
# $1	Name of the core
# $2	Subdirectory of makefile (use "." for none)
# $3	Name of makefile
# $4	Either FORMAT_COMPILER_TARGET or an alternative
# $5	Skip copying (for cores that don't produce exactly one core)
build_libretro_generic_makefile() {
	build_dir="$WORKDIR/libretro-$1"

	if build_should_skip $1 "$build_dir"; then
		echo "Core $1 is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo "=== Building $1 ==="
		build_libretro_generic $1 "$2" "$3" $4 "$build_dir"
		if [ -z "$5" ]; then
			copy_core_to_dist $1
			build_save_revision $? $1
		fi
	else
		echo "$1 not fetched, skipping ..."
	fi
}

# build_makefile
#
# $core_build_subdir		Subdir of the makefile (if any)
# $core_build_makefile	Name of the makefile (if not {GNUm,m,M}akefile)
# $core_build_args		Extra arguments to make
# $core_build_platform	Usually some variant of $FORMAT_COMPILER_TARGET
# $core_build_cores		A list of cores produced by the builds
build_makefile() {
	[ -n "$core_build_subdir" ] && core_build_subdir="/$core_build_subdir"

	make_cmdline="$MAKE"
	if [ -n "$core_build_makefile" ]; then
		make_cmdline="$make_cmdline -f $core_build_makefile"
	fi

	# TODO: Do $platform type stuff better (requires modding each core)
	make_cmdline="$make_cmdline platform=\"$core_build_platform\""

	[ -n "$STATIC_LINKING" ] && make_cmdline="$make_cmdline STATIC_LINKING=1"

	[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"
	[ -n "$DEBUG" ] && make_cmdline="$make_cmdline DEBUG=$DEBUG"

	build_dir="$WORKDIR/$core_dir$core_build_subdir"

	if build_should_skip $1 "$build_dir"; then
		echo "Core $1 is already built, skipping..."
		return
	fi


	if [ -d "$build_dir" ]; then
		echo_cmd "cd \"$build_dir\""

		$core_build_configure

		if [ -z "$NOCLEAN" ]; then
			$core_build_preclean
			echo_cmd "$make_cmdline $core_build_args clean"
		fi
		make_cmdline="$make_cmdline $COMPILER"

		$core_build_prebuild
		echo_cmd "$make_cmdline $core_build_args"

		# TODO: Make this a separate stage/package rule
		$core_build_prepkg
		for a in $core_build_cores; do
			copy_core_to_dist ${core_build_products:+$core_build_products/}$a $a
		done
	else
		echo "$1 not fetched, skipping ..."
	fi
}


# libretro_build_core: Build the given core using its build rules
#
# $1	Name of the core to build
libretro_build_core() {
	local opengl_type

	if [ -n "${LIBRETRO_LOG_MODULE}" ]; then
		printf -v log_module "$LIBRETRO_LOG_DIR/$LIBRETRO_LOG_MODULE" "$1"
		[ -z "$LIBRETRO_LOG_APPEND" ] && : > $log_module
	fi

	eval "core_name=\${libretro_${1}_name:-$1}"
	echo "$(color 34)=== $(color 1)$core_name$(color)"
	lecho "=== $core_name"

	eval "core_build_rule=\${libretro_${1}_build_rule:-generic_makefile}"
	eval "core_dir=\${libretro_${1}_dir:-libretro-$1}"

	eval "core_build_opengl=\$libretro_${1}_build_opengl"
	if [ -n "$core_build_opengl" ]; then
		if [[ "$core_build_opengl" = "yes" || "$core_build_opengl" = "optional" ]]; then
			if [ -n "$BUILD_LIBRETRO_GL" ]; then
				if [ -n "$ENABLE_GLES" ]; then
					opengl_type="-gles"
				else
					opengl_type="-opengl"
				fi
			else
				if [ "$core_build_opengl" = "yes" ]; then
					echo "$1 requires OpenGL (which is disabled), skipping..."
					return 0
				fi
			fi
		else
			echo "libretro_build_core:Unknown OpenGL setting for $1: \"$core_build_opengl\"."
			return 1
		fi
	fi

	echo "Building ${1}..."
	lecho "Building ${1}..."
	if [ -n "$log_module" ]; then
		exec 6>&1
		echo "Building ${1}..." >> $log_module

		# TODO: Possibly a shell function for tee?
		if [[ -n "$LIBRETRO_DEVELOPER" && -n "${cmd_tee:=$(find_tool "tee")}" ]]; then
			exec > >($cmd_tee -a $log_module)
		else
			exec > $log_module
		fi
	fi

	case "$core_build_rule" in
		generic_makefile)
			# As of right now, only configure is used for now...
			if [ "$(type -t libretro_${1}_configure 2> /dev/null)" = "function" ]; then
				eval "core_configure=libretro_${1}_configure"
			else
				eval "core_configure=do_nothing"
			fi
			eval "core_build_makefile=\$libretro_${1}_build_makefile"
			eval "core_build_subdir=\$libretro_${1}_build_subdir"
			eval "core_build_args=\$libretro_${1}_build_args"

			# TODO: Really, change how all of this is done...
			eval "core_build_platform=\${libretro_${1}_build_platform:-$FORMAT_COMPILER_TARGET}$opengl_type"

			eval "core_build_cores=\${libretro_${1}_build_cores:-$1}"
			eval "core_build_products=\$libretro_${1}_build_products"
			build_makefile $1 2>&1
			;;

		legacy)
			eval "core_build_legacy=\$libretro_${1}_build_legacy"
			if [ -n "$core_build_legacy" ]; then
				echo "Warning: $1 hasn't been ported to a modern build rule yet."
				echo "         Will build it using legacy \"$core_build_legacy\"..."
				$core_build_legacy 2>&1
			fi
			;;
		none)
			echo "Don't have a build rule for $1, skipping..."
			;;
		*)
			echo "libretro_build_core:Unknown build rule for $1: \"$core_build_rule\"." >&2
			exit 1
			;;
	esac
	if [ -n "$log_module" ]; then
		exec 1>&6 6>&-
	fi
}


build_libretro_test() {
	build_dir="$WORKDIR/retroarch"

	if build_should_skip "test" "$build_dir"; then
		echo 'Core test is already built, skipping...'
		return
	fi

	if [ -d "$build_dir" ]; then
		echo '=== Building RetroArch test cores ==='
		if check_opengl; then
			build_libretro_generic "retroarch" "cores/libretro-test-gl" "Makefile" $FORMAT_COMPILER_TARGET "$build_dir"
			copy_core_to_dist "testgl"
		fi
		build_libretro_generic "retroarch" "cores/libretro-test" "Makefile" $FORMAT_COMPILER_TARGET "$build_dir"
		copy_core_to_dist "test"

		# TODO: Check for more than test here...
		build_save_revision $? "test"
	else
		echo "$1 not fetched, skipping ..."
	fi
}

summary() {
	# fmt is external and may not be available
	fmt_output="$(find_tool "fmt")"
	local num_success="$(numwords $build_success)"
	local fmt_success="${fmt_output:+$(echo "	$build_success" | $fmt_output)}"
	local num_fail="$(numwords $build_fail)"
	local fmt_fail="${fmt_output:+$(echo "   $build_fail" | $fmt_output)}"

	if [[ -z "$build_success" && -z "$build_fail" ]]; then
		lsecho "No build actions performed."
		return
	fi

	if [ -n "$build_success" ]; then
		secho "$(color 32)$num_success core(s)$(color) successfully processed:"
		lecho "$num_success core(s) successfully processed:"
		lsecho "$fmt_success"
	fi
	if [ -n "$build_fail" ]; then
		secho "$(color 31)$num_fail core(s)$(color) failed:"
		lecho "$num_fail core(s) failed:"
		lsecho "$fmt_fail"
	fi
}

create_dist_dir() {
	mkdir -p "$RARCH_DIST_DIR"
}

create_dist_dir
