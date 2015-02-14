#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

# BSDs don't have readlink -f
read_link()
{
	TARGET_FILE="${1}"
	cd "`dirname "${TARGET_FILE}"`"
	TARGET_FILE="`basename "${TARGET_FILE}"`"

	while [ -L "${TARGET_FILE}" ]; do
		TARGET_FILE="`readlink "${TARGET_FILE}"`"
		cd "`dirname "${TARGET_FILE}"`"
		TARGET_FILE="`basename "${TARGET_FILE}"`"
	done

	PHYS_DIR="`pwd -P`"
	RESULT="${PHYS_DIR}/${TARGET_FILE}"
	echo ${RESULT}
}
SCRIPT="`read_link "$0"`"
BASE_DIR="`dirname "${SCRIPT}"`"

. ${BASE_DIR}/libretro-config.sh
. $BASE_DIR/iKarith-super/fetch-rules.sh	# will rename this dir later

WORKDIR=$(pwd)

DATESTAMP_FMT="%Y-%m-%d_%H:%M:%S"

log_verbose() {
	if [ -n "${VERBOSE}" ]; then
		echo "$(date -u +${DATESTAMP_FMT}):${@}"
	fi
}


# fetch_git_submodules <repository> <local directory>
# Clones or pulls updates from a git repository (and its submodules, if any)
# into a local directory
fetch_git_submodules() {
	fetch_dir="${WORKDIR}/${2}"
	if [ -n "${3}" ]; then
		echo "=== Fetching ${3} ==="
	fi
	if [ -d "${fetch_dir}/.git" ]; then
		cd "${fetch_dir}"
		log_verbose "${fetch_dir}:git pull"
		git pull
		log_verbose "${fetch_dir}:git submodule foreach git pull origin master"
		git submodule foreach git pull origin master
	else
		log_verbose "git clone \"${1}\" \"${fetch_dir}\""
		git clone "${1}" "${fetch_dir}"
		cd "${fetch_dir}"
		log_verbose "${fetch_dir}:git submodule update --init"
		git submodule update --init
	fi
	if [ -n "${3}" ]; then
		echo "=== Fetched ==="
	fi
}

# fetch_git_submodules_no_update <repository> <local directory>
# Clones a repository (and its submodules, if any) into a local directory,
# updates only the main repo on update.
#
# Basically if the core has a ton of external dependencies, you may not want
# them updated automatically
fetch_git_submodules_no_update() {
	fetch_dir="${WORKDIR}/${2}"
	if [ -n "${3}" ]; then
		echo "=== Fetching ${3} ==="
	fi
	if [ -d "${fetch_dir}/.git" ]; then
		cd "${fetch_dir}"
		log_verbose "${fetch_dir}:git pull"
		git pull
	else
		log_verbose "git clone \"${1}\" \"${fetch_dir}\""
		git clone "${1}" "${fetch_dir}"
		cd "${fetch_dir}"
		log_verbose "${fetch_dir}:git submodule update --init"
		git submodule update --init
	fi
	if [ -n "${3}" ]; then
		echo "=== Fetched ==="
	fi
}

# Keep three copies so we don't have to rebuild stuff all the time.
fetch_project_bsnes()
{
	fetch_git "${1}" "${2}"
	fetch_git "${WORKDIR}/${2}" "${2}/perf"
	fetch_git "${WORKDIR}/${2}" "${2}/balanced"
}


fetch_retroarch() {
	fetch_git "https://github.com/libretro/RetroArch.git" "retroarch"
	fetch_git "https://github.com/libretro/common-shaders.git" "retroarch/media/shaders_cg"
	fetch_git "https://github.com/libretro/common-overlays.git" "retroarch/media/overlays"
	fetch_git "https://github.com/libretro/retroarch-assets.git" "retroarch/media/assets"
	fetch_git "https://github.com/libretro/retroarch-joypad-autoconfig.git" "retroarch/media/autoconfig"
	fetch_git "https://github.com/libretro/libretro-database.git" "retroarch/media/libretrodb"
}

