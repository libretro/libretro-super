#! /bin/bash
# vi: sw=3 ts=3 et

. ./libretro-config.sh

WORKDIR=$(pwd)

DATESTAMP_FMT="%Y-%m-%d_%H:%M:%S"

log_verbose() {
   if [ -n "${VERBOSE}" ]; then
      echo "$(date -u +${DATESTAMP_FMT}):${@}"
   fi
}


# fetch_git <repository> <local directory>
# Clones or pulls updates from a git repository into a local directory
fetch_git() {
   if [ -n "${3}" ]; then
      echo "=== Fetching ${3} ==="
   fi
   if [ -d "${2}/.git" ]; then
      log_verbose "${2}:git pull"
      cd "${2}"
      git pull
   else
      log_verbose "git clone \"${1}\" \"${2}\""
      git clone "${1}" "${2}"
   fi
   if [ -n "${3}" ]; then
      echo "=== Fetched ==="
   fi
}

# fetch_git_submodules <repository> <local directory>
# Clones or pulls updates from a git repository (and its submodules, if any)
# into a local directory
fetch_git_submodules() {
   if [ -n "${3}" ]; then
      echo "=== Fetching ${3} ==="
   fi
   if [ -d "${2}/.git" ]; then
      cd "${2}"
      log_verbose "${2}:git pull"
      git pull
      log_verbose "${2}:git submodule foreach git pull origin master"
      git submodule foreach git pull origin master
   else
      log_verbose "git clone \"${1}\" \"${2}\""
      git clone "${1}" "${2}"
      cd "${2}"
      log_verbose "${2}:git submodule update --init"
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
   if [ -n "${3}" ]; then
      echo "=== Fetching ${3} ==="
   fi
   if [ -d "${2}/.git" ]; then
      cd "${2}"
      log_verbose "${2}:git pull"
      git pull
   else
      log_verbose "git clone \"${1}\" \"${2}\""
      git clone "${1}" "${2}"
      cd "${2}"
      log_verbose "${2}:git submodule update --init"
      git submodule update --init
   fi
   if [ -n "${3}" ]; then
      echo "=== Fetched ==="
   fi
}

# Keep three copies so we don't have to rebuild stuff all the time.
fetch_project_bsnes()
{
   echo "=== Fetching ${3} ==="
   fetch_git "${1}" "${WORKDIR}/${2}"
   fetch_git "." "${WORKDIR}/${2}/perf"
   fetch_git "." "${WORKDIR}/${2}/balanced"
   echo "=== Fetched ==="
}

fetch_project()
{
   fetch_git "${1}" "${WORKDIR}/${2}" "${3}"
}

fetch_subprojects()
{
   fetch_git "${1}" "${WORKDIR}/${2}/${3}/${4}" "${5}"
}

fetch_project_submodule()
{
   fetch_git_submodules "${1}" "${WORKDIR}/${2}" "${3}"
}

fetch_project_submodule_no_update()
{
   fetch_git_submodules_no_update "${1}" "${WORKDIR}/${2}" "${3}"
}

if [ -z $WRITERIGHTS ]; then
   REPO_BASE="https://github.com"
else
   REPO_BASE="git://github.com"
fi

fetch_retroarch() {
   fetch_project "$REPO_BASE/libretro/RetroArch.git" "retroarch" "libretro/RetroArch"
   fetch_subprojects "$REPO_BASE/libretro/common-shaders.git" "retroarch" "media" "shaders_cg" "libretro/common-shaders"
   fetch_subprojects "$REPO_BASE/libretro/common-overlays.git" "retroarch" "media" "overlays" "libretro/common-overlays"
   fetch_subprojects "$REPO_BASE/libretro/retroarch-assets.git" "retroarch" "media" "assets" "libretro/retroarch-assets"
   fetch_subprojects "$REPO_BASE/libretro/retroarch-joypad-autoconfig.git" "retroarch" "media" "autoconfig" "libretro/joypad-autoconfig"
   fetch_subprojects "$REPO_BASE/libretro/libretro-database.git" "retroarch" "media" "libretrodb" "libretro/libretro-database"
}

