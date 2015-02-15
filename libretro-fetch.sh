#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR=$(pwd)

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
else
	if [[ "$0" != /* ]]; then
		# Make the path absolute
		BASE_DIR="$WORKDIR/$BASE_DIR"
	fi
fi

. $BASE_DIR/libretro-config.sh
. $BASE_DIR/iKarith-super/fetch-rules.sh	# will rename this dir later


# Keep three copies so we don't have to rebuild stuff all the time.
# FIXME: If you need 3 copies of source to compile 3 sets of objects, you're
#        doing it wrong.  We should fix this.
fetch_project_bsnes()
{
	echo "=== Fetching ${3} ==="
	fetch_git "${1}" "${2}" ""
	fetch_git "${WORKDIR}/${2}" "${2}/perf" ""
	fetch_git "${WORKDIR}/${2}" "${2}/balanced" ""
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

fetch_tools() {
	fetch_git "https://github.com/libretro/libretro-manifest.git" "libretro-manifest" "libretro/libretro-manifest"
	fetch_git "https://github.com/libretro/libretrodb.git" "libretrodb" "libretro/libretrodb"
	fetch_git "https://github.com/libretro/libretro-dat-pull.git" "libretro-dat-pull" "libretro/libretro-dat-pull"
}


fetch_libretro_bsnes() {
	fetch_project_bsnes "https://github.com/libretro/bsnes-libretro.git" "libretro-bsnes" "libretro/bSNES"
}

fetch_libretro_snes9x() {
	fetch_git "https://github.com/libretro/snes9x.git" "libretro-snes9x" "libretro/SNES9x"
}

fetch_libretro_snes9x_next() {
	fetch_git "https://github.com/libretro/snes9x-next.git" "libretro-snes9x_next" "libretro/SNES9x-Next"
}

fetch_libretro_genesis_plus_gx() {
	fetch_git "https://github.com/libretro/Genesis-Plus-GX.git" "libretro-genesis_plus_gx" "libretro/Genplus GX"
}

fetch_libretro_fb_alpha() {
	fetch_git "https://github.com/libretro/fba-libretro.git" "libretro-fb_alpha" "libretro/FBA"
}

fetch_libretro_vba_next() {
	fetch_git "https://github.com/libretro/vba-next.git" "libretro-vba_next" "libretro/VBA Next"
}

fetch_libretro_vbam() {
	fetch_git "https://github.com/libretro/vbam-libretro.git" "libretro-vbam" "libretro/VBA-M"
}

fetch_libretro_handy() {
	fetch_git "https://github.com/libretro/libretro-handy.git" "libretro-handy" "libretro/Handy"
}

fetch_libretro_bnes() {
	fetch_git "https://github.com/libretro/bnes-libretro.git" "libretro-bnes" "libretro/bNES"
}

fetch_libretro_fceumm() {
	fetch_git "https://github.com/libretro/libretro-fceumm.git" "libretro-fceumm" "libretro/FCEUmm"
}

fetch_libretro_gambatte() {
	fetch_git "https://github.com/libretro/gambatte-libretro.git" "libretro-gambatte" "libretro/Gambatte"
}

fetch_libretro_meteor() {
	fetch_git "https://github.com/libretro/meteor-libretro.git" "libretro-meteor" "libretro/Meteor"
}

fetch_libretro_nxengine() {
	fetch_git "https://github.com/libretro/nxengine-libretro.git" "libretro-nxengine" "libretro/NX"
}

fetch_libretro_prboom() {
	fetch_git "https://github.com/libretro/libretro-prboom.git" "libretro-prboom" "libretro/PRBoom"
}

fetch_libretro_stella() {
	fetch_git "https://github.com/libretro/stella-libretro.git" "libretro-stella" "libretro/Stella"
}

fetch_libretro_desmume() {
	fetch_git "https://github.com/libretro/desmume.git" "libretro-desmume" "libretro/Desmume"
}

fetch_libretro_quicknes() {
	fetch_git "https://github.com/libretro/QuickNES_Core.git" "libretro-quicknes" "libretro/QuickNES"
}

fetch_libretro_nestopia() {
	fetch_git "https://github.com/libretro/nestopia.git" "libretro-nestopia" "libretro/Nestopia"
}

fetch_libretro_tyrquake() {
	fetch_git "https://github.com/libretro/tyrquake.git" "libretro-tyrquake" "libretro/tyrquake"
}

fetch_libretro_pcsx_rearmed() {
	fetch_git "https://github.com/libretro/pcsx_rearmed.git" "libretro-pcsx_rearmed" "libretro/pcsx_rearmed"
}

fetch_libretro_mednafen_gba() {
	fetch_git "https://github.com/libretro/beetle-gba-libretro.git" "libretro-mednafen_gba" "libretro/Beetle GBA"
}

fetch_libretro_mednafen_lynx() {
	fetch_git "https://github.com/libretro/beetle-lynx-libretro.git" "libretro-mednafen_lynx" "libretro/Beetle Lynx"
}

fetch_libretro_mednafen_ngp() {
	fetch_git "https://github.com/libretro/beetle-ngp-libretro.git" "libretro-mednafen_ngp" "libretro/Beetle NGP"
}

fetch_libretro_mednafen_pce_fast() {
	fetch_git "https://github.com/libretro/beetle-pce-fast-libretro.git" "libretro-mednafen_pce_fast" "libretro/Beetle PCE Fast"
}

fetch_libretro_mednafen_supergrafx() {
	fetch_git "https://github.com/libretro/beetle-supergrafx-libretro.git" "libretro-mednafen_supergrafx" "libretro/Beetle SuperGrafx"
}

fetch_libretro_mednafen_psx() {
	fetch_git "https://github.com/libretro/mednafen-psx-libretro.git" "libretro-mednafen_psx" "libretro/Mednafen PSX"
}

fetch_libretro_mednafen_pcfx() {
	fetch_git "https://github.com/libretro/beetle-pcfx-libretro.git" "libretro-mednafen_pcfx" "libretro/Beetle PCFX"
}

fetch_libretro_mednafen_snes() {
	fetch_git "https://github.com/libretro/beetle-bsnes-libretro.git" "libretro-mednafen_snes" "libretro/Beetle bSNES"
}

fetch_libretro_mednafen_vb() {
	fetch_git "https://github.com/libretro/beetle-vb-libretro.git" "libretro-mednafen_vb" "libretro/Beetle VB"
}

fetch_libretro_mednafen_wswan() {
	fetch_git "https://github.com/libretro/beetle-wswan-libretro.git" "libretro-mednafen_wswan" "libretro/Beetle WSwan"
}

fetch_libretro_scummvm() {
	fetch_git "https://github.com/libretro/scummvm.git" "libretro-scummvm" "libretro/scummvm"
}

fetch_libretro_yabause() {
	fetch_git "https://github.com/libretro/yabause.git" "libretro-yabause" "libretro/yabause"
}

fetch_libretro_dosbox() {
	fetch_git "https://github.com/libretro/dosbox-libretro.git" "libretro-dosbox" "libretro/dosbox"
}

fetch_libretro_virtualjaguar() {
	fetch_git "https://github.com/libretro/virtualjaguar-libretro.git" "libretro-virtualjaguar" "libretro/virtualjaguar"
}

fetch_libretro_mame078() {
	fetch_git "https://github.com/libretro/mame2003-libretro.git" "libretro-mame078" "libretro/mame078"
}

fetch_libretro_mame139() {
	fetch_git "https://github.com/libretro/mame2010-libretro.git" "libretro-mame139" "libretro/mame139"
}

fetch_libretro_mame() {
	fetch_git "https://github.com/libretro/mame.git" "libretro-mame" "libretro/mame"
}

fetch_libretro_ffmpeg() {
	fetch_git "https://github.com/libretro/FFmpeg.git" "libretro-ffmpeg" "libretro/FFmpeg"
}

fetch_libretro_bsnes_cplusplus98() {
	fetch_git "https://github.com/libretro/bsnes-libretro-cplusplus98.git" "libretro-bsnes_cplusplus98" "libretro/bsnes-cplusplus98"
}

fetch_libretro_bsnes_mercury() {
	fetch_git "https://github.com/libretro/bsnes-mercury.git" "libretro-bsnes_mercury" "libretro/bsnes-mercury"
}

fetch_libretro_picodrive() {
	fetch_git "https://github.com/libretro/picodrive.git" "libretro-picodrive" "libretro/picodrive" "1" "1"
}

fetch_libretro_tgbdual() {
	fetch_git "https://github.com/libretro/tgbdual-libretro.git" "libretro-tgbdual" "libretro/tgbdual"
}

fetch_libretro_mupen64plus() {
	fetch_git "https://github.com/libretro/mupen64plus-libretro.git" "libretro-mupen64plus" "libretro/mupen64plus"
}

fetch_libretro_dinothawr() {
	fetch_git "https://github.com/libretro/Dinothawr.git" "libretro-dinothawr" "libretro/Dinothawr"
}

fetch_libretro_uae() {
	fetch_git "https://github.com/libretro/libretro-uae.git" "libretro-uae" "libretro/UAE"
}

fetch_libretro_3dengine() {
	fetch_git "https://github.com/libretro/libretro-3dengine.git" "libretro-3dengine" "libretro/3DEngine"
}

fetch_libretro_remotejoy() {
	fetch_git "https://github.com/libretro/libretro-remotejoy.git" "libretro-remotejoy" "libretro/RemoteJoy"
}

fetch_libretro_bluemsx() {
	fetch_git "https://github.com/libretro/blueMSX-libretro.git" "libretro-bluemsx" "libretro/blueMSX"
}

fetch_libretro_fmsx() {
	fetch_git "https://github.com/libretro/fmsx-libretro.git" "libretro-fmsx" "libretro/fmsx"
}

fetch_libretro_2048() {
	fetch_git "https://github.com/libretro/libretro-2048.git" "libretro-2048" "libretro/2048"
}

fetch_libretro_vecx() {
	fetch_git "https://github.com/libretro/libretro-vecx.git" "libretro-vecx" "libretro/vecx"
}

fetch_libretro_ppsspp() {
	fetch_git "https://github.com/libretro/ppsspp.git" "libretro-ppsspp" "libretro/ppsspp" "1" "1"
}

fetch_libretro_prosystem() {
	fetch_git "https://github.com/libretro/prosystem-libretro.git" "libretro-prosystem" "libretro/prosystem"
}

fetch_libretro_o2em() {
	fetch_git "https://github.com/libretro/libretro-o2em.git" "libretro-o2em" "libretro/o2em"
}

fetch_libretro_4do() {
	fetch_git "https://github.com/libretro/4do-libretro.git" "libretro-4do" "libretro/4do"
}

fetch_libretro_catsfc() {
	fetch_git "https://github.com/libretro/CATSFC-libretro.git" "libretro-catsfc" "libretro/CATSFC"
}

fetch_libretro_stonesoup() {
	fetch_git "https://github.com/libretro/crawl-ref.git" "libretro-stonesoup" "libretro/DungeonCrawler StoneSoup" "1" ""
}

fetch_libretro_hatari() {
	fetch_git "https://github.com/libretro/hatari.git" "libretro-hatari" "libretro/hatari"
}

fetch_libretro_tempgba() {
	fetch_git "https://github.com/libretro/TempGBA-libretro.git" "libretro-tempgba" "libretro/TempGBA"
}

fetch_libretro_gpsp() {
	fetch_git "https://github.com/libretro/gpsp.git" "libretro-gpsp" "libretro/gpsp"
}

fetch_libretro_emux() {
	fetch_git "https://github.com/libretro/emux.git" "libretro-emux" "libretro/Emux"
}

# Shouldn't this be part of the tools fetch?  Eh, later...
fetch_libretro_sdk() {
	fetch_git "https://github.com/libretro/libretro-sdk.git" "libretro-sdk" "libretro/SDK"
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

