# vim: set ts=3 sw=3 noet ft=sh : bash

register_module core "bsnes"
libretro_bsnes_name="bsnes/higan"
libretro_bsnes_git_url="https://github.com/libretro/bsnes-libretro.git"
libretro_bsnes_build_rule=none # NEED CUSTOM RULE

register_core "snes9x"
libretro_snes9x_name="SNES9x"
libretro_snes9x_git_url="https://github.com/libretro/snes9x.git"
libretro_snes9x_build_subdir="libretro"

register_core "snes9x_next"
libretro_snes9x_next_name="SNES9x Next"
libretro_snes9x_next_git_url="https://github.com/libretro/snes9x-next.git"
libretro_snes9x_next_build_makefile="Makefile.libretro"
libretro_snes9x_next_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "genesis_plus_gx"
libretro_genesis_plus_gx_name="Genesis Plus GX"
libretro_genesis_plus_gx_git_url="https://github.com/libretro/Genesis-Plus-GX.git"
libretro_genesis_plus_gx_build_makefile="Makefile.libretro"

register_core "fb_alpha"
libretro_fb_alpha_name="Final Burn Alpha"
libretro_fb_alpha_git_url="https://github.com/libretro/fba-libretro.git"
libretro_fb_alpha_build_subdir="svn-current/trunk"
libretro_fb_alpha_build_makefile="makefile.libretro"

register_core "vba_next"
libretro_vba_next_name="VBA Next"
libretro_vba_next_git_url="https://github.com/libretro/vba-next.git"
libretro_vba_next_build_makefile="Makefile.libretro"
libretro_vba_next_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "vbam"
libretro_vbam_name="VBA-M"
libretro_vbam_git_url="https://github.com/libretro/vbam-libretro.git"
libretro_vbam_build_subdir="src/libretro"
libretro_vbam_build_makefile="Makefile"
libretro_vbam_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "handy"
libretro_handy_name="Handy"
libretro_handy_git_url="https://github.com/libretro/libretro-handy.git"

register_core "bnes"
libretro_bnes_name="bnes/higan"
libretro_bnes_git_url="https://github.com/libretro/bnes-libretro.git"
libretro_bnes_build_rule=none # NEED CUSTOM RULE

register_core "fceumm"
libretro_fceumm_name="FCEUmm"
libretro_fceumm_git_url="https://github.com/libretro/libretro-fceumm.git"
libretro_fceumm_build_makefile="Makefile.libretro"

register_core "gambatte"
libretro_gambatte_name="Gambatte"
libretro_gambatte_git_url="https://github.com/libretro/gambatte-libretro.git"
libretro_gambatte_build_subdir="libgambatte"
libretro_gambatte_build_makefile="Makefile.libretro"
libretro_gambatte_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "meteor"
libretro_meteor_name="Meteor"
libretro_meteor_git_url="https://github.com/libretro/meteor-libretro.git"
libretro_meteor_build_subdir="libretro"

register_core "nxengine"
libretro_nxengine_name="NXEngine"
libretro_nxengine_git_url="https://github.com/libretro/nxengine-libretro.git"

register_core "prboom"
libretro_prboom_name="PrBoom"
libretro_prboom_git_url="https://github.com/libretro/libretro-prboom.git"
libretro_prboom_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "stella"
libretro_stella_name="Stella"
libretro_stella_git_url="https://github.com/libretro/stella-libretro.git"

register_core "desmume"
libretro_desmume_name="DeSmuME"
libretro_desmume_git_url="https://github.com/libretro/desmume.git"
libretro_desmume_build_subdir="desmume"
libretro_desmume_build_makefile="Makefile.libretro"

register_core "quicknes"
libretro_quicknes_name="QuickNES"
libretro_quicknes_git_url="https://github.com/libretro/QuickNES_Core.git"
libretro_quicknes_build_subdir="libretro"

register_core "nestopia"
libretro_nestopia_name="Nestopia"
libretro_nestopia_git_url="https://github.com/libretro/nestopia.git"
libretro_nestopia_build_subdir="libretro"