fetch_tools() {
	fetch_git "https://github.com/libretro/libretro-manifest.git" "libretro-manifest"
	fetch_git "https://github.com/libretro/libretrodb.git" "libretrodb"
	fetch_git "https://github.com/libretro/libretro-dat-pull.git" "libretro-dat-pull"
}


fetch_libretro_bsnes() {
	fetch_project_bsnes "https://github.com/libretro/bsnes-libretro.git" "libretro-bsnes"
}

fetch_libretro_snes9x() {
	fetch_git "https://github.com/libretro/snes9x.git" "libretro-snes9x"
}

fetch_libretro_snes9x_next() {
	fetch_git "https://github.com/libretro/snes9x-next.git" "libretro-snes9x_next"
}

fetch_libretro_genesis_plus_gx() {
	fetch_git "https://github.com/libretro/Genesis-Plus-GX.git" "libretro-genesis_plus_gx"
}

fetch_libretro_fb_alpha() {
	fetch_git "https://github.com/libretro/fba-libretro.git" "libretro-fb_alpha"
}

fetch_libretro_vba_next() {
	fetch_git "https://github.com/libretro/vba-next.git" "libretro-vba_next"
}

fetch_libretro_vbam() {
	fetch_git "https://github.com/libretro/vbam-libretro.git" "libretro-vbam"
}

fetch_libretro_handy() {
	fetch_git "https://github.com/libretro/libretro-handy.git" "libretro-handy"
}

fetch_libretro_bnes() {
	fetch_git "https://github.com/libretro/bnes-libretro.git" "libretro-bnes"
}

fetch_libretro_fceumm() {
	fetch_git "https://github.com/libretro/libretro-fceumm.git" "libretro-fceumm"
}

fetch_libretro_gambatte() {
	fetch_git "https://github.com/libretro/gambatte-libretro.git" "libretro-gambatte"
}

fetch_libretro_meteor() {
	fetch_git "https://github.com/libretro/meteor-libretro.git" "libretro-meteor"
}

fetch_libretro_nxengine() {
	fetch_git "https://github.com/libretro/nxengine-libretro.git" "libretro-nxengine"
}

fetch_libretro_prboom() {
	fetch_git "https://github.com/libretro/libretro-prboom.git" "libretro-prboom"
}

fetch_libretro_stella() {
	fetch_git "https://github.com/libretro/stella-libretro.git" "libretro-stella"
}

fetch_libretro_desmume() {
	fetch_git "https://github.com/libretro/desmume.git" "libretro-desmume"
}

fetch_libretro_quicknes() {
	fetch_git "https://github.com/libretro/QuickNES_Core.git" "libretro-quicknes"
}

fetch_libretro_nestopia() {
	fetch_git "https://github.com/libretro/nestopia.git" "libretro-nestopia"
}

fetch_libretro_tyrquake() {
	fetch_git "https://github.com/libretro/tyrquake.git" "libretro-tyrquake"
}

fetch_libretro_pcsx_rearmed() {
	fetch_git "https://github.com/libretro/pcsx_rearmed.git" "libretro-pcsx_rearmed"
}

fetch_libretro_mednafen_gba() {
	fetch_git "https://github.com/libretro/beetle-gba-libretro.git" "libretro-mednafen_gba"
}

fetch_libretro_mednafen_lynx() {
	fetch_git "https://github.com/libretro/beetle-lynx-libretro.git" "libretro-mednafen_lynx"
}

fetch_libretro_mednafen_ngp() {
	fetch_git "https://github.com/libretro/beetle-ngp-libretro.git" "libretro-mednafen_ngp"
}

fetch_libretro_mednafen_pce_fast() {
	fetch_git "https://github.com/libretro/beetle-pce-fast-libretro.git" "libretro-mednafen_pce_fast"
}

fetch_libretro_mednafen_supergrafx() {
	fetch_git "https://github.com/libretro/beetle-supergrafx-libretro.git" "libretro-mednafen_supergrafx"
}

