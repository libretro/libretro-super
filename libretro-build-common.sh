# vim: set ts=3 sw=3 noet ft=sh : bash

die() {
	echo $1
	#exit 1
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

[[ "${ARM_NEON}" ]] && echo '=== ARM NEON opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
[[ "${CORTEX_A8}" ]] && echo '=== Cortex A8 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
[[ "${CORTEX_A9}" ]] && echo '=== Cortex A9 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo '=== ARM hardfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo '=== ARM softfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"
[[ "${X86}" ]] && echo '=== x86 CPU detected... ==='
[[ "${X86}" ]] && [[ "${X86_64}" ]] && echo '=== x86_64 CPU detected... ==='
[[ "${IOS}" ]] && echo '=== iOS =='

echo "${FORMAT_COMPILER_TARGET}"
echo "${FORMAT_COMPILER_TARGET_ALT}"
RESET_FORMAT_COMPILER_TARGET=$FORMAT_COMPILER_TARGET
RESET_FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET_ALT

build_summary_log() {
	if [ -n "${BUILD_SUMMARY}" ]; then
		if [ "${1}" -eq "0" ]; then
			echo ${2} >> ${BUILD_SUCCESS}
		else
			echo ${2} >> ${BUILD_FAIL}
		fi
	fi
}

check_opengl() {
	if [ "${BUILD_LIBRETRO_GL}" ]; then
		if [ "${ENABLE_GLES}" ]; then
			echo '=== OpenGL ES enabled ==='
			export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
			export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
		else
			echo '=== OpenGL enabled ==='
			export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
			export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
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
	build_dir="${WORKDIR}/libretro-pcsx_rearmed"
	if [ -d "${build_dir}" ]; then
		echo '=== Building PCSX ReARMed Interpreter ==='
		cd "${build_dir}"

		if [ -z "${NOCLEAN}" ]; then
			"${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean PCSX ReARMed'
		fi
		"${MAKE}" -f Makefile.libretro USE_DYNAREC=0 platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build PCSX ReARMed'
		cp "pcsx_rearmed_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/pcsx_rearmed_interpreter${FORMAT}.${FORMAT_EXT}"
		build_summary_log ${?} "pcsx_rearmed_interpreter"
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
	build_dir="${WORKDIR}/libretro-${1}"
	if [ -d "${build_dir}" ]; then
		echo "=== Building ${2} ==="
		cd "${build_dir}/${3}"

		if [ -z "${NOCLEAN}" ]; then
			make -f ${4} platform=${5} -j$JOBS clean || die "Failed to clean ${2}"
		fi
		make -f ${4} platform=${5} -j$JOBS || die "Failed to build ${2}"
		cp ${2}_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/${2}_libretro$FORMAT.${FORMAT_EXT}
		build_summary_log ${?} ${2}
	fi
}

build_libretro_fba_cps2() {
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps2" "svn-current/trunk/fbacores/cps2" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fba_neogeo() {
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_neo" "svn-current/trunk/fbacores/neogeo" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fba_cps1() {
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps1" "svn-current/trunk/fbacores/cps1" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}


copy_core_to_dist() {
	if [ "$FORMAT_COMPILER_TARGET" = "theos_ios" ]; then
		cp "objs/obj/${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} ${1}
	else
		cp "${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} ${1}
	fi
}

build_libretro_generic() {
	cd "${5}/${2}"

	if [ -z "${NOCLEAN}" ]; then
		"${MAKE}" -f ${3} platform="${4}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die "Failed to build ${1}"
	fi
	echo "${MAKE}" -f ${3} platform="${4}" CC="$CC" CXX="$CXX" "-j${JOBS}"
	"${MAKE}" -f ${3} platform="${4}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die "Failed to build ${1}"
}

# $1 is corename
# $2 is subdir. In case there is no subdir, enter "." here
# $3 is Makefile name
# $4 is preferred platform
build_libretro_generic_makefile() {
	build_dir="${WORKDIR}/libretro-${1}"
	if [ -d "$build_dir" ]; then
		echo "=== Building ${1} ==="
		build_libretro_generic $1 $2 $3 $4 $build_dir
		copy_core_to_dist $1
	else
		echo "${1} not fetched, skipping ..."
	fi
}

build_retroarch_generic_makefile() {
	build_dir="${WORKDIR}/${1}"
	if [ -d "$build_dir" ]; then
		echo "=== Building ${2} ==="
		build_libretro_generic $1 $2 $3 $4 $build_dir
		copy_core_to_dist $5
	else
		echo "${1} not fetched, skipping ..."
	fi
}

build_libretro_stonesoup() {
	build_libretro_generic_makefile "stonesoup" "crawl-ref" "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_hatari() {
	build_libretro_generic_makefile "hatari" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_prosystem() {
	build_libretro_generic_makefile "prosystem" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_4do() {
	build_libretro_generic_makefile "4do" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_o2em() {
	build_libretro_generic_makefile "o2em" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_virtualjaguar() {
	build_libretro_generic_makefile "virtualjaguar" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tgbdual() {
	build_libretro_generic_makefile "tgbdual" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nx() {
	build_libretro_generic_makefile "nxengine" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_catsfc() {
	build_libretro_generic_makefile "catsfc" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_emux() {
	build_libretro_generic_makefile "emux" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET} 1
	copy_core_to_dist "emux_chip8"
	copy_core_to_dist "emux_gb"
	copy_core_to_dist "emux_nes"
	copy_core_to_dist "emux_sms"
}

build_libretro_test() {
	build_retroarch_generic_makefile "retroarch" "libretro-test" "Makefile" ${FORMAT_COMPILER_TARGET} "test"
}

build_libretro_testgl() {
	build_retroarch_generic_makefile "retroarch" "libretro-test-gl" "Makefile" ${FORMAT_COMPILER_TARGET} "testgl"
}

build_libretro_picodrive() {
	build_libretro_generic_makefile "picodrive" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tyrquake() {
	build_libretro_generic_makefile "tyrquake" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_2048() {
	build_libretro_generic_makefile "2048" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vecx() {
	build_libretro_generic_makefile "vecx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_stella() {
	build_libretro_generic_makefile "stella" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_bluemsx() {
	build_libretro_generic_makefile "bluemsx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_handy() {
	build_libretro_generic_makefile "handy" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fmsx() { 
	build_libretro_generic_makefile "fmsx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_gpsp() {
	build_libretro_generic_makefile "gpsp" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_vba_next() {
	build_libretro_generic_makefile "vba_next" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_vbam() {
	build_libretro_generic_makefile "vbam" "src/libretro" "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_snes9x_next() {
	build_libretro_generic_makefile "snes9x_next" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_dinothawr() {
	build_libretro_generic_makefile "dinothawr" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_genesis_plus_gx() {
	build_libretro_generic_makefile "genesis_plus_gx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_mame078() {
	build_libretro_generic_makefile "mame078" "." "makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_prboom() {
	build_libretro_generic_makefile "prboom" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_pcsx_rearmed() {
	build_libretro_generic_makefile "pcsx_rearmed" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fceumm() {
	build_libretro_generic_makefile "fceumm" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_snes() {
	build_libretro_generic_makefile "mednafen_snes" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_lynx() {
	build_libretro_generic_makefile "mednafen_lynx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_wswan() {
	build_libretro_generic_makefile "mednafen_wswan" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_gba() {
	build_libretro_generic_makefile "mednafen_gba" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_ngp() {
	build_libretro_generic_makefile "mednafen_ngp" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_pce_fast() {
	build_libretro_generic_makefile "mednafen_pce_fast" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_vb() {
	build_libretro_generic_makefile "mednafen_vb" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_pcfx() {
	build_libretro_generic_makefile "mednafen_pcfx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_psx() {
	build_libretro_generic_makefile "beetle_psx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_mednafen_psx() {
	build_libretro_generic_makefile "mednafen_psx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_supergrafx() {
	build_libretro_generic_makefile "mednafen_supergrafx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_meteor() {
	build_libretro_generic_makefile "meteor" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nestopia() {
	build_libretro_generic_makefile "nestopia" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_gambatte() {
	build_libretro_generic_makefile "gambatte" "libgambatte" "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_yabause() {
	build_libretro_generic_makefile "yabause" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_desmume() {
	build_libretro_generic_makefile "desmume" "desmume" "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_snes9x() {
	build_libretro_generic_makefile "snes9x" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_quicknes() {
	build_libretro_generic_makefile "quicknes" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_dosbox() {
	build_libretro_generic_makefile "dosbox" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fb_alpha() {
	build_libretro_generic_makefile "fb_alpha" "svn-current/trunk" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_ffmpeg() {
	check_opengl
	build_libretro_generic_makefile "ffmpeg" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
	reset_compiler_targets
}

build_libretro_3dengine() {
	check_opengl
	build_libretro_generic_makefile "3dengine" "." "Makefile" ${FORMAT_COMPILER_TARGET}
	reset_compiler_targets
}

build_libretro_scummvm() {
	build_libretro_generic_makefile "scummvm" "backends/platform/libretro/build" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_ppsspp() {
	check_opengl
	build_libretro_generic_makefile "ppsspp" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
	reset_compiler_targets
}


build_libretro_mame() {
	build_dir="${WORKDIR}/libretro-mame"
	if [ -d "${build_dir}" ]; then
		echo ''
		echo '=== Building MAME ==='
		cd "${build_dir}"

		if [ "$IOS" ]; then
			echo '=== Building MAME (iOS) ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "NATIVE=1" buildtools "-j${JOBS}" || die 'Failed to build MAME buildtools'
			"${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" emulator "-j${JOBS}" || die 'Failed to build MAME (iOS)'
		elif [ "$X86_64" = "true" ]; then
			echo '=== Building MAME64 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		else
			echo '=== Building MAME32 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		fi
		cp "mame_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
	else
		echo 'MAME not fetched, skipping ...'
	fi
}

build_libretro_mess() {
	build_dir="${WORKDIR}/libretro-mame"
	if [ -d "${build_dir}" ]; then
		echo ''
		echo '=== Building MESS ==='
		cd "${build_dir}"

		if [ "$X86_64" = "true" ]; then
			echo '=== Building MESS64 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		else
			echo '=== Building MESS32 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		fi
		cp "mess_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} "mess"
	else
		echo 'MAME not fetched, skipping ...'
	fi
}

rebuild_libretro_mess() {
	build_dir="${WORKDIR}/libretro-mame"
	if [ -d "${build_dir}" ]; then
		echo ''
		echo '=== Building MESS ==='
		cd "${build_dir}"

		if [ "$X86_64" = "true" ]; then
			echo '=== Building MESS64 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		else
			echo '=== Building MESS32 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" -f Makefile.libretro "TARGET=mess" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		fi
		cp "mess_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} "mess"
	else
		echo 'MAME not fetched, skipping ...'
	fi
}

build_libretro_ume() {
	build_dir="${WORKDIR}/libretro-mame"
	if [ -d "${build_dir}" ]; then
		echo ''
		echo '=== Building UME ==='
		cd "${build_dir}"

		if [ "$X86_64" = "true" ]; then
			echo '=== Building UME64 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		else
			echo '=== Building UME32 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		fi
		cp "ume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} "ume"
	else
		echo 'MAME not fetched, skipping ...'
	fi
}

rebuild_libretro_ume() {
	build_dir="${WORKDIR}/libretro-mame"
	if [ -d "${build_dir}" ]; then
		echo ''
		echo '=== Building UME ==='
		cd "${build_dir}"

		if [ "$X86_64" = "true" ]; then
			echo '=== Building UME64 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		else
			echo '=== Building UME32 ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" -f Makefile.libretro "TARGET=ume" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" clean || die 'Failed to clean MAME'
			fi
			"${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build MAME'
		fi
		cp "ume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} "ume"
	else
		echo 'MAME not fetched, skipping ...'
	fi
}

# $1 is corename
# $2 is profile shortname.
# $3 is profile name
build_libretro_bsnes_modern() {
	build_dir="${WORKDIR}/libretro-${1}"
	if [ -d "${build_dir}" ]; then
		echo "=== Building ${1} ${3} ==="
		cd ${build_dir}
		
		if [ -z "${NOCLEAN}" ]; then
			rm -f obj/*.{o,"${FORMAT_EXT}"}
			rm -f out/*.{o,"${FORMAT_EXT}"}
		fi
		"${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="$CXX11" ui='target-libretro' profile="${3}" "-j${JOBS}" || die "Failed to build ${1} ${3} core"
		cp -f "out/${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${1}_${3}_libretro${FORMAT}.${FORMAT_EXT}"
		build_summary_log ${?} "${1}_${3}"
	else
		echo "${1} ${3} not fetched, skipping ..."
	fi
}

build_libretro_bsnes() {
	build_libretro_bsnes_modern "bsnes" "perf" "performance"
	build_libretro_bsnes_modern "bsnes" "balanced" "balanced"
	build_libretro_bsnes_modern "bsnes" "." "accuracy"
}

build_libretro_bsnes_mercury() {
	build_libretro_bsnes_modern "bsnes_mercury" "perf" "performance"
	build_libretro_bsnes_modern "bsnes_mercury" "balanced" "balanced"
	build_libretro_bsnes_modern "bsnes_mercury" "." "accuracy"
}

build_libretro_bsnes_cplusplus98() {
	CORENAME="bsnes_cplusplus98"
	build_dir="${WORKDIR}/libretro-${CORENAME}"
	if [ -d "${build_dir}" ]; then
		echo "=== Building ${CORENAME} ==="
		cd ${build_dir}

		if [ -z "${NOCLEAN}" ]; then
			"${MAKE}" clean || die "Failed to clean ${CORENAME}"
		fi
		"${MAKE}" platform="${FORMAT_COMPILER_TARGET}" CC="$CC" CXX="$CXX" "-j${JOBS}"
		cp "out/libretro.${FORMAT_EXT}" "${RARCH_DIST_DIR}/${CORENAME}_libretro${FORMAT}.${FORMAT_EXT}"
		build_summary_log ${?} ${CORENAME}
	else
		echo "${CORENAME} not fetched, skipping ..."
	fi
}

build_libretro_bnes() {
	build_dir="${WORKDIR}/libretro-bnes"
	if [ -d "${build_dir}" ]; then
		echo '=== Building bNES ==='
		cd ${build_dir}

		mkdir -p obj
		if [ -z "${NOCLEAN}" ]; then
			"${MAKE}" -f Makefile "-j${JOBS}" clean || die 'Failed to clean bNES'
		fi
		"${MAKE}" -f Makefile CC="$CC" CXX="$CXX" "-j${JOBS}" compiler="${CXX11}" || die 'Failed to build bNES'
		cp "libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bnes_libretro${FORMAT}.${FORMAT_EXT}"
		build_summary_log ${?} "bnes"
	else
		echo 'bNES not fetched, skipping ...'
	fi
}

build_libretro_mupen64() {
	check_opengl
	build_dir="${WORKDIR}/libretro-mupen64plus"
	if [ -d "${build_dir}" ]; then
		cd "${build_dir}"

		mkdir -p obj
		if [ "${X86}" ] && [ "${X86_64}" ]; then
			echo '=== Building Mupen 64 Plus (x86_64 dynarec) ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" WITH_DYNAREC='x86_64' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86_64 dynarec)'
			fi
			"${MAKE}" WITH_DYNAREC='x86_64' platform="${FORMAT_COMPILER_TARGET_ALT}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build Mupen 64 (x86_64 dynarec)'
		elif [ "${X86}" ]; then
			echo '=== Building Mupen 64 Plus (x86 32bit dynarec) ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" WITH_DYNAREC='x86' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86 dynarec)'
			fi
			"${MAKE}" WITH_DYNAREC='x86' platform="${FORMAT_COMPILER_TARGET_ALT}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build Mupen 64 (x86 dynarec)'
		elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "${IOS}" ]; then
			echo '=== Building Mupen 64 Plus (ARM dynarec) ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" WITH_DYNAREC='arm' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (ARM dynarec)'
			fi
			"${MAKE}" WITH_DYNAREC='arm' platform="${FORMAT_COMPILER_TARGET_ALT}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build Mupen 64 (ARM dynarec)'
		else
			echo '=== Building Mupen 64 Plus ==='
			if [ -z "${NOCLEAN}" ]; then
				"${MAKE}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64'
			fi
			"${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" CC="$CC" CXX="$CXX" "-j${JOBS}" || die 'Failed to build Mupen 64'
		fi
		cp "mupen64plus_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
		build_summary_log ${?} "mupen64plus"
	else
		echo 'Mupen64 Plus not fetched, skipping ...'
	fi
	reset_compiler_targets
}

build_summary() {
	if [ -z "${NOBUILD_SUMMARY}" ]; then
		echo "=== Core Build Summary ===" > ${BUILD_SUMMARY}
		if [ -r "${BUILD_SUCCESS}" ]; then
			echo "`wc -l < ${BUILD_SUCCESS}` core(s) successfully built:" >> ${BUILD_SUMMARY}
			${BUILD_SUMMARY_FMT} ${BUILD_SUCCESS} >> ${BUILD_SUMMARY}
		else
			echo "		0 cores successfully built. :(" >> ${BUILD_SUMMARY}
			echo "`wc -l < ${BUILD_FAIL}` core(s) failed to build:"
		fi
		if [ -r "${BUILD_FAIL}" ]; then
			echo "`wc -l < ${BUILD_FAIL}` core(s) failed to build:" >> ${BUILD_SUMMARY}
			${BUILD_SUMMARY_FMT} ${BUILD_FAIL} >> ${BUILD_SUMMARY}
		else
			echo "      0 cores failed to build! :D" >> ${BUILD_SUMMARY}
		fi
		rm -f $BUILD_SUCCESS $BUILD_FAIL
		cat ${BUILD_SUMMARY}
	fi
}

create_dist_dir() {
	if [ -d "${RARCH_DIST_DIR}" ]; then
		echo "Directory ${RARCH_DIST_DIR} already exists, skipping creation..."
	else
		mkdir -p "${RARCH_DIST_DIR}"
	fi
}

create_dist_dir

