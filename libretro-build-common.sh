# vim: set ts=3 sw=3 noet ft=sh : bash

. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/cpu.sh"
. "$BASE_DIR/script-modules/modules.sh"
. "$BASE_DIR/script-modules/build-tools.sh"

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

CORE_PREFIX=""
CORE_SUFFIX="_libretro${FORMAT}.$FORMAT_EXT"
if [ "$platform" = "theos_ios" ]; then
	CORE_PREFIX="objs/obj/"
fi


build_summary_log() {
	# Trailing spaces are intentional here
	if [ "$1" -eq "0" ]; then
		build_success="$build_success$2 "
	else
		build_fail="$build_fail$2 "
	fi
}

copy_core_to_dist() {
	[ -z "$1" ] && return 1
	dest="${2:-$1}"
	echo_cmd "cp \"$CORE_PREFIX$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR/$dest$CORE_SUFFIX\""

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

build_libretro_fba_cps2() {
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps2" "svn-current/trunk/fbacores/cps2" "makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_fba_neogeo() {
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_neo" "svn-current/trunk/fbacores/neogeo" "makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_fba_cps1() {
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps1" "svn-current/trunk/fbacores/cps1" "makefile.libretro" $FORMAT_COMPILER_TARGET
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

	# TODO: Do this better
	make_cmdline="$make_cmdline platform=\"$core_build_platform\""

	[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"

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

	eval "core_name=\$libretro_${1}_name"
	[ -z "$core_name" ] && core_name="$1"
	echo "$(color 34)=== $(color 1)$core_name$(color)"

	eval "core_build_rule=\$libretro_${1}_build_rule"
	[ -z "$core_build_rule" ] && core_build_rule=generic_makefile

	eval "core_dir=\$libretro_${1}_dir"
	[ -z "$core_dir" ] && core_dir="libretro-$1"

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

	case "$core_build_rule" in
		generic_makefile)
			for a in configure preclean prebuild prepkg; do
				if [ "$(type -t libretro_${1}_build_$a 2> /dev/null)" = "function" ]; then
					eval "core_build_$a=libretro_${1}_build_$a"
				else
					eval "core_build_$a="
				fi
			done
			eval "core_build_makefile=\$libretro_${1}_build_makefile"
			eval "core_build_subdir=\$libretro_${1}_build_subdir"
			eval "core_build_args=\$libretro_${1}_build_args"

			# TODO: Really, clean this up...
			eval "core_build_platform=\$libretro_${1}_build_platform"
			core_build_platform="${core_build_platform:-$FORMAT_COMPILER_TARGET}$opengl_type"

			eval "core_build_cores=\${libretro_${1}_build_cores:-$1}"
			eval "core_build_products=\$libretro_${1}_build_products"
			echo "Building ${1}..."
			build_makefile $1
			;;

		legacy)
			eval "core_build_legacy=\$libretro_${1}_build_legacy"
			if [ -n "$core_build_legacy" ]; then
				echo "Warning: $1 hasn't been ported to a modern build rule yet."
				echo "         Will build it using legacy \"$core_build_legacy\"..."
				$core_build_legacy
			fi
			;;
		none)
			echo "Don't have a build rule for $1, skipping..."
			;;
		*)
			echo "libretro_build_core:Unknown build rule for $1: \"$core_build_rule\"."
			exit 1
			;;
	esac
}


build_libretro_test() {
	build_dir="$WORKDIR/retroarch"

	if build_should_skip "test" "$build_dir"; then
		echo "Core test is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo "=== Building RetroArch test cores ==="
		if check_opengl; then
			build_libretro_generic "retroarch" "libretro-test-gl" "Makefile" $FORMAT_COMPILER_TARGET "$build_dir"
			copy_core_to_dist "testgl"
		fi
		build_libretro_generic "retroarch" "libretro-test" "Makefile" $FORMAT_COMPILER_TARGET "$build_dir"
		copy_core_to_dist "test"

		# TODO: Check for more than test here...
		build_save_revision $? "test"
	else
		echo "$1 not fetched, skipping ..."
	fi
}