fetch_libretro_mednafen_psx() {
	fetch_git "https://github.com/libretro/mednafen-psx-libretro.git" "libretro-mednafen_psx"
}

fetch_libretro_mednafen_pcfx() {
	fetch_git "https://github.com/libretro/beetle-pcfx-libretro.git" "libretro-mednafen_pcfx"
}

fetch_libretro_mednafen_snes() {
	fetch_git "https://github.com/libretro/beetle-bsnes-libretro.git" "libretro-mednafen_snes"
}

fetch_libretro_mednafen_vb() {
	fetch_git "https://github.com/libretro/beetle-vb-libretro.git" "libretro-mednafen_vb"
}

fetch_libretro_mednafen_wswan() {
	fetch_git "https://github.com/libretro/beetle-wswan-libretro.git" "libretro-mednafen_wswan"
}

fetch_libretro_scummvm() {
	fetch_git "https://github.com/libretro/scummvm.git" "libretro-scummvm"
}

fetch_libretro_yabause() {
	fetch_git "https://github.com/libretro/yabause.git" "libretro-yabause"
}

fetch_libretro_dosbox() {
	fetch_git "https://github.com/libretro/dosbox-libretro.git" "libretro-dosbox"
}

fetch_libretro_virtualjaguar() {
	fetch_git "https://github.com/libretro/virtualjaguar-libretro.git" "libretro-virtualjaguar"
}

fetch_libretro_mame078() {
	fetch_git "https://github.com/libretro/mame2003-libretro.git" "libretro-mame078"
}

fetch_libretro_mame139() {
	fetch_git "https://github.com/libretro/mame2010-libretro.git" "libretro-mame139"
}

fetch_libretro_mame() {
	fetch_git "https://github.com/libretro/mame.git" "libretro-mame"
}

fetch_libretro_ffmpeg() {
	fetch_git "https://github.com/libretro/FFmpeg.git" "libretro-ffmpeg" "libretro/FFmpeg"
}

fetch_libretro_bsnes_cplusplus98() {
	fetch_git "https://github.com/libretro/bsnes-libretro-cplusplus98.git" "libretro-bsnes_cplusplus98"
}

fetch_libretro_bsnes_mercury() {
	fetch_git "https://github.com/libretro/bsnes-mercury.git" "libretro-bsnes_mercury"
}

fetch_libretro_picodrive() {
	fetch_git_submodules "https://github.com/libretro/picodrive.git" "libretro-picodrive" "libretro/picodrive"
}

fetch_libretro_tgbdual() {
	fetch_git "https://github.com/libretro/tgbdual-libretro.git" "libretro-tgbdual"
}

fetch_libretro_mupen64plus() {
	fetch_git "https://github.com/libretro/mupen64plus-libretro.git" "libretro-mupen64plus"
}

fetch_libretro_dinothawr() {
	fetch_git "https://github.com/libretro/Dinothawr.git" "libretro-dinothawr"
}

fetch_libretro_uae() {
	fetch_git "https://github.com/libretro/libretro-uae.git" "libretro-uae"
}

fetch_libretro_3dengine() {
	fetch_git "https://github.com/libretro/libretro-3dengine.git" "libretro-3dengine"
}

fetch_libretro_remotejoy() {
	fetch_git "https://github.com/libretro/libretro-remotejoy.git" "libretro-remotejoy"
}

fetch_libretro_bluemsx() {
	fetch_git "https://github.com/libretro/blueMSX-libretro.git" "libretro-bluemsx"
}

fetch_libretro_fmsx() {
	fetch_git "https://github.com/libretro/fmsx-libretro.git" "libretro-fmsx"
}

fetch_libretro_2048() {
	fetch_git "https://github.com/libretro/libretro-2048.git" "libretro-2048"
}

fetch_libretro_vecx() {
	fetch_git "https://github.com/libretro/libretro-vecx.git" "libretro-vecx"
}