fetch_tools() {
   fetch_project "$REPO_BASE/libretro/libretro-manifest.git" "libretro-manifest" "libretro/libretro-manifest"
   fetch_project "$REPO_BASE/libretro/libretrodb.git" "libretrodb" "libretro/libretrodb"
   fetch_project "$REPO_BASE/libretro/libretro-dat-pull.git" "libretro-dat-pull" "libretro/libretro-dat-pull"
}


fetch_libretro_bsnes() {
   fetch_project_bsnes "$REPO_BASE/libretro/bsnes-libretro.git" "libretro-bsnes" "libretro/bSNES"
}

fetch_libretro_snes9x() {
   fetch_project "$REPO_BASE/libretro/snes9x.git" "libretro-snes9x" "libretro/SNES9x"
}

fetch_libretro_snes9x_next() {
   fetch_project "$REPO_BASE/libretro/snes9x-next.git" "libretro-snes9x_next" "libretro/SNES9x-Next"
}

fetch_libretro_genesis_plus_gx() {
   fetch_project "$REPO_BASE/libretro/Genesis-Plus-GX.git" "libretro-genesis_plus_gx" "libretro/Genplus GX"
}

fetch_libretro_fb_alpha() {
   fetch_project "$REPO_BASE/libretro/fba-libretro.git" "libretro-fb_alpha" "libretro/FBA"
}

fetch_libretro_vba_next() {
   fetch_project "$REPO_BASE/libretro/vba-next.git" "libretro-vba_next" "libretro/VBA Next"
}

fetch_libretro_vbam() {
   fetch_project "$REPO_BASE/libretro/vbam-libretro.git" "libretro-vbam" "libretro/VBA-M"
}

fetch_libretro_handy() {
   fetch_project "$REPO_BASE/libretro/libretro-handy.git" "libretro-handy" "libretro/Handy"
}

fetch_libretro_bnes() {
   fetch_project "$REPO_BASE/libretro/bnes-libretro.git" "libretro-bnes" "libretro/bNES"
}

fetch_libretro_fceumm() {
   fetch_project "$REPO_BASE/libretro/libretro-fceumm.git" "libretro-fceumm" "libretro/FCEUmm"
}

fetch_libretro_gambatte() {
   fetch_project "$REPO_BASE/libretro/gambatte-libretro.git" "libretro-gambatte" "libretro/Gambatte"
}

fetch_libretro_meteor() {
   fetch_project "$REPO_BASE/libretro/meteor-libretro.git" "libretro-meteor" "libretro/Meteor"
}

fetch_libretro_nxengine() {
   fetch_project "$REPO_BASE/libretro/nxengine-libretro.git" "libretro-nxengine" "libretro/NX"
}

fetch_libretro_prboom() {
fetch_project "$REPO_BASE/libretro/libretro-prboom.git" "libretro-prboom" "libretro/PRBoom"
}

fetch_libretro_stella() {
   fetch_project "$REPO_BASE/libretro/stella-libretro.git" "libretro-stella" "libretro/Stella"
}

fetch_libretro_desmume() {
   fetch_project "$REPO_BASE/libretro/desmume.git" "libretro-desmume" "libretro/Desmume"
}

fetch_libretro_quicknes() {
   fetch_project "$REPO_BASE/libretro/QuickNES_Core.git" "libretro-quicknes" "libretro/QuickNES"
}

fetch_libretro_nestopia() {
   fetch_project "$REPO_BASE/libretro/nestopia.git" "libretro-nestopia" "libretro/Nestopia"
}

fetch_libretro_tyrquake() {
   fetch_project "$REPO_BASE/libretro/tyrquake.git" "libretro-tyrquake" "libretro/tyrquake"
}

