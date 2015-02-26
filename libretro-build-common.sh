# vim: set ts=3 sw=3 noet ft=sh : bash

. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/cpu.sh"

. "$BASE_DIR/core-rules.sh"

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

CORE_SUFFIX="_libretro${FORMAT}.$FORMAT_EXT"


build_summary_log() {
	# Trailing spaces are intentional here
	if [ "$1" -eq "0" ]; then
		build_success="$build_success$2 "
	else
		build_fail="$build_fail$2 "
	fi
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

build_libretro_pcsx_rearmed_interpreter() {
	build_dir="$WORKDIR/libretro-pcsx_rearmed"

	if build_should_skip "pcsx_rearmed_interpreter" "$build_dir"; then
		echo "Core test is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo '=== Building PCSX ReARMed Interpreter ==='
		echo_cmd "cd \"$build_dir\""

		if [ -z "$NOCLEAN" ]; then
			echo_cmd "$MAKE -f Makefile.libretro platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" clean" || die 'Failed to clean PCSX ReARMed'
		fi
		echo_cmd "$MAKE -f Makefile.libretro USE_DYNAREC=0 platform=\"$FORMAT_COMPILER_TARGET\" $COMPILER \"-j$JOBS\"" || die 'Failed to build PCSX ReARMed'
		echo_cmd "cp \"pcsx_rearmed$CORE_SUFFIX\" \"$RARCH_DIST_DIR/pcsx_rearmed_interpreter${FORMAT}.$FORMAT_EXT\""
		build_summary_log $? "pcsx_rearmed_interpreter"
		build_save_revision $? "pcsx_rearmed_interpreter"
	else
		echo 'PCSX ReARMed not fetched, skipping ...'
	fi
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
		echo_cmd "cp $2$CORE_SUFFIX $RARCH_DIST_DIR/$2$CORE_SUFFIX"
		build_summary_log $? "$2"
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


copy_core_to_dist() {
	if [ "$FORMAT_COMPILER_TARGET" = "theos_ios" ]; then
		echo_cmd "cp \"objs/obj/$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
	else
		echo_cmd "cp \"$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
	fi

	ret=$?
	build_summary_log $ret "$1"
	return $ret
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
# $1	Name of the core
# $2	Subdirectory of makefile (use "." for none)
# $3	Name of makefile
# $4	Either FORMAT_COMPILER_TARGET or an alternative
# $5	Skip copying (for cores that don't produce exactly one core)
build_makefile() {
	[ -n "$core_build_subdir" ] && core_build_subdir="/$core_build_subdir"

	make_cmdline="$MAKE"
	if [ -n "$core_build_makefile" ]; then
		make_cmdline="$make_cmdline -f $core_build_makefile"
	fi

	# TODO: Do this better
	make_cmdline="$make_cmdline platform=\"${core_build_platform:-$FORMAT_COMPILER_TARGET}\""

	[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"

	build_dir="$WORKDIR/$core_dir$core_build_subdir"

	if build_should_skip $1 "$build_dir"; then
		echo "Core $1 is already built, skipping..."
		return
	fi


	if [ -d "$build_dir" ]; then
		echo_cmd "cd \"$build_dir\""

		if [ -z "$NOCLEAN" ]; then
			echo_cmd "$make_cmdline clean"
		fi
		make_cmdline="$make_cmdline $COMPILER"
		echo_cmd "$make_cmdline"

		# TODO: Make this a separate stage rule
		copy_core_to_dist $1
	else
		echo "$1 not fetched, skipping ..."
	fi
}


# libretro_build_core: Build the given core using its build rules
#
# $1	Name of the core to build
libretro_build_core() {
	eval "core_name=\$libretro_${1}_name"
	[ -z "$core_name" ] && core_name="$1"
	echo "=== $core_name"

	eval "core_build_rule=\$libretro_${1}_build_rule"
	[ -z "$core_build_rule" ] && core_build_rule=build_makefile

	eval "core_dir=\$libretro_${1}_dir"
	[ -z "$core_dir" ] && core_dir="libretro-$1"

	case "$core_build_rule" in
		build_makefile)
			eval "core_build_makefile=\$libretro_${1}_build_makefile"
			eval echo "core_build_makefile=\$libretro_${1}_build_makefile"

			eval "core_build_subdir=\$libretro_${1}_build_subdir"
			eval echo "core_build_subdir=\$libretro_${1}_build_subdir"

			eval "core_build_platform=\$libretro_${1}_build_platform"
			eval echo "core_build_platform=\$libretro_${1}_build_platform"

			echo "Building ${1}..."
			$core_build_rule $1

			;;
		*)
			echo "libretro_build_core:Unknown build rule for $1: \"$core_build_rule\"."
			exit 1
			;;
	esac
}


build_libretro_test() {
	build_dir="$WORKDIR/$1"

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


build_libretro_emux() {
	if build_should_skip emux "$WORKDIR/libretro-emux"; then
		echo "Cores for emux are already built, skipping..."
		return
	fi

	build_libretro_generic_makefile "emux" "libretro" "Makefile" $FORMAT_COMPILER_TARGET 1

	copy_core_to_dist "emux_chip8"
	copy_core_to_dist "emux_gb"
	copy_core_to_dist "emux_nes"
	copy_core_to_dist "emux_sms"

	# TODO: Check for more than emux_sms here...
	build_save_revision $? "emux"
}

build_libretro_ffmpeg() {
	if check_opengl; then
		build_libretro_generic_makefile "ffmpeg" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
		reset_compiler_targets
	fi
}

build_libretro_3dengine() {
	if check_opengl; then
		build_libretro_generic_makefile "3dengine" "." "Makefile" $FORMAT_COMPILER_TARGET
		reset_compiler_targets
	fi
}

build_libretro_ppsspp() {
	if check_opengl; then
		build_libretro_generic_makefile "ppsspp" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
		reset_compiler_targets
	fi
}

build_libretro_mame_modern() {
	build_dir="$WORKDIR/libretro-mame"
	if [ -d "$build_dir" ]; then
		echo ''
		echo "=== Building $1 ==="
		echo_cmd "cd \"$build_dir\""

		if [ -n "$IOS" ]; then
			if [ -z "$NOCLEAN" ]; then
				echo_cmd "$MAKE -f Makefile.libretro \"TARGET=$2\" \"PARTIAL=$3\" platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" clean" || die 'Failed to clean MAME'
			fi
			echo_cmd "$MAKE -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" $COMPILER \"NATIVE=1\" buildtools \"-j$JOBS\"" || die 'Failed to build MAME buildtools'
			echo_cmd "$MAKE -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" emulator \"-j$JOBS\"" || die 'Failed to build MAME (iOS)'
		else
			[ "$X86_64" = "true" ] && PTR64=1
			if [ -z "$NOCLEAN" ]; then
				echo_cmd "$MAKE PTR64=\"$PTR64\" -f Makefile.libretro \"TARGET=$2\" \"PARTIAL=$3\" platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" clean" || die 'Failed to clean MAME'
			fi

			echo_cmd "$MAKE PTR64=\"$PTR64\" -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" $COMPILER \"-j$JOBS\"" || die 'Failed to build MAME'
		fi

		echo_cmd "cp \"$2$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
		ret=$?
		build_summary_log $ret "$2"
		return $ret
	else
		echo 'MAME not fetched, skipping ...'
	fi
}


build_libretro_mame() {
	build_dir="$WORKDIR/libretro-mame"

	if build_should_skip mame "$build_dir"; then
		echo "Core mame is already built, skipping..."
		return
	fi

	build_libretro_mame_modern "MAME" "mame" ""
	build_libretro_mame_modern "MESS" "mess" "1"
	build_libretro_mame_modern "UME" "ume" "1"

	# TODO: Like others, this saves the revision if ume builds...
	build_save_revision $? mame
}

# radius uses these, let's not pull them out from under him just yet
build_libretro_mess() {
	build_libretro_mame_modern "MESS" "mess" ""
}
rebuild_libretro_mess() {
	build_libretro_mame_modern "MESS" "mess" "1"
}
build_libretro_ume() {
	build_libretro_mame_modern "UME" "ume" ""
}
rebuild_libretro_ume() {
	build_libretro_mame_modern "UME" "ume" "1"
}

# $1 is corename
# $2 is profile shortname.
# $3 is profile name
build_libretro_bsnes_modern() {
	build_dir="$WORKDIR/libretro-$1"
	if [ -d "$build_dir" ]; then
		echo "=== Building $1 $3 ==="
		echo_cmd "cd \"$build_dir\""
		
		if [ -z "$NOCLEAN" ]; then
			echo_cmd "rm -f obj/*.{o,\"$FORMAT_EXT\"}"
			echo_cmd "rm -f out/*.{o,\"$FORMAT_EXT\"}"
		fi

		cmdline="$MAKE target=libretro -j$JOBS"
		cmdline="$cmdline platform=\"$FORMAT_COMPILER_TARGET\""
		cmdline="$cmdline compiler=\"$CXX11\""
		ret=0
		for a in accuracy balanced performance; do
			echo_cmd "$cmdline profile=$a"
			echo_cmd "cp -f \"out/${1}_$a$CORE_SUFFIX\" \"$RARCH_DIST_DIR/${1}_$a$CORE_SUFFIX\""
			ret=$?
			build_summary_log $ret "${1}_$a"
			[ $ret -eq 0 ] || break
		done

		return $ret
	else
		echo "$1 not fetched, skipping ..."
	fi
}

build_libretro_bsnes() {
	if build_should_skip bsnes "$WORKDIR/libretro-bsnes"; then
		echo "Core bsnes is already built, skipping..."
		return
	fi

	build_libretro_bsnes_modern "bsnes"
	build_save_revision $? bsnes
}

build_libretro_bsnes_mercury() {
	if build_should_skip bsnes_mercury "$WORKDIR/libretro-bsnes"; then
		echo "Core bsnes_mercury is already built, skipping..."
		return
	fi

	build_libretro_bsnes_modern "bsnes_mercury"
	build_save_revision $? bsnes_mercury
}

build_libretro_bsnes_cplusplus98() {
	CORENAME="bsnes_cplusplus98"
	build_dir="$WORKDIR/libretro-$CORENAME"

	if build_should_skip $CORENAME "$build_dir"; then
		echo "Core $CORENAME is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo "=== Building $CORENAME ==="
		echo_cmd "cd \"$build_dir\""

		if [ -z "$NOCLEAN" ]; then
			echo_cmd "$MAKE clean" || die "Failed to clean $CORENAME"
		fi

		echo_cmd "$MAKE platform=\"$FORMAT_COMPILER_TARGET\" $COMPILER \"-j$JOBS\""
		echo_cmd "cp \"out/libretro.$FORMAT_EXT\" \"$RARCH_DIST_DIR/$CORENAME$CORE_SUFFIX\""
		ret=$?
		build_summary_log $ret $CORENAME
		build_save_revision $ret $CORENAME
	else
		echo "$CORENAME not fetched, skipping ..."
	fi
}

build_libretro_bnes() {
	build_dir="$WORKDIR/libretro-bnes"

	if build_should_skip bnes "$build_dir"; then
		echo "Core bnes is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo '=== Building bNES ==='
		echo_cmd "cd \"$build_dir\""

		mkdir -p obj
		if [ -z "$NOCLEAN" ]; then
			echo_cmd "$MAKE -f Makefile \"-j$JOBS\" clean" || die 'Failed to clean bNES'
		fi
		echo_cmd "$MAKE -f Makefile $COMPILER \"-j$JOBS\" compiler=\"${CXX11}\"" || die 'Failed to build bNES'
		echo_cmd "cp \"libretro${FORMAT}.$FORMAT_EXT\" \"$RARCH_DIST_DIR/bnes$CORE_SUFFIX\""
		ret=$?
		build_summary_log $ret "bnes"
		build_save_revision $ret "bnes"
	else
		echo 'bNES not fetched, skipping ...'
	fi
}

build_libretro_mupen64() {
	if check_opengl; then
		build_dir="$WORKDIR/libretro-mupen64plus"

		if build_should_skip mupen64plus "$build_dir"; then
			echo "Core mupen64plus is already built, skipping..."
			return
		fi

		if [ -d "$build_dir" ]; then
			echo_cmd "cd \"$build_dir\""

			mkdir -p obj

			if iscpu_x86_64 $ARCH; then
				dynarec="WITH_DYNAREC=x86_64"
			elif iscpu_x86 $ARCH; then
				dynarec="WITH_DYNAREC=x86"
			elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "$platform" = "ios" ]; then
				dynarec="WITH_DYNAREC=arm"
			fi

			echo '=== Building Mupen 64 Plus ==='
			if [ -z "$NOCLEAN" ]; then
				echo_cmd "$MAKE $dynarec platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\" clean" || die 'Failed to clean Mupen 64'
			fi

			echo_cmd "$MAKE $dynarec platform=\"$FORMAT_COMPILER_TARGET_ALT\" $COMPILER \"-j$JOBS\"" || die 'Failed to build Mupen 64'

			echo_cmd "cp \"mupen64plus$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
			ret=$?
			build_summary_log $ret "mupen64plus"
			build_save_revision $ret "mupen64plus"
		else
			echo 'Mupen64 Plus not fetched, skipping ...'
		fi
		reset_compiler_targets
	fi
}

build_summary() {
	if [ -z "$NOBUILD_SUMMARY" ]; then
		if command -v fmt > /dev/null; then
			use_fmt=1
		fi
		printf -v summary "=== Core Build Summary ===\n\n"
		if [ -n "$build_success" ]; then
			printf -v summary "%s%d %s\n" "$summary" "$(echo $build_success | wc -w)" "core(s) successfully built:"
			if [ -n "$use_fmt" ]; then
				printf -v summary "%s%s\n\n" "$summary" "$(echo "	$build_success" | fmt)"
			else
				printf -v summary "%s%s\n\n" "$summary" "$(echo $build_success)"
			fi
		fi
		if [ -n "$build_fail" ]; then
			printf -v summary "%s%d %s\n" "$summary" "$(echo $build_fail | wc -w)" "core(s) failed to build:"
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
# TODO: delete these

build_libretro_2048() {
	libretro_build_core 2048
}
build_libretro_4do() {
	libretro_build_core 4do
}
build_libretro_beetle_gba() {
	libretro_build_core beetle_gba
}
build_libretro_beetle_lynx() {
	libretro_build_core beetle_lynx
}
build_libretro_beetle_ngp() {
	libretro_build_core beetle_ngp
}
build_libretro_beetle_pce_fast() {
	libretro_build_core beetle_pce_fast
}
build_libretro_beetle_pcfx() {
	libretro_build_core beetle_pcfx
}
build_libretro_beetle_psx() {
	libretro_build_core beetle_psx
}
build_libretro_beetle_snes() {
	libretro_build_core beetle_snes
}
build_libretro_beetle_supergrafx() {
	libretro_build_core beetle_supergrafx
}
build_libretro_beetle_vb() {
	libretro_build_core beetle_vb
}
build_libretro_beetle_wswan() {
	libretro_build_core beetle_wsawn
}
build_libretro_bluemsx() {
	libretro_build_core bluemsx
}
build_libretro_catsfc() {
	libretro_build_core catsfc
}
build_libretro_desmume() {
	libretro_build_core desmume
}
build_libretro_dinothawr() {
	libretro_build_core dinothawr
}
build_libretro_dosbox() {
	libretro_build_core dosbox
}
build_libretro_fb_alpha() {
	libretro_build_core fb_alpha
}
build_libretro_fceumm() {
	libretro_build_core fceumm
}
build_libretro_fmsx() {
	libretro_build_core fmsx
}
build_libretro_fuse() {
	libretro_build_core fuse
}
build_libretro_gambatte() {
	libretro_build_core gambatte
}
build_libretro_genesis_plus_gx() {
	libretro_build_core genesis_plus_gx
}
build_libretro_gpsp() {
	libretro_build_core gpsp
}
build_libretro_handy() {
	libretro_build_core handy
}
build_libretro_hatari() {
	libretro_build_core hatari
}
build_libretro_mame078() {
	libretro_build_core mame078
}
build_libretro_mednafen_psx() {
	libretro_build_core mednafen_psx
}
build_libretro_meteor() {
	libretro_build_core meteor
}
build_libretro_nestopia() {
	libretro_build_core nestopia
}
build_libretro_nx() {
	libretro_build_core nxengine
}
build_libretro_o2em() {
	libretro_build_core o2em
}
build_libretro_pcsx_rearmed() {
	libretro_build_core pcsx_rearmed
}
build_libretro_picodrive() {
	libretro_build_core picodrive
}
build_libretro_prboom() {
	libretro_build_core prboom
}
build_libretro_prosystem() {
	libretro_build_core prosystem
}
build_libretro_quicknes() {
	libretro_build_core quicknes
}
build_libretro_scummvm() {
	libretro_build_core scummvm
}
build_libretro_snes9x() {
	libretro_build_core snes9x
}
build_libretro_snes9x_next() {
	libretro_build_core snes9x_next
}
build_libretro_stella() {
	libretro_build_core stella
}
build_libretro_stonesoup() {
	libretro_build_core stonesoup
}
build_libretro_tgbdual() {
	libretro_build_core tgbdual
}
build_libretro_tyrquake() {
	libretro_build_core tyrquake
}
build_libretro_vba_next() {
	libretro_build_core vba_next
}
build_libretro_vbam() {
	libretro_build_core vbam
}
build_libretro_vecx() {
	libretro_build_core vecx
}
build_libretro_virtualjaguar() {
	libretro_build_core virtualjaguar
}
build_libretro_yabause() {
	libretro_build_core yabause
}
