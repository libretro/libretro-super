#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

. ./libretro-config.sh

#split TARGET_ABI string into an array we can iterate over
IFS=' ' read -ra ABIS <<< "$TARGET_ABIS"

# BSDs don't have readlink -f
read_link()
{
	TARGET_FILE="$1"
	cd $(dirname "$TARGET_FILE")
	TARGET_FILE=$(basename "$TARGET_FILE")

	while [ -L "$TARGET_FILE" ]
	do
		TARGET_FILE=$(readlink "$TARGET_FILE")
		cd $(dirname "$TARGET_FILE")
		TARGET_FILE=$(basename "$TARGET_FILE")
	done

	PHYS_DIR=$(pwd -P)
	RESULT="$PHYS_DIR/$TARGET_FILE"
	echo $RESULT
}

SCRIPT=$(read_link "$0")
echo "Script: $SCRIPT"
BASE_DIR=$(dirname $SCRIPT)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/android
FORMAT=_android
FORMAT_EXT=so

die()
{
	echo $1
	#exit 1
}



# $1 is core name
# $2 is subdir (if there's no subdir, put "." here)
build_libretro_generic_makefile()
{
	cd $BASE_DIR
	if [ -d "libretro-${1}" ]; then
		echo "=== Building ${1} ==="
		cd libretro-${1}
		cd ${2}
		for a in "${ABIS[@]}"; do
			if [ -z "${NOCLEAN}" ]; then
				ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${1}"
			fi
			ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build  ${a} ${1}"
			cp ../libs/${a}/libretro.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${1}_libretro${FORMAT}.${FORMAT_EXT}
		done
	else
		echo "${1} not fetched, skipping ..."
	fi
}

build_libretro_vba_next() {
	build_libretro_generic_makefile "vba_next" "libretro/jni"
}

build_libretro_vbam() {
	build_libretro_generic_makefile "vbam" "src/libretro/jni"
}


build_libretro_tgbdual() {
	build_libretro_generic_makefile "tgbdual" "libretro/jni"
}

build_libretro_prboom()
{
	build_libretro_generic_makefile "prboom" "libretro/jni"
}

build_libretro_nestopia() {
	build_libretro_generic_makefile "nestopia" "libretro/jni"
}

build_libretro_tyrquake() {
	build_libretro_generic_makefile "tyrquake" "libretro/jni"
}

build_libretro_ppsspp() {
	build_libretro_generic_makefile "ppsspp" "libretro/jni"
}

build_libretro_quicknes() {
	build_libretro_generic_makefile "quicknes" "libretro/jni"
}

build_libretro_handy() {
	build_libretro_generic_makefile "handy" "libretro/jni"
}

build_libretro_yabause() {
	build_libretro_generic_makefile "yabause" "libretro/jni"
}

build_libretro_vecx() {
	build_libretro_generic_makefile "vecx" "libretro/jni"
}

build_libretro_fceumm() {
	build_libretro_generic_makefile "fceumm" "src/drivers/libretro/jni"
}

build_libretro_gambatte() {
	build_libretro_generic_makefile "gambatte" "libgambatte/libretro/jni"
}



build_libretro_dinothawr() {
	build_libretro_generic_makefile "dinothawr" "android/eclipse/jni"
}


build_libretro_desmume() {
	build_libretro_generic_makefile "desmume" "desmume/src/libretro/jni"
}

build_libretro_fb_alpha() {
	build_libretro_generic_makefile "fb_alpha" "svn-current/trunk/projectfiles/libretro-android/jni"
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
	
	for a in "${ABIS[@]}"; do
		if [ -d $RARCH_DIST_DIR/${a} ]; then
			echo "Directory $RARCH_DIST_DIR/${a} already exists, skipping creation..."
		else
			mkdir $RARCH_DIST_DIR/${a}
		fi
	done
}

build_libretro_bsnes()
{
	CORENAME="bsnes"
	#TODO - maybe accuracy/balanced cores as well
	cd $BASE_DIR
	if [ -d "libretro-${CORENAME}" ]; then
		echo "=== Building ${CORENAME} ==="
		cd libretro-${CORENAME}/
		cd target-libretro/jni
		for a in "${ABIS[@]}"; do
			if [ -z "${NOCLEAN}" ]; then
				ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
			fi
			ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build ${a} ${CORENAME}"
			cp ../libs/${a}/libretro_${CORENAME}_performance.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_performance_libretro${FORMAT}.${FORMAT_EXT}
		done
	else
		echo "${CORENAME} not fetched, skipping ..."
	fi
}

build_libretro_bsnes_mercury()
{
	CORENAME="bsnes"
	#TODO - maybe accuracy/balanced cores as well
	cd $BASE_DIR
	if [ -d "libretro-${CORENAME}" ]; then
		echo "=== Building ${CORENAME}-mercury ==="
		cd libretro-${CORENAME}/
		cd target-libretro/jni
		for a in "${ABIS[@]}"; do
			if [ -z "${NOCLEAN}" ]; then
				ndk-build clean APP_ABI=${a} || die "Failed to clean ${a} ${CORENAME}"
			fi
			ndk-build -j$JOBS APP_ABI=${a} || die "Failed to build ${a} ${CORENAME}"
			cp ../libs/${a}/libretro_${CORENAME}_performance.${FORMAT_EXT} $RARCH_DIST_DIR/${a}/${CORENAME}_mercury_performance_libretro${FORMAT}.${FORMAT_EXT}
		done
	else
		echo "${CORENAME} not fetched, skipping ..."
	fi
}



create_dist_dir

if [ $1 ]; then
	WANT_CORES="$1"
else
WANT_CORES=" \
	2048 \
   4do \
	bluemsx \
	fmsx \
	mednafen_lynx \
	mednafen_ngp \
	mednafen_pce_fast \
	mednafen_supergrafx \
	mednafen_pcfx \
	mednafen_vb \
	mednafen_wswan \
	mednafen_psx \
	catsfc \
	snes9x \
	snes9x_next \
	genesis_plus_gx \
	virtualjaguar \
	stella \
	gpsp \
	dosbox \
	picodrive \
	3dengine \
	prosystem \
	meteor \
	nxengine \
	o2em \
	pcsx_rearmed \
	mupen64plus"
build_libretro_bsnes
build_libretro_bsnes_mercury
fi

for core in $WANT_CORES; do
	path="jni"
	if [ $core = "snes9x" ] || [ $core = "snes9x_next" ] || [ $core = "genesis_plus_gx" ] || [ $core = "meteor" ]; then
		path="libretro/jni"
	fi
	build_libretro_generic_makefile $core $path
done

