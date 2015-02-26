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

. "$BASE_DIR/libretro-config.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"

# Rules for fetching cores are in this file:
. "$BASE_DIR/core-rules.sh"

# libretro_fetch_core: Download the given core using its fetch rules
#
# $1	Name of the core to fetch
libretro_fetch_core() {
	eval "core_name=\$libretro_${1}_name"
	[ -z "$core_name" ] && core_name="$1"
	echo "=== $core_name"

	eval "core_fetch_rule=\$libretro_${1}_fetch_rule"
	[ -z "$core_fetch_rule" ] && core_fetch_rule=fetch_git

	eval "core_dir=\$libretro_${1}_dir"
	[ -z "$core_dir" ] && core_dir="libretro-$1"

	case "$core_fetch_rule" in
		fetch_git)
			eval "core_fetch_url=\$libretro_${1}_fetch_url"
			if [ -z "$core_fetch_url" ]; then
				echo "libretro_fetch_core:No URL set to fetch $1 via git."
				exit 1
			fi

			eval "core_git_submodules=\$libretro_${1}_git_submodules"
			eval "core_git_submodules_update=\$libretro_${1}_git_submodules_update"

			echo "Fetching ${1}..."
			$core_fetch_rule "$core_fetch_url" "$core_dir" "" $core_git_submodules $core_git_submodules_update
			;;
		*)
			echo "libretro_fetch_core:Unknown fetch rule for $1: \"$core_fetch_rule\"."
			exit 1
			;;
	esac
}

fetch_retroarch() {
	echo "=== Fetching RetroArch ==="
	fetch_git "https://github.com/libretro/RetroArch.git" "retroarch" ""
	fetch_git "https://github.com/libretro/common-shaders.git" "retroarch/media/shaders_cg" ""
	fetch_git "https://github.com/libretro/common-overlays.git" "retroarch/media/overlays" ""
	fetch_git "https://github.com/libretro/retroarch-assets.git" "retroarch/media/assets" ""
	fetch_git "https://github.com/libretro/retroarch-joypad-autoconfig.git" "retroarch/media/autoconfig" ""
	fetch_git "https://github.com/libretro/libretro-database.git" "retroarch/media/libretrodb" ""
}

fetch_devkit() {
	fetch_git "https://github.com/libretro/libretro-manifest.git" "libretro-manifest" "libretro/libretro-manifest"
	fetch_git "https://github.com/libretro/libretrodb.git" "libretrodb" "libretro/libretrodb"
	fetch_git "https://github.com/libretro/libretro-dat-pull.git" "libretro-dat-pull" "libretro/libretro-dat-pull"
	fetch_git "https://github.com/libretro/libretro-common.git" "libretro-common" "libretro/common"
}


if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		case "$1" in
			fetch_libretro_*)
				# "Old"-style
				$1
				;;
			*)
				# New style (just cores for now)
				libretro_fetch_core $1
				;;
		esac
		shift
	done
else
	fetch_retroarch
	fetch_devkit

	libretro_fetch_core bsnes
	libretro_fetch_core snes9x
	libretro_fetch_core snes9x_next
	libretro_fetch_core genesis_plus_gx
	libretro_fetch_core fb_alpha
	libretro_fetch_core vba_next
	libretro_fetch_core vbam
	libretro_fetch_core handy
	libretro_fetch_core bnes
	libretro_fetch_core fceumm
	libretro_fetch_core gambatte
	libretro_fetch_core meteor
	libretro_fetch_core nxengine
	libretro_fetch_core prboom
	libretro_fetch_core stella
	libretro_fetch_core desmume
	libretro_fetch_core quicknes
	libretro_fetch_core nestopia
	libretro_fetch_core tyrquake
	libretro_fetch_core pcsx_rearmed
	libretro_fetch_core mednafen_gba
	libretro_fetch_core mednafen_lynx
	libretro_fetch_core mednafen_ngp
	libretro_fetch_core mednafen_pce_fast
	libretro_fetch_core mednafen_supergrafx
	libretro_fetch_core mednafen_psx
	libretro_fetch_core mednafen_pcfx
	libretro_fetch_core mednafen_snes
	libretro_fetch_core mednafen_vb
	libretro_fetch_core mednafen_wswan
	libretro_fetch_core scummvm
	libretro_fetch_core yabause
	libretro_fetch_core dosbox
	libretro_fetch_core virtualjaguar
	libretro_fetch_core mame078
	libretro_fetch_core mame139
	libretro_fetch_core mame
	libretro_fetch_core ffmpeg
	libretro_fetch_core bsnes_cplusplus98
	libretro_fetch_core bsnes_mercury
	libretro_fetch_core picodrive
	libretro_fetch_core tgbdual
	libretro_fetch_core mupen64plus
	libretro_fetch_core dinothawr
	libretro_fetch_core uae
	libretro_fetch_core 3dengine
	libretro_fetch_core remotejoy
	libretro_fetch_core bluemsx
	libretro_fetch_core fmsx
	libretro_fetch_core 2048
	libretro_fetch_core vecx
	libretro_fetch_core ppsspp
	libretro_fetch_core prosystem
	libretro_fetch_core o2em
	libretro_fetch_core 4do
	libretro_fetch_core catsfc
	libretro_fetch_core stonesoup
	libretro_fetch_core hatari
	libretro_fetch_core tempgba
	libretro_fetch_core gpsp
	libretro_fetch_core emux
	libretro_fetch_core fuse
fi