register_core "tyrquake"
libretro_tyrquake_name="TyrQuake"
libretro_tyrquake_git_url="https://github.com/libretro/tyrquake.git"
libretro_tyrquake_build_makefile="Makefile.libretro"

register_core "pcsx_rearmed"
libretro_pcsx_rearmed_name="PCSX ReARMed"
libretro_pcsx_rearmed_git_url="https://github.com/libretro/pcsx_rearmed.git"
libretro_pcsx_rearmed_build_makefile="Makefile.libretro"

register_core "mednafen_gba"
libretro_mednafen_gba_name="Mednafen/Beetle GBA"
libretro_mednafen_gba_git_url="https://github.com/libretro/beetle-gba-libretro.git"

register_core "mednafen_lynx"
libretro_mednafen_lynx_name="Mednafen/Beetle Lynx"
libretro_mednafen_lynx_git_url="https://github.com/libretro/beetle-lynx-libretro.git"

register_core "mednafen_ngp"
libretro_mednafen_ngp_name="Mednafen/Beetle NeoPop"
libretro_mednafen_ngp_git_url="https://github.com/libretro/beetle-ngp-libretro.git"

register_core "mednafen_pce_fast"
libretro_mednafen_pce_fast_name="Mednafen/Beetle PCE FAST"
libretro_mednafen_pce_fast_git_url="https://github.com/libretro/beetle-pce-fast-libretro.git"

register_core "mednafen_supergrafx"
libretro_mednafen_supergrafx_name="Mednafen/Beetle SuperGrafx"
libretro_mednafen_supergrafx_git_url="https://github.com/libretro/beetle-supergrafx-libretro.git"

register_core "mednafen_psx"
libretro_mednafen_psx_name="Mednafen PSX"
libretro_mednafen_psx_git_url="https://github.com/libretro/mednafen-psx-libretro.git"

register_core "mednafen_pcfx"
libretro_mednafen_pcfx_name="Mednafen/Beetle PC-FX"
libretro_mednafen_pcfx_git_url="https://github.com/libretro/beetle-pcfx-libretro.git"

register_core "mednafen_snes"
libretro_mednafen_snes_name="Mednafen/Beetle bsnes"
libretro_mednafen_snes_git_url="https://github.com/libretro/beetle-bsnes-libretro.git"

register_core "mednafen_vb"
libretro_mednafen_vb_name="Mednafen/Beetle VB"
libretro_mednafen_vb_git_url="https://github.com/libretro/beetle-vb-libretro.git"

register_core "mednafen_wswan"
libretro_mednafen_wswan_name="Mednafen/Beetle WonderSwan"
libretro_mednafen_wswan_git_url="https://github.com/libretro/beetle-wswan-libretro.git"

register_core "scummvm"
libretro_scummvm_name="ScummVM"
libretro_scummvm_git_url="https://github.com/libretro/scummvm.git"
libretro_scummvm_build_subdir="backends/platform/libretro/build"

register_core "yabause"
libretro_yabause_name="Yabause"
libretro_yabause_git_url="https://github.com/libretro/yabause.git"
libretro_yabause_build_subdir="libretro"

register_core "dosbox"
libretro_dosbox_name="DOSBox"
libretro_dosbox_git_url="https://github.com/libretro/dosbox-libretro.git"
libretro_dosbox_makefile="Makefile.libretro"

register_core "virtualjaguar"
libretro_virtualjaguar_name="Virtual Jaguar"
libretro_virtualjaguar_git_url="https://github.com/libretro/virtualjaguar-libretro.git"

register_core "mame078"
libretro_mame078_name="MAME 2003 (0.78)"
libretro_mame078_git_url="https://github.com/libretro/mame2003-libretro.git"

register_core "mame139"
libretro_mame139_name="MAME 2010 (0.139)"
libretro_mame139_git_url="https://github.com/libretro/mame2010-libretro.git"
libretro_mame139_build_rule=none # NEED A BUILD RULE

