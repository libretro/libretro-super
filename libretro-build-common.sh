# vim: set ts=3 sw=3 noet ft=sh : bash

. "${BASE_DIR}/script-modules/fetch-rules.sh"

die() {
	echo $1
	#exit 1
}

echo_cmd() {
	eval 'echo "$@"'
	eval "$@"
}


#
# FIXME: Okay regarding COMPILER...  It's no longer used to build any targets
# in this file because it doesn't let you specify arguments to the compiler
# such as CC="gcc -something".  We need to be able to do that on the Mac in
# particular because we need to be able to specify -arch to build on a CPU
# other than the default.
#
# Basically, if you use this variable, you should stop.  :)
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

CORE_SUFFIX="_lib\retro${FORMAT}.$FORMAT_EXT"


build_summary_log() {
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
	if [ "${BUILD_LIBRETRO_GL}" ]; then
		if [ "${ENABLE_GLES}" ]; then
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
	fi
}

reset_compiler_targets() {
	export FORMAT_COMPILER_TARGET=$RESET_FORMAT_COMPILER_TARGET
	export FORMAT_COMPILER_TARGET_ALT=$RESET_FORMAT_COMPILER_TARGET_ALT
}

build_libretro_pcsx_rearmed_interpreter() {
	build_dir="$WORKDIR/libretro-pcsx_rearmed"
	if [ -d "$build_dir" ]; then
		echo '=== Building PCSX ReARMed Interpreter ==='
		echo "cd \"$build_dir\""
		cd "$build_dir"

		if [ -z "$NOCLEAN" ]; then
			if [ "$CC $CXX" != " " ]; then
				echo "$MAKE -f Makefile.libretro platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\" clean"
				$MAKE -f Makefile.libretro platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "-j$JOBS" clean || die 'Failed to clean PCSX ReARMed'
			else
				# TODO: Remove this condition post-1.1
				echo "$MAKE -f Makefile.libretro platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" clean"
				$MAKE -f Makefile.libretro platform="$FORMAT_COMPILER_TARGET" "-j$JOBS" clean || die 'Failed to clean PCSX ReARMed'
			fi
		fi
		if [ "$CC $CXX" != " " ]; then
			echo "$MAKE -f Makefile.libretro USE_DYNAREC=0 platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
			$MAKE -f Makefile.libretro USE_DYNAREC=0 platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "-j$JOBS" || die 'Failed to build PCSX ReARMed'
		else
			# TODO: Remove this condition post-1.1
			echo "$MAKE -f Makefile.libretro USE_DYNAREC=0 platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\""
			$MAKE -f Makefile.libretro USE_DYNAREC=0 platform="$FORMAT_COMPILER_TARGET" "-j$JOBS" || die 'Failed to build PCSX ReARMed'
		fi
		echo "cp \"pcsx_rearmed$CORE_SUFFIX\" \"$RARCH_DIST_DIR/pcsx_rearmed_interpreter${FORMAT}.$FORMAT_EXT\""
		cp "pcsx_rearmed$CORE_SUFFIX" "$RARCH_DIST_DIR/pcsx_rearmed_interpreter${FORMAT}.$FORMAT_EXT"
		build_summary_log $? "pcsx_rearmed_interpreter"
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
		echo "cd \"$build_dir/$3\""
		cd "$build_dir/$3"

		if [ -z "$NOCLEAN" ]; then
			echo "$MAKE -f \"$4\" platform=$5 -j$JOBS clean"
			$MAKE -f "$4" platform=$5 -j$JOBS clean || die "Failed to clean $2"
		fi
		echo "$MAKE -f $4 platform=$5 -j$JOBS"
		$MAKE -f $4 platform=$5 -j$JOBS || die "Failed to build $2"
		echo "cp $2$CORE_SUFFIX $RARCH_DIST_DIR/$2$CORE_SUFFIX"
		cp $2$CORE_SUFFIX $RARCH_DIST_DIR/$2$CORE_SUFFIX
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
		echo "cp \"objs/obj/$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
		cp "objs/obj/$1$CORE_SUFFIX" "$RARCH_DIST_DIR"
	else
		echo "cp \"$1$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
		cp "$1$CORE_SUFFIX" "$RARCH_DIST_DIR"
	fi

	ret=$?
	build_summary_log $ret "$1"
	return $ret
}