fetch_libretro_pcsx_rearmed() {
   fetch_project "$REPO_BASE/libretro/pcsx_rearmed.git" "libretro-pcsx_rearmed" "libretro/pcsx_rearmed"
}

fetch_libretro_mednafen_gba() {
   fetch_project "$REPO_BASE/libretro/beetle-gba-libretro.git" "libretro-mednafen_gba" "libretro/Beetle GBA"
}

fetch_libretro_mednafen_lynx() {
   fetch_project "$REPO_BASE/libretro/beetle-lynx-libretro.git" "libretro-mednafen_lynx" "libretro/Beetle Lynx"
}

fetch_libretro_mednafen_ngp() {
   fetch_project "$REPO_BASE/libretro/beetle-ngp-libretro.git" "libretro-mednafen_ngp" "libretro/Beetle NGP"
}

fetch_libretro_mednafen_pce_fast() {
   fetch_project "$REPO_BASE/libretro/beetle-pce-fast-libretro.git" "libretro-mednafen_pce_fast" "libretro/Beetle PCE Fast"
}

fetch_libretro_mednafen_supergrafx() {
   fetch_project "$REPO_BASE/libretro/beetle-supergrafx-libretro.git" "libretro-mednafen_supergrafx" "libretro/Beetle SuperGrafx"
}

fetch_libretro_mednafen_psx() {
   fetch_project "$REPO_BASE/libretro/mednafen-psx-libretro.git" "libretro-mednafen_psx" "libretro/Mednafen PSX"
}

fetch_libretro_mednafen_pcfx() {
   fetch_project "$REPO_BASE/libretro/beetle-pcfx-libretro.git" "libretro-mednafen_pcfx" "libretro/Beetle PCFX"
}

fetch_libretro_mednafen_snes() {
   fetch_project "$REPO_BASE/libretro/beetle-bsnes-libretro.git" "libretro-mednafen_snes" "libretro/Beetle bSNES"
}

fetch_libretro_mednafen_vb() {
   fetch_project "$REPO_BASE/libretro/beetle-vb-libretro.git" "libretro-mednafen_vb" "libretro/Beetle VB"
}

fetch_libretro_mednafen_wswan() {
   fetch_project "$REPO_BASE/libretro/beetle-wswan-libretro.git" "libretro-mednafen_wswan" "libretro/Beetle WSwan"
}

fetch_libretro_scummvm() {
   fetch_project "$REPO_BASE/libretro/scummvm.git" "libretro-scummvm" "libretro/scummvm"
}

fetch_libretro_yabause() {
   fetch_project "$REPO_BASE/libretro/yabause.git" "libretro-yabause" "libretro/yabause"
}

fetch_libretro_dosbox() {
   fetch_project "$REPO_BASE/libretro/dosbox-libretro.git" "libretro-dosbox" "libretro/dosbox"
}

fetch_libretro_virtualjaguar() {
   fetch_project "$REPO_BASE/libretro/virtualjaguar-libretro.git" "libretro-virtualjaguar" "libretro/virtualjaguar"
}

fetch_libretro_mame078() {
   fetch_project "$REPO_BASE/libretro/mame2003-libretro.git" "libretro-mame078" "libretro/mame078"
}

fetch_libretro_mame139() {
   fetch_project "$REPO_BASE/libretro/mame2010-libretro.git" "libretro-mame139" "libretro/mame139"
}

fetch_libretro_mame() {
   fetch_project "$REPO_BASE/libretro/mame.git" "libretro-mame" "libretro/mame"
}

fetch_libretro_ffmpeg() {
   fetch_project "$REPO_BASE/libretro/FFmpeg.git" "libretro-ffmpeg" "libretro/FFmpeg"
}

fetch_libretro_bsnes_cplusplus98() {
   fetch_project "$REPO_BASE/libretro/bsnes-libretro-cplusplus98.git" "libretro-bsnes_cplusplus98" "libretro/bsnes-cplusplus98"
}

