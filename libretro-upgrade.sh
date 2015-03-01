#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

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

found_nothing=1

libretro_move_libretro_common() {
	if [ -f "$WORKDIR/libretro-sdk/file/config_file.c" ]; then
		found_nothing=""
		echo ""
		echo "=== Detected old libretro-sdk (now libretro-common)"
		if [ -d "$WORKDIR/libretro-common" ]; then
			echo "    libretro-common already exists"
			echo ""
			echo -n "    Would you like to delete libretro-sdk? [y/N] : "
			read user
			if [[ "$user" = "y" || "$user" == "Y" ]]; then
				echo "    Deleting libretro-sdk..."
				rm -rf "$WORKDIR/libretro-sdk"
			else
				echo "Retaining libretro-sdk at your request."
			fi
		else
			echo ""
			echo "    will move it"
			mv "$WORKDIR/libretro-sdk" "$WORKDIR/libretro-common"
		fi
	fi
}

libretro_bsnes_one_copy() {
	if [ -d "$WORKDIR/libretro-bsnes/perf" ]; then
		found_nothing=""
		echo ""
		echo "=== Detected bsnes duplicates"
		echo "    libretro-super no longer needs three copies of bsnes"
		echo ""
		echo -n "    Would you like to delete the extras? [y/N] : "
		read user
		if [[ "$user" = "y" || "$user" == "Y" ]]; then
			echo "    Deleting libretro-bsnes/balanced..."
			rm -rf "$WORKDIR/libretro-bsnes/balanced"
			echo "    Deleting libretro-bsnes/perf..."
			rm -rf "$WORKDIR/libretro-bsnes/perf"
		else
			echo "    Retaining bsnes duplicates at your request."
		fi
fi
}

libretro_devkit_mgit_dir_0="libretro-manifest"
libretro_devkit_mgit_dir_1="libretrodb"
libretro_devkit_mgit_dir_2="libretro-dat-pull"
libretro_devkit_mgit_dir_3="libretro-common"

libretro_move_devkit() {
	if [ -d "$WORKDIR/libretrodb" ]; then
		found_nothing=""
		if [ -d "$WORKDIR/libretro-devkit" ]; then
			echo ""
			echo "=== Detected multiple copies of libretro devkit"
			echo "    devkit has moved to a subdir, but you have old copies installed."
			echo ""
			echo -n "    Would you like to delete the extras? [y/N] : "
			read user
			if [[ "$user" = "y" || "$user" == "Y" ]]; then
				echo "    Removing old versions of devkit..."
				rm -rf "$WORKDIR/libretro-manifest"
				rm -rf "$WORKDIR/libretrodb"
				rm -rf "$WORKDIR/libretro-dat-pull"
				rm -rf "$WORKDIR/libretro-common"
			else
				echo "    Retaining devkit duplicates at your request."
			fi
		else
			echo ""
			echo "=== Detected devkit installed in working directory"
			echo "    Found in \"$WORKDIR\""
			echo "    Should be \"$WORKDIR/libretro-devkit\""
			echo ""
			echo "    will move it"
			mkdir -p "$WORKDIR/libretro-devkit"
			mv "$WORKDIR/libretro-manifest" "$WORKDIR/libretro-devkit"
			mv "$WORKDIR/libretrodb" "$WORKDIR/libretro-devkit"
			mv "$WORKDIR/libretro-dat-pull" "$WORKDIR/libretro-devkit"
			mv "$WORKDIR/libretro-common" "$WORKDIR/libretro-devkit"
		fi
	fi
}

if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		"$1"
		shift
	done
else
	libretro_move_libretro_common
	libretro_bsnes_one_copy
	libretro_move_devkit
fi
if [ -n "$found_nothing" ]; then
	echo "Nothing to upgrade."
fi

