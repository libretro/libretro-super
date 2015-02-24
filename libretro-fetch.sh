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


# TODO: Move all of these rules to their own file

libretro_bsnes_fetch_url="https://github.com/libretro/bsnes-libretro.git"
libretro_bsnes_name="bsnes/higan"

libretro_snes9x_fetch_url="https://github.com/libretro/snes9x.git"
libretro_snes9x_name="SNES9x"

libretro_snes9x_next_fetch_url="https://github.com/libretro/snes9x-next.git"
libretro_snes9x_next_name="SNES9x Next"

libretro_genesis_plus_gx_fetch_url="https://github.com/libretro/Genesis-Plus-GX.git"
libretro_genesis_plus_gx_name="Genesis Plus GX"

libretro_fb_alpha_fetch_url="https://github.com/libretro/fba-libretro.git"
libretro_fb_alpha_name="Final Burn Alpha"

libretro_vba_next_fetch_url="https://github.com/libretro/vba-next.git"
libretro_vba_next_name="VBA Next"

libretro_vbam_fetch_url="https://github.com/libretro/vbam-libretro.git"
libretro_vbam_name="VBA-M"

libretro_handy_fetch_url="https://github.com/libretro/libretro-handy.git"
libretro_handy_name="Handy"

libretro_bnes_fetch_url="https://github.com/libretro/bnes-libretro.git"
libretro_bnes_name="bnes/higan"

libretro_fceumm_fetch_url="https://github.com/libretro/libretro-fceumm.git"
libretro_fceumm_name="FCEUmm"

libretro_gambatte_fetch_url="https://github.com/libretro/gambatte-libretro.git"
libretro_gambatte_name="Gambatte"

libretro_meteor_fetch_url="https://github.com/libretro/meteor-libretro.git"
libretro_meteor_name="Meteor"

libretro_nxengine_fetch_url="https://github.com/libretro/nxengine-libretro.git"
libretro_nxengine_name="NXEngine"

libretro_prboom_fetch_url="https://github.com/libretro/libretro-prboom.git"
libretro_prboom_name="PrBoom"

libretro_stella_fetch_url="https://github.com/libretro/stella-libretro.git"
libretro_stella_name="Stella"

libretro_desmume_fetch_url="https://github.com/libretro/desmume.git"
libretro_desmume_name="DeSmuME"

libretro_quicknes_fetch_url="https://github.com/libretro/QuickNES_Core.git"
libretro_quicknes_name="QuickNES"

libretro_nestopia_fetch_url="https://github.com/libretro/nestopia.git"
libretro_nestopia_name="Nestopia"

libretro_tyrquake_fetch_url="https://github.com/libretro/tyrquake.git"
libretro_tyrquake_name="TyrQuake"

libretro_pcsx_rearmed_fetch_url="https://github.com/libretro/pcsx_rearmed.git"
libretro_pcsx_rearmed_name="PCSX ReARMed"

libretro_mednafen_gba_fetch_url="https://github.com/libretro/beetle-gba-libretro.git"
libretro_mednafen_gba_name="Mednafen/Beetle GBA"

libretro_mednafen_lynx_fetch_url="https://github.com/libretro/beetle-lynx-libretro.git"
libretro_mednafen_lynx_name="Mednafen/Beetle Lynx"

libretro_mednafen_ngp_fetch_url="https://github.com/libretro/beetle-ngp-libretro.git"
libretro_mednafen_ngp_name="Mednafen/Beetle NeoPop"

libretro_mednafen_pce_fast_fetch_url="https://github.com/libretro/beetle-pce-fast-libretro.git"
libretro_mednafen_pce_fast_name="Mednafen/Beetle PCE FAST"

libretro_mednafen_supergrafx_fetch_url="https://github.com/libretro/beetle-supergrafx-libretro.git"
libretro_mednafen_supergrafx_name="Mednafen/Beetle SuperGrafx"

libretro_mednafen_psx_fetch_url="https://github.com/libretro/mednafen-psx-libretro.git"
libretro_mednafen_psx_name="Mednafen PSX"

libretro_mednafen_pcfx_fetch_url="https://github.com/libretro/beetle-pcfx-libretro.git"
libretro_mednafen_pcfx_name="Mednafen/Beetle PC-FX"

libretro_mednafen_snes_fetch_url="https://github.com/libretro/beetle-bsnes-libretro.git"
libretro_mednafen_snes_name="Mednafen/Beetle bsnes"

libretro_mednafen_vb_fetch_url="https://github.com/libretro/beetle-vb-libretro.git"
libretro_mednafen_vb_name="Mednafen/Beetle VB"

libretro_mednafen_wswan_fetch_url="https://github.com/libretro/beetle-wswan-libretro.git"
libretro_mednafen_wswan_name="Mednafen/Beetle WonderSwan"