fetch_libretro_bsnes_mercury() {
   fetch_project "$REPO_BASE/libretro/bsnes-mercury.git" "libretro-bsnes_mercury" "libretro/bsnes-mercury"
}

fetch_libretro_picodrive() {
   fetch_project_submodule "$REPO_BASE/libretro/picodrive.git" "libretro-picodrive" "libretro/picodrive"
}

fetch_libretro_tgbdual() {
   fetch_project "$REPO_BASE/libretro/tgbdual-libretro.git" "libretro-tgbdual" "libretro/tgbdual"
}

fetch_libretro_mupen64plus() {
   fetch_project "$REPO_BASE/libretro/mupen64plus-libretro.git" "libretro-mupen64plus" "libretro/mupen64plus"
}

fetch_libretro_dinothawr() {
   fetch_project "$REPO_BASE/libretro/Dinothawr.git" "libretro-dinothawr" "libretro/Dinothawr"
}

fetch_libretro_uae() {
   fetch_project "$REPO_BASE/libretro/libretro-uae.git" "libretro-uae" "libretro/UAE"
}

fetch_libretro_3dengine() {
   fetch_project "$REPO_BASE/libretro/libretro-3dengine.git" "libretro-3dengine" "libretro/3DEngine"
}

fetch_libretro_remotejoy() {
   fetch_project "$REPO_BASE/libretro/libretro-remotejoy.git" "libretro-remotejoy" "libretro/RemoteJoy"
}

fetch_libretro_bluemsx() {
   fetch_project "$REPO_BASE/libretro/blueMSX-libretro.git" "libretro-bluemsx" "libretro/blueMSX"
}

fetch_libretro_fmsx() {
   fetch_project "$REPO_BASE/libretro/fmsx-libretro.git" "libretro-fmsx" "libretro/fmsx"
}

fetch_libretro_2048() {
   fetch_project "$REPO_BASE/libretro/libretro-2048.git" "libretro-2048" "libretro/2048"
}

fetch_libretro_vecx() {
   fetch_project "$REPO_BASE/libretro/libretro-vecx.git" "libretro-vecx" "libretro/vecx"
}

fetch_libretro_ppsspp() {
   fetch_project_submodule "$REPO_BASE/libretro/ppsspp.git" "libretro-ppsspp" "libretro/ppsspp"
}

fetch_libretro_prosystem() {
   fetch_project "$REPO_BASE/libretro/prosystem-libretro.git" "libretro-prosystem" "libretro/prosystem"
}

fetch_libretro_o2em() {
   fetch_project "$REPO_BASE/libretro/libretro-o2em.git" "libretro-o2em" "libretro/o2em"
}

fetch_libretro_4do() {
   fetch_project "$REPO_BASE/libretro/4do-libretro.git" "libretro-4do" "libretro/4do"
}

fetch_libretro_catsfc() {
   fetch_project "$REPO_BASE/libretro/CATSFC-libretro.git" "libretro-catsfc" "libretro/CATSFC"
}

fetch_libretro_stonesoup() {
   fetch_project_submodule_no_update "$REPO_BASE/libretro/crawl-ref.git" "libretro-stonesoup" "libretro/DungeonCrawler StoneSoup"
}

fetch_libretro_hatari() {
   fetch_project "$REPO_BASE/libretro/hatari.git" "libretro-hatari" "libretro/hatari"
}

fetch_libretro_tempgba() {
   fetch_project "$REPO_BASE/libretro/TempGBA-libretro.git" "libretro-tempgba" "libretro/TempGBA"
}

fetch_libretro_gpsp() {
   fetch_project "$REPO_BASE/libretro/gpsp.git" "libretro-gpsp" "libretro/gpsp"
}

fetch_libretro_emux() {
   fetch_project "$REPO_BASE/libretro/emux.git" "libretro-emux" "libretro/Emux"
}

if [ ${1} ]; then
   ${1}
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
fi