build_libretro_generic() {
	cd "$5/$2"

	if [ -z "$NOCLEAN" ]; then
		if [ "$CC $CXX" != " " ]; then
			echo "$MAKE -f \"$3\" platform=\"$4\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\" clean"
			$MAKE -f "$3" platform="$4" CC="$CC" CXX="$CXX" "-j$JOBS" clean || die "Failed to clean $1"
		else
			# TODO: Remove this condition post-1.1
			echo "$MAKE -f \"$3\" platform=\"$4\" \"-j$JOBS\" clean"
			$MAKE -f "$3" platform="$4" "-j$JOBS" clean || die "Failed to clean $1"
		fi
	fi
	if [ "$CC $CXX" != " " ]; then
		echo "$MAKE -f \"$3\" platform=\"$4\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
		$MAKE -f "$3" platform="$4" CC="$CC" CXX="$CXX" "-j$JOBS" || die "Failed to build $1"
	else
		# TODO: Remove this condition post-1.1
		echo "$MAKE -f \"$3\" platform=\"$4\" \"-j$JOBS\""
		$MAKE -f "$3" platform="$4" "-j$JOBS" || die "Failed to build $1"
	fi
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

build_retroarch_generic_makefile() {
	build_dir="$WORKDIR/$1"

	if build_should_skip $1 "$build_dir"; then
		echo "Core $1 is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo "=== Building $2 ==="
		build_libretro_generic $1 "$2" "$3" $4 "$build_dir"
		copy_core_to_dist $5
		build_save_revision $? $1
	else
		echo "$1 not fetched, skipping ..."
	fi
}

build_libretro_stonesoup() {
	build_libretro_generic_makefile "stonesoup" "crawl-ref" "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_hatari() {
	build_libretro_generic_makefile "hatari" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_prosystem() {
	build_libretro_generic_makefile "prosystem" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_4do() {
	build_libretro_generic_makefile "4do" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_o2em() {
	build_libretro_generic_makefile "o2em" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_virtualjaguar() {
	build_libretro_generic_makefile "virtualjaguar" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_tgbdual() {
	build_libretro_generic_makefile "tgbdual" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_nx() {
	build_libretro_generic_makefile "nxengine" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_catsfc() {
	build_libretro_generic_makefile "catsfc" "." "Makefile" $FORMAT_COMPILER_TARGET
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

build_libretro_test() {
	build_retroarch_generic_makefile "retroarch" "libretro-test" "Makefile" $FORMAT_COMPILER_TARGET "test"
}

build_libretro_testgl() {
	build_retroarch_generic_makefile "retroarch" "libretro-test-gl" "Makefile" $FORMAT_COMPILER_TARGET "testgl"
}

build_libretro_picodrive() {
	build_libretro_generic_makefile "picodrive" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_tyrquake() {
	build_libretro_generic_makefile "tyrquake" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_2048() {
	build_libretro_generic_makefile "2048" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_vecx() {
	build_libretro_generic_makefile "vecx" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_stella() {
	build_libretro_generic_makefile "stella" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_bluemsx() {
	build_libretro_generic_makefile "bluemsx" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_handy() {
	build_libretro_generic_makefile "handy" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_fmsx() { 
	build_libretro_generic_makefile "fmsx" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_gpsp() {
	build_libretro_generic_makefile "gpsp" "." "Makefile" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_fuse() {
	build_libretro_generic_makefile "fuse" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_vba_next() {
	build_libretro_generic_makefile "vba_next" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_vbam() {
	build_libretro_generic_makefile "vbam" "src/libretro" "Makefile" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_snes9x_next() {
	build_libretro_generic_makefile "snes9x_next" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_dinothawr() {
	build_libretro_generic_makefile "dinothawr" "." "Makefile" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_genesis_plus_gx() {
	build_libretro_generic_makefile "genesis_plus_gx" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_mame078() {
	build_libretro_generic_makefile "mame078" "." "makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_prboom() {
	build_libretro_generic_makefile "prboom" "." "Makefile" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_pcsx_rearmed() {
	build_libretro_generic_makefile "pcsx_rearmed" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_fceumm() {
	build_libretro_generic_makefile "fceumm" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_snes() {
	build_libretro_generic_makefile "mednafen_snes" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_lynx() {
	build_libretro_generic_makefile "mednafen_lynx" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_wswan() {
	build_libretro_generic_makefile "mednafen_wswan" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_gba() {
	build_libretro_generic_makefile "mednafen_gba" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_ngp() {
	build_libretro_generic_makefile "mednafen_ngp" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_pce_fast() {
	build_libretro_generic_makefile "mednafen_pce_fast" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_vb() {
	build_libretro_generic_makefile "mednafen_vb" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_pcfx() {
	build_libretro_generic_makefile "mednafen_pcfx" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_psx() {
	build_libretro_generic_makefile "beetle_psx" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_mednafen_psx() {
	build_libretro_generic_makefile "mednafen_psx" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_beetle_supergrafx() {
	build_libretro_generic_makefile "mednafen_supergrafx" "." "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_meteor() {
	build_libretro_generic_makefile "meteor" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_nestopia() {
	build_libretro_generic_makefile "nestopia" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_gambatte() {
	build_libretro_generic_makefile "gambatte" "libgambatte" "Makefile.libretro" $FORMAT_COMPILER_TARGET_ALT
}

build_libretro_yabause() {
	build_libretro_generic_makefile "yabause" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_desmume() {
	build_libretro_generic_makefile "desmume" "desmume" "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_snes9x() {
	build_libretro_generic_makefile "snes9x" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_quicknes() {
	build_libretro_generic_makefile "quicknes" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_dosbox() {
	build_libretro_generic_makefile "dosbox" "." "Makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_fb_alpha() {
	build_libretro_generic_makefile "fb_alpha" "svn-current/trunk" "makefile.libretro" $FORMAT_COMPILER_TARGET
}

build_libretro_ffmpeg() {
	check_opengl
	build_libretro_generic_makefile "ffmpeg" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
	reset_compiler_targets
}

build_libretro_3dengine() {
	check_opengl
	build_libretro_generic_makefile "3dengine" "." "Makefile" $FORMAT_COMPILER_TARGET
	reset_compiler_targets
}

build_libretro_scummvm() {
	build_libretro_generic_makefile "scummvm" "backends/platform/libretro/build" "Makefile" $FORMAT_COMPILER_TARGET
}

build_libretro_ppsspp() {
	check_opengl
	build_libretro_generic_makefile "ppsspp" "libretro" "Makefile" $FORMAT_COMPILER_TARGET
	reset_compiler_targets
}

build_libretro_mame_modern() {
	build_dir="$WORKDIR/libretro-mame"
	if [ -d "$build_dir" ]; then
		echo ''
		echo "=== Building $1 ==="
		echo "cd \"$build_dir\""
		cd "$build_dir"

		if [ -n "$IOS" ]; then
			# iOS must set CC/CXX
			if [ -z "$NOCLEAN" ]; then
				echo "$MAKE -f Makefile.libretro \"TARGET=$2\" \"PARTIAL=$3\" platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\" clean"
				$MAKE -f Makefile.libretro "TARGET=$2" "PARTIAL=$3" platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "-j$JOBS" clean || die 'Failed to clean MAME'
			fi
			echo "$MAKE -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"NATIVE=1\" buildtools \"-j$JOBS\""
			$MAKE -f Makefile.libretro "TARGET=$2" platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "NATIVE=1" buildtools "-j$JOBS" || die 'Failed to build MAME buildtools'
			echo "$MAKE -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" emulator \"-j$JOBS\""
			$MAKE -f Makefile.libretro "TARGET=$2" platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" emulator "-j$JOBS" || die 'Failed to build MAME (iOS)'
		else
			[ "$X86_64" = "true" ] && PTR64=1
			if [ -z "$NOCLEAN" ]; then
				if [ "$CC $CXX" != " " ]; then
					echo "$MAKE PTR64=1 -f Makefile.libretro \"TARGET=$2\" \"PARTIAL=$3\" platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\" clean"
					$MAKE PTR64=1 -f Makefile.libretro "TARGET=$2" "PARTIAL=$3" platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "-j$JOBS" clean || die 'Failed to clean MAME'
				else
					# TODO: Remove this condition post-1.1
					echo "$MAKE PTR64=1 -f Makefile.libretro \"TARGET=$2\" \"PARTIAL=$3\" platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\" clean"
					$MAKE PTR64=1 -f Makefile.libretro "TARGET=$2" "PARTIAL=$3" platform="$FORMAT_COMPILER_TARGET" "-j$JOBS" clean || die 'Failed to clean MAME'
				fi
			fi
			if [ "$CC $CXX" != " " ]; then
				echo "$MAKE PTR64=1 -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
				$MAKE "PTR64=$PTR64" -f Makefile.libretro "TARGET=$2" platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "-j$JOBS" || die 'Failed to build MAME'
			else
				# TODO: Remove this condition post-1.1
				echo "$MAKE PTR64=1 -f Makefile.libretro \"TARGET=$2\" platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\""
				$MAKE "PTR64=$PTR64" -f Makefile.libretro "TARGET=$2" platform="$FORMAT_COMPILER_TARGET" "-j$JOBS" || die 'Failed to build MAME'
			fi
		fi

		echo "cp \"$2$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
		cp "$2$CORE_SUFFIX" "$RARCH_DIST_DIR"
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
		echo "cd \"$build_dir\""
		cd "$build_dir"

		if [ -z "$NOCLEAN" ]; then
			echo "$MAKE clean"
			$MAKE clean || die "Failed to clean $CORENAME"
		fi
		if [ "$CC $CXX" != " " ]; then
			echo "$MAKE platform=\"$FORMAT_COMPILER_TARGET\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
			$MAKE platform="$FORMAT_COMPILER_TARGET" CC="$CC" CXX="$CXX" "-j$JOBS"
		else
			# TODO: Remove this condition post-1.1
			echo "$MAKE platform=\"$FORMAT_COMPILER_TARGET\" \"-j$JOBS\""
			$MAKE platform="$FORMAT_COMPILER_TARGET" "-j$JOBS"
		fi
		echo "cp \"out/libretro.$FORMAT_EXT\" \"$RARCH_DIST_DIR/$CORENAME$CORE_SUFFIX\""
		cp "out/libretro.$FORMAT_EXT" "$RARCH_DIST_DIR/$CORENAME$CORE_SUFFIX"
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
		echo "cd \"$build_dir\""
		cd "$build_dir"

		mkdir -p obj
		if [ -z "$NOCLEAN" ]; then
			echo "$MAKE -f Makefile \"-j$JOBS\" clean"
			$MAKE -f Makefile "-j$JOBS" clean || die 'Failed to clean bNES'
		fi
		if [ "$CC $CXX" != " " ]; then
			echo "$MAKE -f Makefile CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\" compiler=\"${CXX11}\""
			$MAKE -f Makefile CC="$CC" CXX="$CXX" "-j$JOBS" compiler="${CXX11}" || die 'Failed to build bNES'
		else
			# TODO: Remove this condition post-1.1
			echo "$MAKE -f Makefile \"-j$JOBS\" compiler=\"${CXX11}\""
			$MAKE -f Makefile "-j$JOBS" compiler="${CXX11}" || die 'Failed to build bNES'
		fi
		echo "cp \"libretro${FORMAT}.$FORMAT_EXT\" \"$RARCH_DIST_DIR/bnes$CORE_SUFFIX\""
		cp "libretro${FORMAT}.$FORMAT_EXT" "$RARCH_DIST_DIR/bnes$CORE_SUFFIX"
		ret=$?
		build_summary_log $ret "bnes"
		build_save_revision $ret "bnes"
	else
		echo 'bNES not fetched, skipping ...'
	fi
}

build_libretro_mupen64() {
	check_opengl
	build_dir="$WORKDIR/libretro-mupen64plus"

	if build_should_skip mupen64plus "$build_dir"; then
		echo "Core mupen64plus is already built, skipping..."
		return
	fi

	if [ -d "$build_dir" ]; then
		echo "cd \"$build_dir\""
		cd "$build_dir"

		mkdir -p obj
		if [ "$X86" ] && [ "$X86_64" ]; then
			echo '=== Building Mupen 64 Plus (x86_64 dynarec) ==='
			if [ -z "$NOCLEAN" ]; then
				echo "$MAKE WITH_DYNAREC='x86_64' platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\" clean"
				$MAKE WITH_DYNAREC='x86_64' platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" clean || die 'Failed to clean Mupen 64 (x86_64 dynarec)'
			fi
			if [ "$CC $CXX" != " " ]; then
				echo "$MAKE WITH_DYNAREC='x86_64' platform=\"$FORMAT_COMPILER_TARGET_ALT\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\" || die 'Failed to build Mupen 64 (x86_64 dynarec)'"
				$MAKE WITH_DYNAREC='x86_64' platform="$FORMAT_COMPILER_TARGET_ALT" CC="$CC" CXX="$CXX" "-j$JOBS" || die 'Failed to build Mupen 64 (x86_64 dynarec)'
			else
				# TODO: Remove this condition post-1.1
				echo "$MAKE WITH_DYNAREC='x86_64' platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\" || die 'Failed to build Mupen 64 (x86_64 dynarec)'"
				$MAKE WITH_DYNAREC='x86_64' platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" || die 'Failed to build Mupen 64 (x86_64 dynarec)'
			fi
		elif [ "$X86" ]; then
			echo '=== Building Mupen 64 Plus (x86 32bit dynarec) ==='
			if [ -z "$NOCLEAN" ]; then
				echo "$MAKE WITH_DYNAREC='x86' platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\" clean"
				$MAKE WITH_DYNAREC='x86' platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" clean || die 'Failed to clean Mupen 64 (x86 dynarec)'
			fi
			if [ "$CC $CXX" != " " ]; then
				echo "$MAKE WITH_DYNAREC='x86' platform=\"$FORMAT_COMPILER_TARGET_ALT\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
				$MAKE WITH_DYNAREC='x86' platform="$FORMAT_COMPILER_TARGET_ALT" CC="$CC" CXX="$CXX" "-j$JOBS" || die 'Failed to build Mupen 64 (x86 dynarec)'
			else
				# TODO: Remove this condition post-1.1
				echo "$MAKE WITH_DYNAREC='x86' platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\""
				$MAKE WITH_DYNAREC='x86' platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" || die 'Failed to build Mupen 64 (x86 dynarec)'
			fi
		elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "${IOS}" ]; then
			echo '=== Building Mupen 64 Plus (ARM dynarec) ==='
			if [ -z "$NOCLEAN" ]; then
				echo "$MAKE WITH_DYNAREC='arm' platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\""
				$MAKE WITH_DYNAREC='arm' platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" clean || die 'Failed to clean Mupen 64 (ARM dynarec)'
			fi
			if [ "$CC $CXX" != " " ]; then
				echo "$MAKE WITH_DYNAREC='arm' platform=\"$FORMAT_COMPILER_TARGET_ALT\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
				$MAKE WITH_DYNAREC='arm' platform="$FORMAT_COMPILER_TARGET_ALT" CC="$CC" CXX="$CXX" "-j$JOBS" || die 'Failed to build Mupen 64 (ARM dynarec)'
			else
				# TODO: Remove this condition post-1.1
				echo "$MAKE WITH_DYNAREC='arm' platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\""
				$MAKE WITH_DYNAREC='arm' platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" || die 'Failed to build Mupen 64 (ARM dynarec)'
			fi
		else
			echo '=== Building Mupen 64 Plus ==='
			if [ -z "$NOCLEAN" ]; then
				echo "$MAKE \"-j$JOBS\" clean"
				$MAKE "-j$JOBS" clean || die 'Failed to clean Mupen 64'
			fi
			if [ "$CC $CXX" != " " ]; then
				echo "$MAKE platform=\"$FORMAT_COMPILER_TARGET_ALT\" CC=\"$CC\" CXX=\"$CXX\" \"-j$JOBS\""
				$MAKE platform="$FORMAT_COMPILER_TARGET_ALT" CC="$CC" CXX="$CXX" "-j$JOBS" || die 'Failed to build Mupen 64'
			else
				# TODO: Remove this condition post-1.1
				echo "$MAKE platform=\"$FORMAT_COMPILER_TARGET_ALT\" \"-j$JOBS\""
				$MAKE platform="$FORMAT_COMPILER_TARGET_ALT" "-j$JOBS" || die 'Failed to build Mupen 64'
			fi
		fi
		echo "cp \"mupen64plus$CORE_SUFFIX\" \"$RARCH_DIST_DIR\""
		cp "mupen64plus$CORE_SUFFIX" "$RARCH_DIST_DIR"
		ret=$?
		build_summary_log $ret "mupen64plus"
		build_save_revision $ret "mupen64plus"
	else
		echo 'Mupen64 Plus not fetched, skipping ...'
	fi
	reset_compiler_targets
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
