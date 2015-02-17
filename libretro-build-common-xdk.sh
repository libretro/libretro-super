# vim: set ts=3 sw=3 noet ft=sh : bash

die()
{
	echo $1
	#exit 1
}

# $1 is corename
# $2 subdir. If there is no subdir, input "." here
# $3 build configuration - ie. release or release_ltcg
build_libretro_generic_makefile() {
	cd "$BASE_DIR"
	if [ -d "libretro-${1}" ]; then
		echo "=== Building ${1} ==="
		cd libretro-${1}
		cd ${2}
		cd msvc
		cmd.exe /k $MSVC_NAME.bat
		cp $MSVC_NAME/${3}/${MSVC_NAME}.${FORMAT_EXT} "$RARCH_DIST_DIR"/${1}_libretro$FORMAT.$FORMAT_EXT
	else
		echo "${1} not fetched, skipping ..."
	fi
}

build_libretro_beetle_bsnes() {
	build_libretro_generic_makefile "mednafen_snes" "." $RELEASE_LTCG
}

build_libretro_beetle_lynx() {
	build_libretro_generic_makefile "mednafen_lynx" "." $RELEASE_LTCG
}

build_libretro_beetle_wswan() {
	build_libretro_generic_makefile "mednafen_wswan" "." $RELEASE_LTCG
}

build_libretro_beetle_gba() {
	build_libretro_generic_makefile "mednafen_gba" "." $RELEASE_LTCG
}

build_libretro_beetle_ngp() {
	build_libretro_generic_makefile "mednafen_ngp" "." $RELEASE_LTCG
}

build_libretro_beetle_pce_fast() {
	build_libretro_generic_makefile "mednafen_pce_fast" "." $RELEASE_LTCG
}

build_libretro_beetle_supergrafx() {
	build_libretro_generic_makefile "mednafen_supergrafx" "." $RELEASE_LTCG
}

build_libretro_beetle_pcfx() {
	build_libretro_generic_makefile "mednafen_pcfx" "." $RELEASE_LTCG
}

build_libretro_beetle_vb() {
	build_libretro_generic_makefile "mednafen_vb" "." $RELEASE_LTCG
}

build_libretro_snes9x() {
	build_libretro_generic_makefile "snes9x" "libretro" $RELEASE_LTCG
}

build_libretro_s9x_next() {
	build_libretro_generic_makefile "snes9x_next" "libretro" $RELEASE_LTCG
}

build_libretro_genesis_plus_gx() {
	build_libretro_generic_makefile "genesis_plus_gx" "libretro" $RELEASE_LTCG
}

build_libretro_vba_next() {
	build_libretro_generic_makefile "genesis_plus_gx" "libretro" $RELEASE
}

build_libretro_mame078() {
	build_libretro_generic_makefile "mame078" "libretro" $RELEASE
}

build_libretro_fceumm() {
	build_libretro_generic_makefile "fceumm" "src/drivers/libretro" $RELEASE_LTCG
}

build_libretro_gambatte()
{
	build_libretro_generic_makefile "gambatte" "libgambatte/libretro" $RELEASE_LTCG
}

build_libretro_nx() {
	build_libretro_generic_makefile "nxengine" "nxengine-1.0.0.4/libretro" $RELEASE_LTCG
}

build_libretro_prboom() {
	build_libretro_generic_makefile "prboom" "libretro" $RELEASE_LTCG
}

build_libretro_stella() {
	build_libretro_generic_makefile "stella" "." $RELEASE_LTCG
}

build_libretro_picodrive() {
	build_libretro_generic_makefile "picodrive" "platform/libretro" $RELEASE_LTCG
}

build_libretro_nestopia() {
	build_libretro_generic_makefile "nestopia" "libretro" $RELEASE_LTCG
}

build_libretro_tyrquake() {
	build_libretro_generic_makefile "tyrquake" "libretro" $RELEASE_LTCG
}

create_dist_dir()
{
	if [ -d $RARCH_DIR ]; then
		echo "Directory $RARCH_DIR already exists, skipping creation..."
	else
		mkdir $RARCH_DIR
	fi

	if [ -d $RARCH_DIST_DIR ]; then
		echo "Directory $RARCH_DIST_DIR already exists, skipping creation..."
	else
		mkdir $RARCH_DIST_DIR
	fi
}

create_dist_dir