register_core "mame"
libretro_mame_name="MAME (git)"
libretro_mame_git_url="https://github.com/libretro/mame.git"
libretro_mame_build_rule=none # NEED CUSTOM RULE

register_core "ffmpeg"
libretro_ffmpeg_name="FFmpeg"
libretro_ffmpeg_git_url="https://github.com/libretro/FFmpeg.git"
libretro_ffmpeg_build_subdir="libretro"
libretro_ffmpeg_build_opengl="optional"

register_core "bsnes_cplusplus98"
libretro_bsnes_cplusplus98_name="bsnes C++98 (v0.85)"
libretro_bsnes_cplusplus98_git_url="https://github.com/libretro/bsnes-libretro-cplusplus98.git"
libretro_bsnes_cplusplus98_build_rule=none # NEED CUSTOM RULE

register_core "bsnes_mercury"
libretro_bsnes_mercury_name="bsnes-mercury"
libretro_bsnes_mercury_git_url="https://github.com/libretro/bsnes-mercury.git"
libretro_bsnes_mercury_build_rule=none # NEED CUSTOM RULE

register_core "picodrive"
libretro_picodrive_name="Picodrive"
libretro_picodrive_git_url="https://github.com/libretro/picodrive.git"
libretro_picodrive_git_submodules="yes"
libretro_picodrive_build_makefile="Makefile.libretro"

register_core "tgbdual"
libretro_tgbdual_name="TGB Dual"
libretro_tgbdual_git_url="https://github.com/libretro/tgbdual-libretro.git"

register_core "mupen64plus"
libretro_mupen64plus_name="Mupen64Plus"
libretro_mupen64plus_git_url="https://github.com/libretro/mupen64plus-libretro.git"
libretro_mupen64plus_build_rule=none # NEED CUSTOM RULE

register_core "dinothawr"
libretro_dinothawr_name="Dinothawr"
libretro_dinothawr_git_url="https://github.com/libretro/Dinothawr.git"
libretro_dinothawr_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "uae"
libretro_uae_name="UAE"
libretro_uae_git_url="https://github.com/libretro/libretro-uae.git"
libretro_uae_build_rule=none # NEED A BUILD RULE

register_core "3dengine"
libretro_3dengine_name="3DEngine"
libretro_3dengine_git_url="https://github.com/libretro/libretro-3dengine.git"
libretro_3dengine_build_opengl=yes

register_core "remotejoy"
libretro_remotejoy_name="RemoteJoy"
libretro_remotejoy_git_url="https://github.com/libretro/libretro-remotejoy.git"
libretro_remotejoy_build_rule=none # NEED A BUILD RULE

register_core "bluemsx"
libretro_bluemsx_name="blueMSX"
libretro_bluemsx_git_url="https://github.com/libretro/blueMSX-libretro.git"
libretro_bluemsx_build_makefile="Makefile.libretro"

register_core "fmsx"
libretro_fmsx_name="fMSX"
libretro_fmsx_git_url="https://github.com/libretro/fmsx-libretro.git"

register_module core "2048"
libretro_2048_git_url="https://github.com/libretro/libretro-2048.git"
libretro_2048_build_makefile="Makefile.libretro"

register_module core "vecx"
libretro_vecx_git_url="https://github.com/libretro/libretro-vecx.git"
libretro_vecx_build_makefile="Makefile.libretro"

register_core "ppsspp"
libretro_ppsspp_name="PPSSPP"
libretro_ppsspp_git_url="https://github.com/libretro/ppsspp.git"
libretro_ppsspp_git_submodules="yes"
libretro_ppsspp_build_subdir="libretro"
libretro_ppsspp_build_opengl="yes"

register_core "prosystem"
libretro_prosystem_name="ProSystem"
libretro_prosystem_git_url="https://github.com/libretro/prosystem-libretro.git"

register_core "o2em"
libretro_o2em_name="O2EM"
libretro_o2em_git_url="https://github.com/libretro/libretro-o2em.git"

register_core "4do"
libretro_4do_name="4DO"
libretro_4do_git_url="https://github.com/libretro/4do-libretro.git"