build_summary() {
	if [ -z "$NOBUILD_SUMMARY" ]; then
		if command -v fmt > /dev/null; then
			use_fmt=1
		fi
		printf -v summary "=== Core Build Summary ===\n\n"
		if [ -n "$build_success" ]; then
			printf -v summary "%s%s%d%s\n" "$summary" "$(color 32)" "$(echo $build_success | wc -w)" " core(s)$(color) successfully built:"
			if [ -n "$use_fmt" ]; then
				printf -v summary "%s%s\n\n" "$summary" "$(echo "	$build_success" | fmt)"
			else
				printf -v summary "%s%s\n\n" "$summary" "$(echo $build_success)"
			fi
		fi
		if [ -n "$build_fail" ]; then
			printf -v summary "%s%s%d%s\n" "$summary" "$(color 31)" "$(echo $build_fail | wc -w)" " core(s)$(color) failed to build:"
			if [ -n "$use_fmt" ]; then
				printf -v summary "%s%s\n\n" "$summary" "$(echo "	$build_fail" | fmt)"
			else
				printf -v summary "%s%s\n\n" "$summary" "$(echo $build_fail)"
			fi
		fi
		if [[ -z "$build_success" && -z "$build_fail" ]]; then
			printf -v summary "%s%s\n\n" "$summary" "No build actions performed."
		fi
		if [ -n "$BUILD_SUMMARY" ]; then
			echo "$summary" > "$BUILD_SUMMARY"
		fi
		echo "$summary"
	fi
}

create_dist_dir() {
	mkdir -p "$RARCH_DIST_DIR"
}

create_dist_dir


########## LEGACY RULES
# TODO: Port these to modern rules

build_libretro_mame_prerule() {
	build_dir="$WORKDIR/libretro-mame"

	if build_should_skip mame "$build_dir"; then
		echo "Core mame is already built, skipping..."
		return
	fi

	ret=0
	if [ -d "$build_dir" ]; then
		echo ''
		echo "=== Building MAME ==="
		echo_cmd "cd \"$build_dir\""

		local extra_args
		[ "${MAME_GIT_TINY:=0}" -eq 1 ] && extra_args="$extra_args SUBTARGET=tiny"

		if [ -z "$NOCLEAN" ]; then
			echo_cmd "$MAKE -f Makefile.libretro $extra_args platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" clean"
			ret=$?

			if [ "$ret" != 0 ]; then
				die 'Failed to clean MAME'
				return $ret
			fi
		fi

		# For mame platforms that are CROSS_BUILD's (iOS/Android), we must make buildtools natively
		if [ "$platform" = "ios" ]; then
			echo_cmd "$MAKE -f Makefile.libretro platform=\"\" buildtools" || die 'Failed to build MAME buildtools'
		fi

		# This hack is because mame uses $(CC) to comiple C++ code because "historical reasons"
		# It can/should be removed when upstream MAME fixes it on their end.
		MAME_COMPILER="REALCC=\"${CC:-cc}\" CC=\"${CXX:-c++}\""

		# mame's tiny subtarget doesn't support UME
		mame_targets="mame mess ume"
		[ "$MAME_GIT_TINY" -eq 1 ] && mame_targets="mame mess"

		for target in $mame_targets; do
			echo_cmd "$MAKE -f Makefile.libretro $extra_args platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" osd-clean" || die 'Failed to clean MAME OSD'
			echo_cmd "$MAKE -f Makefile.libretro $extra_args \"TARGET=$target\" platform=\"$FORMAT_COMPILER_TARGET\" $MAME_COMPILER \"-j$JOBS\"" || die "Failed to build $target"
			copy_core_to_dist "$target"
			ret=$?

			# If a target fails, stop here...
			[ $ret -eq 0 ] || break
		done

	else
		echo 'MAME not fetched, skipping ...'
	fi

	build_save_revision $ret mame
}