libretro_scummvm_fetch_url="https://github.com/libretro/scummvm.git"
libretro_scummvm_name="ScummVM"

libretro_yabause_fetch_url="https://github.com/libretro/yabause.git"
libretro_yabause_name="Yabause"

libretro_dosbox_fetch_url="https://github.com/libretro/dosbox-libretro.git"
libretro_dosbox_name="DOSBox"

libretro_virtualjaguar_fetch_url="https://github.com/libretro/virtualjaguar-libretro.git"
libretro_virtualjaguar_name="Virtual Jaguar"

libretro_mame078_fetch_url="https://github.com/libretro/mame2003-libretro.git"
libretro_mame078_name="MAME 2003 (0.78)"

libretro_mame139_fetch_url="https://github.com/libretro/mame2010-libretro.git"
libretro_mame139_name="MAME 2010 (0.139)"

libretro_mame_fetch_url="https://github.com/libretro/mame.git"
libretro_mame_name="MAME (git)"

libretro_ffmpeg_fetch_url="https://github.com/libretro/FFmpeg.git"
libretro_ffmpeg_name="FFmpeg"

libretro_bsnes_cplusplus98_fetch_url="https://github.com/libretro/bsnes-libretro-cplusplus98.git"
libretro_bsnes_cplusplus98_name="bsnes C++98 (v0.85)"

libretro_bsnes_mercury_fetch_url="https://github.com/libretro/bsnes-mercury.git"
libretro_bsnes_mercury_name="bsnes-mercury"

libretro_picodrive_fetch_url="https://github.com/libretro/picodrive.git"
libretro_picodrive_name="Picodrive"
libretro_picodrive_git_submodules="1"
libretro_picodrive_git_submodules_update="1"

libretro_tgbdual_fetch_url="https://github.com/libretro/tgbdual-libretro.git"
libretro_tgbdual_name="TGB Dual"

libretro_mupen64plus_fetch_url="https://github.com/libretro/mupen64plus-libretro.git"
libretro_mupen64plus_name="Mupen64Plus"

libretro_dinothawr_fetch_url="https://github.com/libretro/Dinothawr.git"
libretro_dinothawr_name="Dinothawr"

libretro_uae_fetch_url="https://github.com/libretro/libretro-uae.git"
libretro_uae_name="UAE"

libretro_3dengine_fetch_url="https://github.com/libretro/libretro-3dengine.git"
libretro_3dengine_name="3DEngine"

libretro_remotejoy_fetch_url="https://github.com/libretro/libretro-remotejoy.git"
libretro_remotejoy_name="RemoteJoy"

libretro_bluemsx_fetch_url="https://github.com/libretro/blueMSX-libretro.git"
libretro_bluemsx_name="blueMSX"

libretro_fmsx_fetch_url="https://github.com/libretro/fmsx-libretro.git"
libretro_fmsx_name="fMSX"

libretro_2048_fetch_url="https://github.com/libretro/libretro-2048.git"

libretro_vecx_fetch_url="https://github.com/libretro/libretro-vecx.git"

libretro_ppsspp_fetch_url="https://github.com/libretro/ppsspp.git"
libretro_ppsspp_name="PPSSPP"
libretro_ppsspp_git_submodules="1"
libretro_ppsspp_git_submodules_update="1"

libretro_prosystem_fetch_url="https://github.com/libretro/prosystem-libretro.git"
libretro_prosystem_name="ProSystem"

libretro_o2em_fetch_url="https://github.com/libretro/libretro-o2em.git"
libretro_o2em_name="O2EM"

libretro_4do_fetch_url="https://github.com/libretro/4do-libretro.git"
libretro_4do_name="4DO"

libretro_catsfc_fetch_url="https://github.com/libretro/CATSFC-libretro.git"
libretro_catsfc_name="CATSFC"

libretro_stonesoup_fetch_url="https://github.com/libretro/crawl-ref.git"
libretro_stonesoup_name="Dungeon Crawl Stone Soup"
libretro_stonesoup_git_submodules="1"

libretro_hatari_fetch_url="https://github.com/libretro/hatari.git"
libretro_hatari_name="Hatari"

libretro_tempgba_fetch_url="https://github.com/libretro/TempGBA-libretro.git"
libretro_tempgba_name="TempGBA"

libretro_gpsp_fetch_url="https://github.com/libretro/gpsp.git"
libretro_gpsp_name="gpSP"

libretro_emux_fetch_url="https://github.com/libretro/emux.git"
libretro_emux_name="Emux"

libretro_fuse_fetch_url="https://github.com/libretro/fuse-libretro.git"
libretro_fuse_name="Fuse"


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