fetch_libretro_ppsspp() {
	fetch_git_submodules "https://github.com/libretro/ppsspp.git" "libretro-ppsspp" "libretro/ppsspp"
}

fetch_libretro_prosystem() {
	fetch_git "https://github.com/libretro/prosystem-libretro.git" "libretro-prosystem"
}

fetch_libretro_o2em() {
	fetch_git "https://github.com/libretro/libretro-o2em.git" "libretro-o2em"
}

fetch_libretro_4do() {
	fetch_git "https://github.com/libretro/4do-libretro.git" "libretro-4do"
}

fetch_libretro_catsfc() {
	fetch_git "https://github.com/libretro/CATSFC-libretro.git" "libretro-catsfc"
}

fetch_libretro_stonesoup() {
	fetch_git_submodules_no_update "https://github.com/libretro/crawl-ref.git" "libretro-stonesoup" "libretro/DungeonCrawler StoneSoup"
}

fetch_libretro_hatari() {
	fetch_git "https://github.com/libretro/hatari.git" "libretro-hatari"
}

fetch_libretro_tempgba() {
	fetch_git "https://github.com/libretro/TempGBA-libretro.git" "libretro-tempgba"
}

fetch_libretro_gpsp() {
	fetch_git "https://github.com/libretro/gpsp.git" "libretro-gpsp"
}

fetch_libretro_emux() {
	fetch_git "https://github.com/libretro/emux.git" "libretro-emux"
}

fetch_libretro_sdk() {
	fetch_git "https://github.com/libretro/libretro-sdk.git" "libretro-sdk"
}


if [ -n "${1}" ]; then
	while [ -n "${1}" ]; do
		"${1}"
		shift
	done
else
	fetch_retroarch
	fetch_tools
	fetch_libretro_bsnes
	fetch_libretro_snes9x
	fetch_libretro_snes9x_next
	fetch_libretro_genesis_plus_gx
	fetch_libretro_fb_alpha
	fetch_libretro_vba_next
	fetch_libretro_vbam
	fetch_libretro_handy
	fetch_libretro_bnes
	fetch_libretro_fceumm
	fetch_libretro_gambatte
	fetch_libretro_meteor
	fetch_libretro_nxengine
	fetch_libretro_prboom
	fetch_libretro_stella
	fetch_libretro_desmume
	fetch_libretro_quicknes
	fetch_libretro_nestopia
	fetch_libretro_tyrquake
	fetch_libretro_pcsx_rearmed
	fetch_libretro_mednafen_gba
	fetch_libretro_mednafen_lynx
	fetch_libretro_mednafen_ngp
	fetch_libretro_mednafen_pce_fast
	fetch_libretro_mednafen_supergrafx
	fetch_libretro_mednafen_psx
	fetch_libretro_mednafen_pcfx
	fetch_libretro_mednafen_snes
	fetch_libretro_mednafen_vb
	fetch_libretro_mednafen_wswan
	fetch_libretro_scummvm
	fetch_libretro_yabause
	fetch_libretro_dosbox
	fetch_libretro_virtualjaguar
	fetch_libretro_mame078
	fetch_libretro_mame139
	fetch_libretro_mame
	fetch_libretro_ffmpeg
	fetch_libretro_bsnes_cplusplus98
	fetch_libretro_bsnes_mercury
	fetch_libretro_picodrive
	fetch_libretro_tgbdual
	fetch_libretro_mupen64plus
	fetch_libretro_dinothawr
	fetch_libretro_uae
	fetch_libretro_3dengine
	fetch_libretro_remotejoy
	fetch_libretro_bluemsx
	fetch_libretro_fmsx
	fetch_libretro_2048
	fetch_libretro_vecx
	fetch_libretro_ppsspp
	fetch_libretro_prosystem
	fetch_libretro_o2em
	fetch_libretro_4do
	fetch_libretro_catsfc
	fetch_libretro_stonesoup
	fetch_libretro_hatari
	fetch_libretro_tempgba
	fetch_libretro_gpsp
	fetch_libretro_emux
	fetch_libretro_sdk
fi