register_core "catsfc"
libretro_catsfc_name="CATSFC"
libretro_catsfc_git_url="https://github.com/libretro/CATSFC-libretro.git"

register_core "stonesoup"
libretro_stonesoup_name="Dungeon Crawl Stone Soup"
libretro_stonesoup_git_url="https://github.com/libretro/crawl-ref.git"
libretro_stonesoup_git_submodules="clone"
libretro_stonesoup_build_subdir="crawl-ref"
libretro_stonesoup_build_makefile="Makefile.libretro"

register_core "hatari"
libretro_hatari_name="Hatari"
libretro_hatari_git_url="https://github.com/libretro/hatari.git"
libretro_hatari_build_makefile="Makefile.libretro"

register_core "tempgba"
libretro_tempgba_name="TempGBA"
libretro_tempgba_git_url="https://github.com/libretro/TempGBA-libretro.git"
libretro_tempgba_build_rule=none # NEED A BUILD RULE

register_core "gpsp"
libretro_gpsp_name="gpSP"
libretro_gpsp_git_url="https://github.com/libretro/gpsp.git"

register_core "emux"
libretro_emux_name="Emux"
libretro_emux_git_url="https://github.com/libretro/emux.git"
libretro_emux_build_rule=none # NEED CUSTOM RULE

register_core "fuse"
libretro_fuse_name="Fuse"
libretro_fuse_git_url="https://github.com/libretro/fuse-libretro.git"
libretro_fuse_build_makefile="Makefile.libretro"
libretro_fuse_build_platform="$FORMAT_COMPILER_TARGET_ALT"

register_core "gw"
libretro_gw_name="Game & Watch"
libretro_gw_git_url="https://github.com/libretro/gw-libretro.git"
libretro_gw_git_submodules="yes"
libretro_gw_build_makefile="Makefile.libretro"

register_core "lutro"
libretro_lutro_name="Lutro"
libretro_lutro_git_url="https://github.com/libretro/libretro-lutro.git"
libretro_lutro_build_makefile="Makefile"

# CORE RULE VARIABLES
#
# All variables follow the format of libretro_<core>_<setting> where <core> is
# a unique identifier customarily consisting of the characters [_a-z0-9], but
# technically uppercase characters would also be legal here.  The <setting> may
# be any of the following:
#
# name						Pretty-printed name of the core
# 								Defaults to <core>
#
# dir							Name of the core's directory
# 								Defaults to "libretro-<core>"
#
# fetch_rule				Name of the core's fetch rule
# 								Currently "git" (default) or "multi_git"
#
# For the "git" fetch rule:
#
# git_url					Source to fetch via git
#								REQUIRED for fetch actions
#
# git_submodules			Set to "yes" if core has git submodules
#								Set to "clone" if they never need updating
#
# build_subdir				Subdir containing the libretro makefile
#								Leave unset if in top level of core
#
# For the "multi_git" fetch rule:
#
# mgit_urls					Number of URLs to fetch
#
# mgit_url_<n>				<n>th URL to fetch, start with 0
#								If you have 4 mgit_urls, <n> will be 0, 1, 2, or 3
#
# mgit_dir_<n>				<n>th directory to fetch into
#								You must set this for each URL
#
# For the generic makefile build rule:
#
# build_makefile			Name of makefile
#								If unset, GNU make has rules for default makefile names
#
# build_platform			Set to override the default platform
#								(e.g., $FORMAT_COMPILER_TARGET_ALT)
#
# build_opengl				Set to "optional" to use OpenGL/GLES if available
#								Set to "yes" if the core requires it
#
# Example:
#
#	libretro_dinothawr_git_url="https://github.com/libretro/Dinothawr.git"
#	libretro_dinothawr_name="Dinothawr"
#	libretro_dinothawr_build_platform="$FORMAT_COMPILER_TARGET_ALT"
#
# Since Dinothawr builds using defaults for everything else, you need only
# specify its URL and the platform override.  Everything else the core rules
# fetch and build can use default values.
