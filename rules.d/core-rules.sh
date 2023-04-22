# vim: set ts=3 sw=3 noet ft=sh : bash

include_core_bsnes() {
	register_module core "bsnes" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}

libretro_bsnes_name="bsnes"
libretro_bsnes_git_url="https://github.com/libretro/bsnes-libretro.git"
libretro_bsnes_build_args="local=\"portable\" binary=\"library\" compiler=\"${CXX17}\" target=\"libretro\""
libretro_bsnes_build_subdir="bsnes"
libretro_bsnes_build_makefile="GNUmakefile"
libretro_bsnes_build_products="out"

include_core_bsnes_hd_beta() {
	register_module core "bsnes_hd_beta" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}

libretro_bsnes_hd_beta_name="bsnes-hd beta"
libretro_bsnes_hd_beta_git_url="https://github.com/DerKoun/bsnes-hd.git"
libretro_bsnes_hd_beta_build_args="binary=\"library\" compiler=\"${CXX17}\" target=\"libretro\""
libretro_bsnes_hd_beta_build_subdir="bsnes"
libretro_bsnes_hd_beta_build_makefile="GNUmakefile"
libretro_bsnes_hd_beta_build_products="out"

include_core_bsnes_accuracy() {
	register_module core "bsnes_accuracy" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_bsnes_accuracy_name="bsnes/higan 2014 (Accuracy)"
libretro_bsnes_accuracy_git_url="https://github.com/libretro/bsnes2014.git"
libretro_bsnes_accuracy_build_args="compiler=\"${CXX11}\" PROFILE=\"accuracy\""
libretro_bsnes_accuracy_build_cores="bsnes2014_accuracy"

include_core_bsnes_balanced() {
	register_module core "bsnes_balanced" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_bsnes_balanced_name="bsnes/higan 2014 (Balanced)"
libretro_bsnes_balanced_git_url="https://github.com/libretro/bsnes2014.git"
libretro_bsnes_balanced_build_args="compiler=\"${CXX11}\" PROFILE=\"balanced\""
libretro_bsnes_balanced_build_cores="bsnes2014_balanced"

include_core_bsnes_performance() {
	register_module core "bsnes_performance" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_bsnes_performance_name="bsnes/higan 2014 (Performance)"
libretro_bsnes_performance_git_url="https://github.com/libretro/bsnes2014.git"
libretro_bsnes_performance_build_args="compiler=\"${CXX11}\" PROFILE=\"performance\""
libretro_bsnes_performance_build_cores="bsnes2014_performance"

include_core_crocods() {
	register_module core "crocods"
}
libretro_crocods_name="CrocoDS"
libretro_crocods_git_url="https://github.com/libretro/libretro-crocods.git"
libretro_crocods_build_makefile="Makefile"

include_core_dolphin() {
	register_module core "dolphin"
}
libretro_dolphin_name="Dolphin"
libretro_dolphin_git_url="https://github.com/libretro/dolphin.git"
libretro_dolphin_build_subdir="Source/Core/DolphinLibretro"
libretro_dolphin_build_makefile="Makefile"

include_core_dolphin_launcher() {
	register_module core "dolphin_launcher"
}
libretro_dolphin_launcher_name="Dolphin Launcher"
libretro_dolphin_launcher_git_url="https://github.com/RobLoach/libretro-dolphin-launcher"

include_core_ishiiruka() {
	register_module core "ishiiruka"
}
libretro_ishiiruka_name="Ishiiruka"
libretro_ishiiruka_git_url="https://github.com/libretro/Ishiiruka.git"
libretro_ishiiruka_build_subdir="Source/Core/DolphinLibretro"
libretro_ishiiruka_build_makefile="Makefile"

include_core_daphne() {
	register_module core "daphne"
}
libretro_daphne_name="Daphne"
libretro_daphne_git_url="https://github.com/libretro/daphne.git"
libretro_daphne_build_makefile="Makefile"

include_core_swanstation() {
	register_module core "swanstation"
}
libretro_swanstation_name="Duckstation"
libretro_swanstation_git_url="https://github.com/libretro/swanstation.git"
libretro_swanstation_build_products="bin"

include_core_mrboom() {
	register_module core "mrboom"
}
libretro_mrboom_name="Mr.Boom"
libretro_mrboom_git_url="https://github.com/libretro/mrboom-libretro.git"
libretro_mrboom_git_submodules="yes"
libretro_mrboom_build_makefile="Makefile"

include_core_retro8() {
	register_module core "retro8"
}
libretro_retro8_name="Retro8"
libretro_retro8_git_url="https://github.com/libretro/retro8.git"
libretro_retro8_build_makefile="Makefile"

include_core_frodo() {
	register_module core "frodo"
}
libretro_frodo_name="Frodo"
libretro_frodo_git_url="https://github.com/libretro/frodo-libretro.git"
libretro_frodo_build_makefile="Makefile"

include_core_x1() {
	register_module core "x1"
}
libretro_x1_name="X Millennium Sharp 1"
libretro_x1_git_url="https://github.com/libretro/xmil-libretro.git"
libretro_x1_build_subdir="libretro"
libretro_x1_build_makefile="Makefile.libretro"

include_core_vice_x64() {
	register_module core "vice_x64"
}
libretro_vice_x64_name="VICE x64"
libretro_vice_x64_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_x64_build_makefile="Makefile"

include_core_vice_x64sc() {
	register_module core "vice_x64sc"
}
libretro_vice_x64sc_name="VICE x64sc"
libretro_vice_x64sc_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_x64sc_build_makefile="Makefile"
libretro_vice_x64sc_build_args="EMUTYPE=\"x64sc\""
libretro_vice_x64sc_build_cores="vice_x64sc"

include_core_vice_xscpu64() {
	register_module core "vice_xscpu64"
}
libretro_vice_xscpu64_name="VICE xscpu64"
libretro_vice_xscpu64_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_xscpu64_build_makefile="Makefile"
libretro_vice_xscpu64_build_args="EMUTYPE=\"xscpu64\""
libretro_vice_xscpu64_build_cores="vice_xscpu64"

include_core_vice_xcbm2() {
	register_module core "vice_xcbm2"
}
libretro_vice_xcbm2_name="VICE xcbm2"
libretro_vice_xcbm2_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_xcbm2_build_makefile="Makefile"
libretro_vice_xcbm2_build_args="EMUTYPE=\"xcbm2\""
libretro_vice_xcbm2_build_cores="vice_xcbm2"

include_core_vice_xcbm5x0() {
	register_module core "vice_xcbm5x0"
}
libretro_vice_xcbm5x0_name="VICE xcbm5x0"
libretro_vice_xcbm5x0_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_xcbm5x0_build_makefile="Makefile"
libretro_vice_xcbm5x0_build_args="EMUTYPE=\"xcbm5x0\""
libretro_vice_xcbm5x0_build_cores="vice_xcbm5x0"

include_core_vice_x128() {
	register_module core "vice_x128"
}
libretro_vice_x128_name="VICE x128"
libretro_vice_x128_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_x128_build_makefile="Makefile"
libretro_vice_x128_build_args="EMUTYPE=\"x128\""
libretro_vice_x128_build_cores="vice_x128"

include_core_vice_xpet() {
	register_module core "vice_xpet"
}
libretro_vice_xpet_name="VICE xpet"
libretro_vice_xpet_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_xpet_build_makefile="Makefile"
libretro_vice_xpet_build_args="EMUTYPE=\"xpet\""
libretro_vice_xpet_build_cores="vice_xpet"

include_core_vice_xplus4() {
	register_module core "vice_xplus4"
}
libretro_vice_xplus4_name="VICE xplus4"
libretro_vice_xplus4_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_xplus4_build_makefile="Makefile"
libretro_vice_xplus4_build_args="EMUTYPE=\"xplus4\""
libretro_vice_xplus4_build_cores="vice_xplus4"

include_core_vice_xvic() {
	register_module core "vice_xvic"
}
libretro_vice_xvic_name="VICE xvic"
libretro_vice_xvic_git_url="https://github.com/libretro/vice-libretro.git"
libretro_vice_xvic_build_makefile="Makefile"
libretro_vice_xvic_build_args="EMUTYPE=\"xvic\""
libretro_vice_xvic_build_cores="vice_xvic"

include_core_xrick() {
	register_module core "xrick"
}
libretro_xrick_name="XRick"
libretro_xrick_git_url="https://github.com/libretro/xrick-libretro.git"
libretro_xrick_build_makefile="Makefile"

include_core_freeintv() {
	register_module core "freeintv"
}
libretro_freeintv_name="FreeIntv"
libretro_freeintv_git_url="https://github.com/libretro/FreeIntv.git"
libretro_freeintv_build_makefile="Makefile"

include_core_pocketcdg() {
	register_module core "pocketcdg"
}
libretro_pocketcdg_name="PocketCDG"
libretro_pocketcdg_git_url="https://github.com/libretro/libretro-pocketcdg.git"
libretro_pocketcdg_build_makefile="Makefile"

include_core_potator() {
	register_module core "potator"
}
libretro_potator_name="Potator"
libretro_potator_git_url="https://github.com/libretro/potator.git"
libretro_potator_build_subdir="platform/libretro"
libretro_potator_build_makefile="Makefile"

include_core_easyrpg() {
	register_module core "easyrpg" -ngc -ps3 -psp1 -wii
}
libretro_easyrpg_name="EasyRPG"
libretro_easyrpg_git_url="https://github.com/EasyRPG/Player.git"
libretro_easyrpg_build_subdir="build"
libretro_easyrpg_git_submodules="yes"
libretro_easyrpg_post_fetch_cmd="cmake . -DPLAYER_TARGET_PLATFORM=libretro -t build"
libretro_easyrpg_build_makefile="Makefile"

include_core_gme() {
	register_module core "gme" -ngc -ps3 -psp1 -wii
}
libretro_gme_name="Game Music Emu"
libretro_gme_git_url="https://github.com/libretro/libretro-gme.git"

include_core_fixnes() {
	register_module core "fixnes" -ngc -ps3 -psp1 -wii
}
libretro_fixnes_name="fixNES"
libretro_fixnes_git_url="https://github.com/libretro/fixNES.git"
libretro_fixnes_build_subdir="libretro"

include_core_fixgb() {
	register_module core "fixgb" -ngc -ps3 -psp1 -wii
}
libretro_fixgb_name="fixGB"
libretro_fixgb_git_url="https://github.com/libretro/fixGB.git"
libretro_fixgb_build_subdir="libretro"

include_core_snes9x2002() {
	register_module core "snes9x2002" -ngc -ps3 -psp1 -wii
}
libretro_snes9x2002_name="SNES9x 2002"
libretro_snes9x2002_git_url="https://github.com/libretro/snes9x2002.git"

include_core_snes9x2005() {
	register_module core "snes9x2005" -ngc -ps3 -psp1 -wii
}
libretro_snes9x2005_name="SNES9x 2005"
libretro_snes9x2005_git_url="https://github.com/libretro/snes9x2005.git"

include_core_snes9x2005_plus() {
	register_module core "snes9x2005_plus" -ngc -ps3 -psp1 -wii
}
libretro_snes9x2005_plus_name="SNES9x 2005 Plus"
libretro_snes9x2005_plus_git_url="https://github.com/libretro/snes9x2005.git"
libretro_snes9x2005_plus_build_args="USE_BLARGG_APU=\"1\""

include_core_chimerasnes() {
	register_module core "chimerasnes" -ngc -ps3 -psp1 -wii
}
libretro_chimerasnes_name="ChimeraSNES"
libretro_chimerasnes_git_url="https://github.com/jamsilva/chimerasnes.git"

include_core_snes9x2010() {
	register_module core "snes9x2010" -ps3
}
libretro_snes9x2010_name="SNES9x 2010"
libretro_snes9x2010_git_url="https://github.com/libretro/snes9x2010.git"
libretro_snes9x2010_build_makefile="Makefile.libretro"
libretro_snes9x2010_build_platform="$FORMAT_COMPILER_TARGET_ALT"

include_core_snes9x() {
	register_module core "snes9x" -ngc -sncps3 -ps3 -psp1 -wii
}
libretro_snes9x_name="SNES9x"
libretro_snes9x_git_url="https://github.com/libretro/snes9x.git"
libretro_snes9x_build_subdir="libretro"

include_core_flycast() {
	register_module core "flycast"
}
libretro_flycast_name="Flycast"
libretro_flycast_git_url="https://github.com/flyinghead/flycast"
libretro_flycast_build_makefile="Makefile"

include_core_redream() {
	register_module core "redream"
}
libretro_redream_name="Redream"
libretro_redream_git_url="https://github.com/libretro/redream.git"
libretro_redream_build_makefile="Makefile"
libretro_redream_build_subdir="deps/libretro"

include_core_minivmac() {
	register_module core "minivmac"
}
libretro_minivmac_name="Mini Vmac"
libretro_minivmac_git_url="https://github.com/libretro/libretro-minivmac.git"
libretro_minivmac_build_makefile="Makefile"
libretro_minivmac_git_submodules="yes"

include_core_oberon() {
	register_module core "oberon"
}
libretro_oberon_name="Oberon RISC Emulator"
libretro_oberon_git_url="https://github.com/libretro/oberon-risc-emu"
libretro_oberon_build_makefile="Makefile.libretro"

include_core_reminiscence() {
	register_module core "reminiscence"
}
libretro_reminiscence_name="REminiscence"
libretro_reminiscence_git_url="https://github.com/libretro/REminiscence.git"
libretro_reminiscence_build_makefile="Makefile"

include_core_genesis_plus_gx() {
	register_module core "genesis_plus_gx" -theos_ios
}
libretro_genesis_plus_gx_name="Genesis Plus GX"
libretro_genesis_plus_gx_git_url="https://github.com/libretro/Genesis-Plus-GX.git"
libretro_genesis_plus_gx_build_makefile="Makefile.libretro"

include_core_genesis_plus_gx_wide() {
	register_module core "genesis_plus_gx_wide" -theos_ios
}
libretro_genesis_plus_gx_wide_name="Genesis Plus GX"
libretro_genesis_plus_gx_wide_git_url="https://github.com/libretro/Genesis-Plus-GX-Wide.git"
libretro_genesis_plus_gx_wide_build_makefile="Makefile.libretro"

include_core_mgba() {
	register_module core "mgba"
}
libretro_mgba_name="mGBA"
libretro_mgba_git_url="https://github.com/libretro/mgba.git"
libretro_mgba_build_makefile="Makefile.libretro"

include_core_video_processor() {
	register_module core "video_processor"
}
libretro_video_processor_name="Video processor"
libretro_video_processor_git_url="https://github.com/libretro/libretro-video-processor.git"
libretro_video_processor_build_makefile="Makefile"

include_core_fbneo() {
	register_module core "fbneo" -psp1
}
libretro_fbneo_name="FinalBurn Neo"
libretro_fbneo_git_url="https://github.com/libretro/FBNeo.git"
libretro_fbneo_build_subdir="src/burner/libretro"

include_core_fbalpha() {
	register_module core "fbalpha" -psp1
}
libretro_fbalpha_name="Final Burn Alpha"
libretro_fbalpha_git_url="https://github.com/libretro/fbalpha.git"
libretro_fbalpha_build_makefile="makefile.libretro"

include_core_fbalpha2012() {
	register_module core "fbalpha2012" -psp1
}
libretro_fbalpha2012_name="Final Burn Alpha 2012"
libretro_fbalpha2012_git_url="https://github.com/libretro/fbalpha2012.git"
libretro_fbalpha2012_build_subdir="svn-current/trunk"
libretro_fbalpha2012_build_makefile="makefile.libretro"

include_core_fbalpha2012_cps1() {
	register_module core "fbalpha2012_cps1" -psp1
}
libretro_fbalpha2012_cps1_name="Final Burn Alpha 2012 CPS1"
libretro_fbalpha2012_cps1_git_url="https://github.com/libretro/fbalpha2012_cps1.git"
libretro_fbalpha2012_cps1_build_makefile="makefile.libretro"

include_core_fbalpha2012_cps2() {
	register_module core "fbalpha2012_cps2" -psp1
}
libretro_fbalpha2012_cps2_name="Final Burn Alpha 2012 CPS2"
libretro_fbalpha2012_cps2_git_url="https://github.com/libretro/fbalpha2012_cps2.git"
libretro_fbalpha2012_cps2_build_makefile="makefile.libretro"

include_core_fbalpha2012_cps3() {
	register_module core "fbalpha2012_cps3" -psp1
}
libretro_fbalpha2012_cps3_name="Final Burn Alpha 2012 CPS3"
libretro_fbalpha2012_cps3_git_url="https://github.com/libretro/fbalpha2012_cps3.git"
libretro_fbalpha2012_cps3_build_subdir="svn-current/trunk"
libretro_fbalpha2012_cps3_build_makefile="makefile.libretro"

include_core_fbalpha2012_neogeo() {
	register_module core "fbalpha2012_neogeo" -psp1
}
libretro_fbalpha2012_neogeo_name="Final Burn Alpha 2012 NeoGeo"
libretro_fbalpha2012_neogeo_git_url="https://github.com/libretro/fbalpha2012_neogeo.git"
libretro_fbalpha2012_neogeo_build_makefile="Makefile"

include_core_blastem() {
	register_module core "blastem" -psp1
}
libretro_blastem_name="BlastEm"
libretro_blastem_git_url="https://github.com/libretro/blastem.git"
libretro_blastem_build_makefile="Makefile.libretro"

include_core_vba_next() {
	register_module core "vba_next"
}
libretro_vba_next_name="VBA Next"
libretro_vba_next_git_url="https://github.com/libretro/vba-next.git"
libretro_vba_next_build_makefile="Makefile.libretro"
libretro_vba_next_build_platform="$FORMAT_COMPILER_TARGET_ALT"

include_core_vbam() {
	register_module core "vbam" -ngc -ps3 -psp1 -wii
}
libretro_vbam_name="VBA-M"
libretro_vbam_git_url="https://github.com/libretro/vbam-libretro.git"
libretro_vbam_build_subdir="src/libretro"
libretro_vbam_build_makefile="Makefile"
libretro_vbam_build_platform="$FORMAT_COMPILER_TARGET_ALT"

include_core_handy() {
	register_module core "handy" -ngc -wii
}
libretro_handy_name="Handy"
libretro_handy_git_url="https://github.com/libretro/libretro-handy.git"

include_core_cap32() {
	register_module core "cap32" -ngc -ps3 -psp1 -qnx -wii
}
libretro_cap32_name="Caprice32"
libretro_cap32_git_url="https://github.com/libretro/libretro-cap32.git"
libretro_cap32_build_makefile="Makefile"

include_core_fsuae() {
	register_module core "fsuae" -ngc -ps3 -psp1 -qnx -wii
}
libretro_fsuae_name="FS-UAE"
libretro_fsuae_git_url="https://github.com/libretro/libretro-fsuae.git"
libretro_fsuae_build_makefile="Makefile.libretro"

include_core_puae() {
	register_module core "puae" -ngc -ps3 -psp1 -qnx -wii
}
libretro_puae_name="PUAE"
libretro_puae_git_url="https://github.com/libretro/libretro-uae.git"
libretro_puae_build_makefile="Makefile"

include_core_puae2021() {
	register_module core "puae2021" -ngc -ps3 -psp1 -qnx -wii
}
libretro_puae2021_name="PUAE 2021"
libretro_puae2021_git_url="https://github.com/libretro/libretro-uae.git"
libretro_puae2021_build_makefile="Makefile"
libretro_puae2021_post_fetch_cmd="git checkout 2.6.1"

include_core_uae4arm() {
	register_module core "uae4arm"
}
libretro_uae4arm_name="uae4arm"
libretro_uae4arm_git_url="https://github.com/libretro/uae4arm-libretro.git"
libretro_uae4arm_build_makefile="Makefile"

include_core_galaxy() {
	register_module core "galaxy"
}
libretro_galaxy_name="Galaxy"
libretro_galaxy_git_url="https://github.com/libretro/galaxy-libretro.git"
libretro_galaxy_build_makefile="Makefile"
libretro_galaxy_build_cores="galaksija"

include_core_bnes() {
	register_module core "bnes" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_bnes_name="bnes/higan"
libretro_bnes_git_url="https://github.com/libretro/bnes-libretro.git"
libretro_bnes_build_args="compiler=\"${CXX11}\""

include_core_fceumm() {
	register_module core "fceumm"
}
libretro_fceumm_name="FCEUmm"
libretro_fceumm_git_url="https://github.com/libretro/libretro-fceumm.git"
libretro_fceumm_build_makefile="Makefile.libretro"

include_core_gambatte() {
	register_module core "gambatte"
}
libretro_gambatte_name="Gambatte"
libretro_gambatte_git_url="https://github.com/libretro/gambatte-libretro.git"
libretro_gambatte_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_gambatte_build_makefile="Makefile.libretro"

include_core_gearboy() {
	register_module core "gearboy"
}
libretro_gearboy_name="Gearboy"
libretro_gearboy_git_url="https://github.com/drhelius/Gearboy.git"
libretro_gearboy_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_gearboy_build_subdir="platforms/libretro"
libretro_gearboy_build_makefile="Makefile"

include_core_gearsystem() {
   register_module core "gearsystem"
}
libretro_gearsystem_name="Gearsystem"
libretro_gearsystem_git_url="https://github.com/drhelius/Gearsystem.git"
libretro_gearsystem_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_gearsystem_build_subdir="platforms/libretro"
libretro_gearsystem_build_makefile="Makefile"

include_core_sameboy() {
	register_module core "sameboy"
}
libretro_sameboy_name="SameBoy"
libretro_sameboy_git_url="https://github.com/libretro/SameBoy.git"
libretro_sameboy_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_sameboy_build_subdir="libretro"
libretro_sameboy_build_makefile="Makefile"

include_core_sameduck() {
	register_module core "sameduck"
}
libretro_sameduck_name="SameDuck"
libretro_sameduck_git_url="https://github.com/LIJI32/SameBoy.git"
libretro_sameduck_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_sameduck_build_subdir="libretro"
libretro_sameduck_build_makefile="Makefile"
libretro_sameduck_post_fetch_cmd="git checkout SameDuck"

include_core_meteor() {
	register_module core "meteor" -ngc -ps3 -psp1 -qnx -wii
}
libretro_meteor_name="Meteor"
libretro_meteor_git_url="https://github.com/libretro/meteor-libretro.git"
libretro_meteor_build_subdir="libretro"

include_core_nxengine() {
	register_module core "nxengine"
}
libretro_nxengine_name="NXEngine"
libretro_nxengine_git_url="https://github.com/libretro/nxengine-libretro.git"

include_core_ecwolf() {
	register_module core "ecwolf"
}
libretro_ecwolf_name="ECWolf"
libretro_ecwolf_git_url="https://github.com/libretro/ecwolf.git"
libretro_ecwolf_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_ecwolf_build_subdir="src/libretro"
libretro_ecwolf_build_makefile="Makefile"
libretro_ecwolf_git_submodules="yes"

include_core_prboom() {
	register_module core "prboom"
}
libretro_prboom_name="PrBoom"
libretro_prboom_git_url="https://github.com/libretro/libretro-prboom.git"
libretro_prboom_build_platform="$FORMAT_COMPILER_TARGET_ALT"

include_core_stella() {
	register_module core "stella" -ngc -wii
}
libretro_stella_name="Stella"
libretro_stella_git_url="https://github.com/stella-emu/stella.git"
libretro_stella_build_subdir="src/libretro"
libretro_stella_build_makefile="Makefile"

include_core_stella2014() {
	register_module core "stella2014" -ngc -wii
}
libretro_stella2014_name="Stella 2014"
libretro_stella2014_git_url="https://github.com/libretro/stella2014-libretro.git"

include_core_melonds() {
register_module core "melonds" -ngc -ps3 -psp1 -qnx -wii
}
libretro_melonds_name="melonDS"
libretro_melonds_git_url="https://github.com/libretro/melonDS.git"
libretro_melonds_build_makefile="Makefile"

include_core_openlara() {
register_module core "openlara" -ngc -ps3 -psp1 -qnx -wii
}
libretro_openlara_name="OpenLara"
libretro_openlara_git_url="https://github.com/libretro/OpenLara.git"
libretro_openlara_build_subdir="src/platform/libretro"
libretro_openlara_build_makefile="Makefile"

include_core_cannonball() {
	register_module core "cannonball" -ngc -wii
}
libretro_cannonball_name="Cannonball"
libretro_cannonball_git_url="https://github.com/libretro/cannonball.git"

include_core_desmume() {
register_module core "desmume" -ngc -ps3 -psp1 -qnx -wii
}
libretro_desmume_name="DeSmuME"
libretro_desmume_git_url="https://github.com/libretro/desmume.git"
libretro_desmume_build_subdir="desmume/src/frontend/libretro"
libretro_desmume_build_makefile="Makefile.libretro"

include_core_desmume2015() {
register_module core "desmume2015" -ngc -ps3 -psp1 -qnx -wii
}
libretro_desmume2015_name="DeSmuME 2015"
libretro_desmume2015_git_url="https://github.com/libretro/desmume2015.git"
libretro_desmume2015_build_subdir="desmume"
libretro_desmume2015_build_makefile="Makefile.libretro"

include_core_quicknes() {
	register_module core "quicknes"
}
libretro_quicknes_name="QuickNES"
libretro_quicknes_git_url="https://github.com/libretro/QuickNES_Core.git"
libretro_quicknes_build_makefile="Makefile"

include_core_nestopia() {
	register_module core "nestopia"
}
libretro_nestopia_name="Nestopia"
libretro_nestopia_git_url="https://github.com/libretro/nestopia.git"
libretro_nestopia_build_subdir="libretro"

include_core_numero() {
	register_module core "numero"
}
libretro_numero_name="Numero"
libretro_numero_git_url="https://github.com/nbarkhina/numero.git"
libretro_numero_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_numero_build_makefile="Makefile.libretro"

include_core_craft() {
	register_module core "craft"
}
libretro_craft_name="Craft"
libretro_craft_git_url="https://github.com/libretro/Craft.git"
libretro_craft_build_makefile="Makefile.libretro"

include_core_pcem() {
	register_module core "pcem"
}
libretro_pcem_name="PCem"
libretro_pcem_git_url="https://github.com/libretro/libretro-pcem.git"
libretro_pcem_build_makefile="Makefile.libretro"
libretro_pcem_build_subdir="src"

include_core_tyrquake() {
	register_module core "tyrquake"
}
libretro_tyrquake_name="TyrQuake"
libretro_tyrquake_git_url="https://github.com/libretro/tyrquake.git"
libretro_tyrquake_build_makefile="Makefile"

include_core_boom3() {
	register_module core "boom3"
}
libretro_boom3_name="boom3"
libretro_boom3_git_url="https://github.com/libretro/boom3.git"
libretro_boom3_build_makefile="Makefile"
libretro_boom3_build_subdir="neo"

include_core_vitaquake2() {
	register_module core "vitaquake2"
}
libretro_vitaquake2_name="vitaQuake2"
libretro_vitaquake2_git_url="https://github.com/libretro/vitaquake2.git"
libretro_vitaquake2_build_makefile="Makefile"

include_core_vitaquake2_rogue() {
	register_module core "vitaquake2_rogue"
}
libretro_vitaquake2_rogue_name="vitaQuake 2 [Rogue]"
libretro_vitaquake2_rogue_git_url="https://github.com/libretro/vitaquake2.git"
libretro_vitaquake2_rogue_build_makefile="Makefile"
libretro_vitaquake2_rogue_build_args="basegame=\"rogue\""
libretro_vitaquake2_rogue_build_cores="vitaquake2-rogue"
libretro_vitaquake2_rogue_dir=libretro-vitaquake2

include_core_vitaquake2_xatrix() {
	register_module core "vitaquake2_xatrix"
}
libretro_vitaquake2_xatrix_name="vitaQuake 2 [Xatrix]"
libretro_vitaquake2_xatrix_git_url="https://github.com/libretro/vitaquake2.git"
libretro_vitaquake2_xatrix_build_makefile="Makefile"
libretro_vitaquake2_xatrix_build_args="basegame=\"xatrix\""
libretro_vitaquake2_xatrix_build_cores="vitaquake2-xatrix"
libretro_vitaquake2_xatrix_dir=libretro-vitaquake2

include_core_vitaquake2_zaero() {
	register_module core "vitaquake2_zaero"
}
libretro_vitaquake2_zaero_name="vitaQuake 2 [Zaero]"
libretro_vitaquake2_zaero_git_url="https://github.com/libretro/vitaquake2.git"
libretro_vitaquake2_zaero_build_makefile="Makefile"
libretro_vitaquake2_zaero_build_args="basegame=\"zaero\""
libretro_vitaquake2_zaero_build_cores="vitaquake2-zaero"
libretro_vitaquake2_zaero_dir=libretro-vitaquake2

include_core_vitavoyager() {
	register_module core "vitavoyager"
}
libretro_vitavoyager_name="Lilium Voyager"
libretro_vitavoyager_git_url="https://github.com/libretro/vitaVoyager.git"

include_core_vitaquake3() {
	register_module core "vitaquake3"
}
libretro_vitaquake3_name="vitaQuake3"
libretro_vitaquake3_git_url="https://github.com/libretro/vitaquake3.git"
libretro_vitaquake3_build_makefile="Makefile"

include_core_pcsx_rearmed() {
	register_module core "pcsx_rearmed" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_pcsx_rearmed_name="PCSX ReARMed"
libretro_pcsx_rearmed_git_url="https://github.com/libretro/pcsx_rearmed.git"
libretro_pcsx_rearmed_build_makefile="Makefile.libretro"
libretro_pcsx_rearmed_configure() {
	if [ "$platform" = "ios" ]; then
		core_build_cores="pcsx_rearmed_interpreter pcsx_rearmed"
	fi
}

include_core_pcsx1() {
	register_module core "pcsx1" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_pcsx1_name="PCSX1"
libretro_pcsx1_git_url="https://github.com/libretro/pcsx1-libretro.git"
libretro_pcsx1_build_makefile="Makefile.libretro"
libretro_pcsx1_configure() {
	if [ "$platform" = "ios" ]; then
		core_build_cores="pcsx1_interpreter pcsx1"
	fi
}

include_core_pcsx2() {
	register_module core "pcsx2" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_pcsx2_name="PCSX2"
libretro_pcsx2_git_url="https://github.com/libretro/pcsx2.git"
libretro_pcsx2_git_submodules="yes"
libretro_pcsx2_build_subdir="libretro"
libretro_pcsx2_build_makefile="Makefile"

include_core_mednafen_gba() {
	register_module core "mednafen_gba" -theos_ios
}
libretro_mednafen_gba_name="Mednafen/Beetle GBA"
libretro_mednafen_gba_git_url="https://github.com/libretro/beetle-gba-libretro.git"

include_core_mednafen_lynx() {
	register_module core "mednafen_lynx" -theos_ios
}
libretro_mednafen_lynx_name="Mednafen/Beetle Lynx"
libretro_mednafen_lynx_git_url="https://github.com/libretro/beetle-lynx-libretro.git"

include_core_mednafen_ngp() {
	register_module core "mednafen_ngp" -theos_ios -qnx
}
libretro_mednafen_ngp_name="Mednafen/Beetle NeoPop"
libretro_mednafen_ngp_git_url="https://github.com/libretro/beetle-ngp-libretro.git"

include_core_race() {
	register_module core "race" -theos_ios -qnx
}
libretro_race_name="RACE"
libretro_race_git_url="https://github.com/libretro/RACE.git"

include_core_mednafen_pce() {
	register_module core "mednafen_pce" -theos_ios
}
libretro_mednafen_pce_name="Mednafen/Beetle PCE"
libretro_mednafen_pce_git_url="https://github.com/libretro/beetle-pce-libretro.git"

include_core_mednafen_pce_fast() {
	register_module core "mednafen_pce_fast" -theos_ios
}
libretro_mednafen_pce_fast_name="Mednafen/Beetle PCE FAST"
libretro_mednafen_pce_fast_git_url="https://github.com/libretro/beetle-pce-fast-libretro.git"

include_core_mednafen_supergrafx() {
	register_module core "mednafen_supergrafx" -theos_ios
}
libretro_mednafen_supergrafx_name="Mednafen/Beetle SuperGrafx"
libretro_mednafen_supergrafx_git_url="https://github.com/libretro/beetle-supergrafx-libretro.git"

include_core_mednafen_psx() {
	register_module core "mednafen_psx" -theos_ios -ngc -psp1
}
libretro_mednafen_psx_name="Mednafen/Beetle PSX"
libretro_mednafen_psx_git_url="https://github.com/libretro/beetle-psx-libretro.git"
libretro_mednafen_psx_dir=libretro-beetle_psx

include_core_mednafen_psx_hw() {
	register_module core "mednafen_psx_hw" -theos_ios -ngc -psp1
}
libretro_mednafen_psx_hw_name="Mednafen/Beetle PSX HW"
libretro_mednafen_psx_hw_git_url="https://github.com/libretro/beetle-psx-libretro.git"
libretro_mednafen_psx_hw_dir=libretro-beetle_psx
libretro_mednafen_psx_hw_build_args="HAVE_HW=1 HAVE_LIGHTREC=1 $libretro_mednafen_psx_hw_build_args"

include_core_mednafen_saturn() {
	register_module core "mednafen_saturn" -theos_ios -ngc -psp1
}
libretro_mednafen_saturn_name="Mednafen/Beetle Saturn"
libretro_mednafen_saturn_git_url="https://github.com/libretro/beetle-saturn-libretro.git"

include_core_mednafen_pcfx() {
	register_module core "mednafen_pcfx" -theos_ios
}
libretro_mednafen_pcfx_name="Mednafen/Beetle PC-FX"
libretro_mednafen_pcfx_git_url="https://github.com/libretro/beetle-pcfx-libretro.git"

include_core_mednafen_snes() {
	register_module core "mednafen_snes" -theos_ios
}
libretro_mednafen_snes_name="Mednafen/Beetle bsnes"
libretro_mednafen_snes_git_url="https://github.com/libretro/beetle-bsnes-libretro.git"

include_core_mednafen_supafaust() {
	register_module core "mednafen_supafaust" -theos_ios
}
libretro_mednafen_supafaust_name="Mednafen/Beetle Faust"
libretro_mednafen_supafaust_git_url="https://github.com/libretro/supafaust.git"

include_core_mednafen_vb() {
	register_module core "mednafen_vb" -theos_ios
}
libretro_mednafen_vb_name="Mednafen/Beetle VB"
libretro_mednafen_vb_git_url="https://github.com/libretro/beetle-vb-libretro.git"

include_core_mednafen_wswan() {
	register_module core "mednafen_wswan" -theos_ios -psp1
}
libretro_mednafen_wswan_name="Mednafen/Beetle WonderSwan"
libretro_mednafen_wswan_git_url="https://github.com/libretro/beetle-wswan-libretro.git"

include_core_rustation() {
	register_module core "rustation" -theos_ios -ngc -psp1
}
libretro_rustation_name="Rustation"
libretro_rustation_git_url="https://github.com/libretro/rustation-libretro.git"

include_core_scummvm() {
	register_module core "scummvm" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_scummvm_name="ScummVM"
libretro_scummvm_git_url="https://github.com/libretro/scummvm.git"
libretro_scummvm_build_subdir="backends/platform/libretro/build"

include_core_kronos() {
	register_module core "kronos" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_kronos_name="Kronos"
libretro_kronos_git_url="https://github.com/libretro/yabause.git"
libretro_kronos_build_subdir="yabause/src/libretro"
libretro_kronos_post_fetch_cmd="git checkout kronos"

include_core_yabasanshiro() {
	register_module core "yabasanshiro" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_yabasanshiro_name="YabaSanshiro"
libretro_yabasanshiro_git_url="https://github.com/libretro/yabause.git"
libretro_yabasanshiro_build_subdir="yabause/src/libretro"
libretro_yabasanshiro_post_fetch_cmd="git checkout yabasanshiro"

include_core_yabause() {
	register_module core "yabause" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_yabause_name="Yabause"
libretro_yabause_git_url="https://github.com/libretro/yabause.git"
libretro_yabause_build_subdir="yabause/src/libretro"

include_core_dosbox() {
	register_module core "dosbox" -ngc -ps3 -psp1 -wii
}
libretro_dosbox_name="DOSBox"
libretro_dosbox_git_url="https://github.com/libretro/dosbox-libretro.git"
libretro_dosbox_makefile="Makefile.libretro"

include_core_dosbox_core() {
	register_module core "dosbox_core" -ngc -ps3 -psp1 -wii
}
libretro_dosbox_core_name="DOSBox Core"
libretro_dosbox_core_git_url="https://github.com/libretro/dosbox-core.git"
libretro_dosbox_core_build_subdir="libretro"
libretro_dosbox_core_makefile="Makefile.libretro"

include_core_dosbox_svn() {
	register_module core "dosbox_svn" -ngc -ps3 -psp1 -wii
}
libretro_dosbox_svn_name="DOSBox SVN"
libretro_dosbox_svn_git_url="https://github.com/libretro/dosbox-svn.git"
libretro_dosbox_svn_git_submodules="yes"
libretro_dosbox_svn_makefile="Makefile.libretro"
libretro_dosbox_svn_build_subdir="libretro"
libretro_dosbox_svn_build_args="WITH_FAKE_SDL=1"

include_core_dosbox_svn_ce() {
	register_module core "dosbox_svn_ce" -ngc -ps3 -psp1 -wii
}
libretro_dosbox_svn_ce_name="DOSBox SVN CE"
libretro_dosbox_svn_ce_git_url="https://github.com/libretro/dosbox-svn.git"
libretro_dosbox_svn_ce_git_submodules="yes"
libretro_dosbox_svn_ce_makefile="Makefile.libretro"
libretro_dosbox_svn_ce_build_subdir="libretro"
libretro_dosbox_svn_ce_build_args="WITH_FAKE_SDL=1"
libretro_dosbox_svn_ce_post_fetch_cmd="git checkout community-patches"


include_core_dosbox_pure() {
	register_module core "dosbox_pure" -ngc -ps3 -psp1 -wii
}
libretro_dosbox_pure_name="DOSBox Pure"
libretro_dosbox_pure_git_url="https://github.com/libretro/dosbox-pure.git"
libretro_dosbox_pure_git_submodules="yes"
libretro_dosbox_pure_makefile="Makefile"

include_core_basilisk2() {
	register_module core "basilisk2" -ngc -ps3 -psp1 -wii
}
libretro_basilisk2_name="Basilisk II"
libretro_basilisk2_git_url="https://github.com/libretro/Basilisk2.git"
libretro_basilisk2_build_subdir="BasiliskII/src/libretro"
libretro_basilisk2_makefile="Makefile.libretro"

include_core_virtualjaguar() {
	register_module core "virtualjaguar" -ngc -ps3 -psp1 -wii
}
libretro_virtualjaguar_name="Virtual Jaguar"
libretro_virtualjaguar_git_url="https://github.com/libretro/virtualjaguar-libretro.git"
libretro_virtualjaguar_makefile="Makefile"

include_core_mame2000() {
	register_module core "mame2000" -theos_ios -ngc -psp1 -wii
}
libretro_mame2000_name="MAME 2000 (0.37b5)"
libretro_mame2000_git_url="https://github.com/libretro/mame2000-libretro.git"
libretro_mame2000_makefile="Makefile"

include_core_mame2003() {
	register_module core "mame2003" -theos_ios -ngc -psp1 -wii
}
libretro_mame2003_name="MAME 2003 (0.78)"
libretro_mame2003_git_url="https://github.com/libretro/mame2003-libretro.git"
libretro_mame2003_makefile="Makefile"

include_core_mame2003_plus() {
	register_module core "mame2003_plus" -theos_ios -ngc -psp1 -wii
}
libretro_mame2003_plus_name="MAME 2003 Plus (0.78)"
libretro_mame2003_plus_git_url="https://github.com/libretro/mame2003-plus-libretro.git"
libretro_mame2003_plus_makefile="Makefile"

include_core_mame2003_midway() {
	register_module core "mame2003_midway" -theos_ios -ngc -psp1 -wii
}
libretro_mame2003_midway_name="MAME 2003 Midway (0.78)"
libretro_mame2003_midway_git_url="https://github.com/libretro/mame2003_midway.git"
libretro_mame2003_midway_makefile="Makefile"

include_core_mame2010() {
	register_module core "mame2010"
}
libretro_mame2010_name="MAME 2010 (0.139)"
libretro_mame2010_git_url="https://github.com/libretro/mame2010-libretro.git"
libretro_mame2010_makefile="Makefile"

include_core_mame2015() {
	register_module core "mame2015" -theos_ios -ngc -psp1 -wii
}
libretro_mame2015_name="MAME 2015 (0.160)"
libretro_mame2015_git_url="https://github.com/libretro/mame2015-libretro.git"
libretro_mame2015_makefile="Makefile"

include_core_mame2016() {
	register_module core "mame2016" -theos_ios -ngc -psp1 -wii
}
libretro_mame2016_name="MAME 2016 (0.174)"
libretro_mame2016_git_url="https://github.com/libretro/mame2016-libretro.git"
libretro_mame2016_makefile="Makefile"

include_core_hbmame() {
	register_module core "hbmame"
}
libretro_hbmame_name="Home Brew MAME"
libretro_hbmame_git_url="https://github.com/libretro/hbmame-libretro.git"
libretro_hbmame_makefile="Makefile.libretro"

include_core_mame() {
	register_module core "mame" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_mame_name="MAME (git)"
libretro_mame_git_url="https://github.com/libretro/mame.git"
libretro_mame_build_makefile=Makefile.libretro
libretro_mame_build_compiler="REALCC=\"${CC:-cc}\" CC=\"${CXX:-c++}\""
libretro_mame_build_makefile_targets="TARGET=\"mame\""
libretro_mame_build_cores="mame"

include_core_ffmpeg() {
	register_module core "ffmpeg" -ios -theos_ios -osx -ngc -ps3 -psp1 -qnx -wii
}
libretro_ffmpeg_name="FFmpeg"
libretro_ffmpeg_git_url="https://github.com/libretro/FFmpeg.git"
libretro_ffmpeg_build_subdir="libretro"
libretro_ffmpeg_build_opengl="optional"

include_core_bsnes_cplusplus98() {
	register_module core "bsnes_cplusplus98" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_bsnes_cplusplus98_name="bsnes C++98 (v0.85)"
libretro_bsnes_cplusplus98_git_url="https://github.com/libretro/bsnes-libretro-cplusplus98.git"

include_core_bsnes_mercury_accuracy() {
	register_module core "bsnes_mercury_accuracy" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_bsnes_mercury_accuracy_name="bsnes/higan Mercury (Accuracy)"
libretro_bsnes_mercury_accuracy_git_url="https://github.com/libretro/bsnes-mercury.git"
libretro_bsnes_mercury_accuracy_build_args="compiler=\"${CXX11}\" PROFILE=\"accuracy\""

include_core_bsnes_mercury_balanced() {
	register_module core "bsnes_mercury_balanced" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_bsnes_mercury_balanced_name="bsnes/higan Mercury (Balanced)"
libretro_bsnes_mercury_balanced_git_url="https://github.com/libretro/bsnes-mercury.git"
libretro_bsnes_mercury_balanced_build_args="compiler=\"${CXX11}\" PROFILE=\"balanced\""

include_core_bsnes_mercury_performance() {
	register_module core "bsnes_mercury_performance" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_bsnes_mercury_performance_name="bsnes/higan Mercury (Performance)"
libretro_bsnes_mercury_performance_git_url="https://github.com/libretro/bsnes-mercury.git"
libretro_bsnes_mercury_performance_build_args="compiler=\"${CXX11}\" PROFILE=\"performance\""

include_core_neocd() {
	register_module core "neocd" -theos_ios -ngc -ps3 -wii
}
libretro_neocd_name="NeoCD"
libretro_neocd_git_url="https://github.com/libretro/neocd_libretro.git"
libretro_neocd_git_submodules="yes"
libretro_neocd_build_makefile="Makefile"

include_core_smsplus() {
	register_module core "smsplus" -theos_ios -ngc -ps3 -wii
}
libretro_smsplus_name="SMSPlus GX"
libretro_smsplus_git_url="https://github.com/libretro/smsplus-gx.git"
libretro_smsplus_build_makefile="Makefile.libretro"

include_core_picodrive() {
	register_module core "picodrive" -theos_ios -ngc -ps3 -wii
}
libretro_picodrive_name="Picodrive"
libretro_picodrive_git_url="https://github.com/libretro/picodrive.git"
libretro_picodrive_git_submodules="yes"
libretro_picodrive_build_makefile="Makefile.libretro"

include_core_tgbdual() {
	register_module core "tgbdual" -ngc -ps3 -wii
}
libretro_tgbdual_name="TGB Dual"
libretro_tgbdual_git_url="https://github.com/libretro/tgbdual-libretro.git"

include_core_theodore() {
	register_module core "theodore"
}
libretro_theodore_name="Theodore"
libretro_theodore_git_url="https://github.com/Zlika/theodore.git"

include_core_mesen() {
	register_module core "mesen"
}
libretro_mesen_name="Mesen"
libretro_mesen_git_url="https://github.com/libretro/Mesen.git"
libretro_mesen_build_subdir="Libretro"

include_core_mesens() {
	register_module core "mesens"
}
libretro_mesens_name="Mesen-S"
libretro_mesens_git_url="https://github.com/libretro/Mesen-S.git"
libretro_mesens_build_subdir="Libretro"

include_core_mupen64plus_next() {
	register_module core "mupen64plus_next" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_mupen64plus_next_name="Mupen64 Plus Next"
libretro_mupen64plus_next_git_url="https://github.com/libretro/mupen64plus-libretro-nx.git"
libretro_mupen64plus_next_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_mupen64plus_next_configure() {
	if iscpu_x86_64 $ARCH; then
		core_build_args="WITH_DYNAREC=x86_64"
	elif iscpu_x86 $ARCH; then
		core_build_args="WITH_DYNAREC=x86"
	elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "$platform" = "ios" ]; then
		core_build_args="WITH_DYNAREC=arm"
	fi
}

include_core_parallext() {
	register_module core "parallext" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_parallext_name="paraLLeXT"
libretro_parallext_git_url="https://github.com/libretro/paraLLeXT.git"
libretro_parallext_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_parallext_configure() {
	if iscpu_x86_64 $ARCH; then
		core_build_args="WITH_DYNAREC=x86_64"
	elif iscpu_x86 $ARCH; then
		core_build_args="WITH_DYNAREC=x86"
	elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "$platform" = "ios" ]; then
		core_build_args="WITH_DYNAREC=arm"
	fi
}

include_core_parallel_n64() {
	register_module core "parallel_n64" -theos_ios -ngc -ps3 -psp1 -wii
}
libretro_parallel_n64_name="Parallel N64"
libretro_parallel_n64_git_url="https://github.com/libretro/parallel-n64.git"
libretro_parallel_n64_build_platform="$FORMAT_COMPILER_TARGET_ALT"
libretro_parallel_n64_configure() {
	if iscpu_x86_64 $ARCH; then
		core_build_args="WITH_DYNAREC=x86_64"
	elif iscpu_x86 $ARCH; then
		core_build_args="WITH_DYNAREC=x86"
	elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "$platform" = "ios" ]; then
		core_build_args="WITH_DYNAREC=arm"
	fi
}

include_core_dinothawr() {
	register_module core "dinothawr" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_dinothawr_name="Dinothawr"
libretro_dinothawr_git_url="https://github.com/libretro/Dinothawr.git"
libretro_dinothawr_build_platform="$FORMAT_COMPILER_TARGET_ALT"

include_core_3dengine() {
	register_module core "3dengine" -ngc -sncps3 -ps3 -psp1 -wii
}
libretro_3dengine_name="3DEngine"
libretro_3dengine_git_url="https://github.com/libretro/libretro-3dengine.git"
libretro_3dengine_build_opengl=yes

include_core_remotejoy() {
	register_module core "remotejoy" -ngc -ps3 -psp1 -qnx -wii
}
libretro_remotejoy_name="RemoteJoy"
libretro_remotejoy_git_url="https://github.com/libretro/libretro-remotejoy.git"
libretro_remotejoy_build_makefile="Makefile"

include_core_bluemsx() {
	register_module core "bluemsx" -ps3
}
libretro_bluemsx_name="blueMSX"
libretro_bluemsx_git_url="https://github.com/libretro/blueMSX-libretro.git"
libretro_bluemsx_build_makefile="Makefile.libretro"

include_core_fmsx() {
	register_module core "fmsx" -ps3
}
libretro_fmsx_name="fMSX"
libretro_fmsx_git_url="https://github.com/libretro/fmsx-libretro.git"

include_core_2048() {
	register_module core "2048" -ngc -sncps3 -ps2 -ps3 -wii
}
libretro_2048_git_url="https://github.com/libretro/libretro-2048.git"
libretro_2048_build_makefile="Makefile.libretro"

include_core_vecx() {
	register_module core "vecx" -ngc -ps3 -wii
}
libretro_vecx_git_url="https://github.com/libretro/libretro-vecx.git"
libretro_vecx_build_makefile="Makefile.libretro"

include_core_citra() {
	register_module core "citra" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_citra_name="Citra"
libretro_citra_git_url="https://github.com/libretro/citra.git"
libretro_citra_git_submodules="yes"
libretro_citra_build_opengl="yes"

include_core_citra2018() {
	register_module core "citra2018" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_citra2018_name="Citra 2018"
libretro_citra2018_git_url="https://github.com/libretro/citra2018.git"
libretro_citra2018_git_submodules="yes"
libretro_citra2018_build_opengl="yes"

include_core_citra_canary() {
	register_module core "citra_canary" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_citra_canary_name="Citra Canary"
libretro_citra_canary_git_url="https://github.com/libretro/citra.git"
libretro_citra_canary_git_submodules="yes"
libretro_citra_canary_build_opengl="yes"

include_core_thepowdertoy() {
	register_module core "thepowdertoy" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_thepowdertoy_name="The Powder Toy"
libretro_thepowdertoy_git_url="https://github.com/libretro/ThePowderToy.git"
libretro_thepowdertoy_git_submodules="yes"

include_core_ppsspp() {
	register_module core "ppsspp" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_ppsspp_name="PPSSPP"
libretro_ppsspp_git_url="https://github.com/hrydgard/ppsspp.git"
libretro_ppsspp_git_submodules="yes"
libretro_ppsspp_build_subdir="libretro"
libretro_ppsspp_build_opengl="yes"

include_core_play() {
	register_module core "play" -ios -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_play_name="Play!"
libretro_play_git_url="https://github.com/libretro/Play-.git"
libretro_play_git_submodules="yes"
libretro_play_build_opengl="yes"
libretro_play_post_fetch_cmd="cd .. && git clone https://github.com/jpd002/Play-.git Play_tmp && cd Play_tmp && git submodule update -q --init --recursive && git submodule foreach \"git checkout -q master\" && cd deps && git submodule update --init && cd ../.. && rm -rf Play_tmp/Play && mv libretro-play/ Play_tmp/Play && mv Play_tmp libretro-play"
libretro_play_subdir="libretro-play/Play/build_retro"

include_core_prosystem() {
	register_module core "prosystem" -ngc -ps3 -wii
}
libretro_prosystem_name="ProSystem"
libretro_prosystem_git_url="https://github.com/libretro/prosystem-libretro.git"

include_core_o2em() {
	register_module core "o2em" -ngc -ps3 -wii
}
libretro_o2em_name="O2EM"
libretro_o2em_git_url="https://github.com/libretro/libretro-o2em.git"

include_core_opera() {
	register_module core "opera" -ngc -sncps3 -ps3 -psp1 -wii
}
libretro_opera_name="Opera"
libretro_opera_git_url="https://github.com/libretro/opera-libretro.git"

include_core_stonesoup() {
	register_module core "stonesoup" -ngc -ps3 -psp1 -qnx -wii
}
libretro_stonesoup_name="Dungeon Crawl Stone Soup"
libretro_stonesoup_git_url="https://github.com/libretro/crawl-ref.git"
libretro_stonesoup_git_submodules="clone"
libretro_stonesoup_build_subdir="crawl-ref"
libretro_stonesoup_build_makefile="Makefile.libretro"

include_core_freechaf() {
	register_module core "freechaf" -ngc -ps3 -psp1 -qnx -wii
}
libretro_freechaf_name="FreeChaF"
libretro_freechaf_git_url="https://github.com/libretro/FreeChaF.git"
libretro_freechaf_build_makefile="Makefile"
libretro_freechaf_git_submodules="yes"

include_core_hatari() {
	register_module core "hatari" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_hatari_name="Hatari"
libretro_hatari_git_url="https://github.com/libretro/hatari.git"
libretro_hatari_build_makefile="Makefile.libretro"

include_core_tempgba() {
	register_module core "tempgba" -psp1
}
libretro_tempgba_name="TempGBA"
libretro_tempgba_git_url="https://github.com/libretro/TempGBA-libretro.git"

include_core_gpsp() {
	register_module core "gpsp" -ngc -sncps3 -ps3 -psp1 -wii
}
libretro_gpsp_name="gpSP"
libretro_gpsp_git_url="https://github.com/libretro/gpsp.git"

include_core_emux() {
	register_module core "emux" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_emux_name="Emux"
libretro_emux_git_url="https://github.com/libretro/emux.git"
libretro_emux_build_subdir=libretro
libretro_emux_build_cores="emux_chip8 emux_gb emux_nes emux_sms"

include_core_fuse() {
	register_module core "fuse" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_fuse_name="Fuse"
libretro_fuse_git_url="https://github.com/libretro/fuse-libretro.git"
libretro_fuse_build_makefile="Makefile.libretro"
libretro_fuse_build_platform="$FORMAT_COMPILER_TARGET_ALT"

include_core_gw() {
	register_module core "gw" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_gw_name="Game & Watch"
libretro_gw_git_url="https://github.com/libretro/gw-libretro.git"
libretro_gw_git_submodules="yes"
libretro_gw_build_makefile="Makefile.libretro"

include_core_chailove() {
	register_module core "chailove" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_chailove_name="ChaiLove"
libretro_chailove_git_url="https://github.com/libretro/ChaiLove.git"
libretro_chailove_git_submodules="yes"
libretro_chailove_build_makefile="Makefile"

include_core_81() {
	register_module core "81" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_81_name="81"
libretro_81_git_url="https://github.com/libretro/81-libretro.git"
libretro_81_build_makefile="Makefile.libretro"

include_core_lutro() {
	register_module core "lutro" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_lutro_name="Lutro"
libretro_lutro_git_url="https://github.com/libretro/libretro-lutro.git"
libretro_lutro_build_makefile="Makefile"

include_core_pokemini() {
	register_module core "pokemini" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_pokemini_name="PokeMini"
libretro_pokemini_git_url="https://github.com/libretro/PokeMini.git"
libretro_pokemini_build_makefile="Makefile"

include_core_nekop2() {
	register_module core "nekop2" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_nekop2_name="Neko Project II"
libretro_nekop2_git_url="https://github.com/libretro/libretro-meowPC98.git"
libretro_nekop2_build_subdir="libretro"
libretro_nekop2_build_makefile="Makefile.libretro"

include_core_np2kai() {
	register_module core "np2kai" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_np2kai_name="Neko Project II"
libretro_np2kai_git_url="https://github.com/libretro/NP2kai.git"
libretro_np2kai_build_subdir="sdl"
libretro_np2kai_build_makefile="Makefile.libretro"

include_core_px68k() {
	register_module core "px68k" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_px68k_name="PX68K"
libretro_px68k_git_url="https://github.com/libretro/px68k-libretro.git"
libretro_px68k_build_makefile="Makefile.libretro"

include_core_uw8() {
	register_module core "uw8" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_uw8_name="MicroW8"
libretro_uw8_git_url="https://github.com/libretro/uw8-libretro.git"
libretro_uw8_git_submodules="yes"
libretro_uw8_build_makefile="Makefile"

include_core_uzem() {
	register_module core "uzem" -theos_ios -ngc -ps3 -psp1 -qnx -wii
}
libretro_uzem_name="Uzem"
libretro_uzem_git_url="https://github.com/libretro/libretro-uzem.git"
libretro_uzem_build_makefile="Makefile.libretro"

include_core_atari800() {
	register_module core "atari800" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_atari800_name="Atari800"
libretro_atari800_git_url="https://github.com/libretro/libretro-atari800.git"
libretro_atari800_build_makefile="Makefile"

include_core_a5200() {
	register_module core "a5200" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_a5200_name="A5200"
libretro_a5200_git_url="https://github.com/libretro/a5200.git"
libretro_a5200_build_makefile="Makefile"

include_core_samecdi() {
	register_module core "samecdi" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_samecdi_name="SameCDi"
libretro_samecdi_git_url="https://github.com/libretro/same_cdi.git"
libretro_samecdi_build_makefile="Makefile.libretro"
libretro_samecdi_build_cores="same_cdi"

include_core_vemulator() {
	register_module core "vemulator" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_vemulator_name="VEmulator"
libretro_vemulator_git_url="https://github.com/libretro/vemulator-libretro.git"
libretro_vemulator_build_makefile="Makefile"

include_core_mu() {
	register_module core "mu" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_mu_name="Mu"
libretro_mu_git_url="https://github.com/libretro/Mu.git"
libretro_mu_build_makefile="Makefile"
libretro_mu_build_subdir="libretroBuildSystem"

include_core_tic80() {
	register_module core "tic80" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_tic80_name="TIC-80"
libretro_tic80_git_url="https://github.com/libretro/TIC-80.git"
libretro_tic80_git_submodules="yes"
libretro_tic80_build_makefile="Makefile"
libretro_tic80_build_subdir="build"

include_core_lowresnx() {
	register_module core "lowresnx" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_lowresnx_name="LowRes NX"
libretro_lowresnx_git_url="https://github.com/timoinutilis/lowres-nx.git"
libretro_lowresnx_build_makefile="Makefile"
libretro_lowresnx_build_subdir="platform/LibRetro"

include_core_squirreljme() {
	register_module core "squirreljme"
}
libretro_squirreljme_name="SquirrelJME"
libretro_squirreljme_git_url="https://github.com/XerTheSquirrel/SquirrelJME.git"
libretro_squirreljme_build_makefile="makefilelibretro"
libretro_squirreljme_build_subdir="ratufacoat"

include_core_quasi88() {
	register_module core "quasi88" -theos_ios -ngc -sncps3 -ps3 -psp1 -qnx -wii
}
libretro_quasi88_name="QUASI88"
libretro_quasi88_git_url="https://github.com/libretro/quasi88-libretro.git"
libretro_quasi88_build_makefile="Makefile"

include_core_ep128emu_core() {
	register_module core "ep128emu_core"
}
libretro_ep128emu_core_name="ep128emu"
libretro_ep128emu_core_git_url="https://github.com/libretro/ep128emu-core.git"

include_core_freej2me() {
	register_module core "freej2me"
}
libretro_freej2me_name="freej2me"
libretro_freej2me_git_url="https://github.com/hex007/freej2me.git"
libretro_freej2me_build_subdir="src/libretro"

include_core_gearcoleco() {
	register_module core "gearcoleco"
}
libretro_gearcoleco_name="Gearcoleco"
libretro_gearcoleco_git_url="https://github.com/drhelius/Gearcoleco.git"
libretro_gearcoleco_build_subdir="platforms/libretro"

include_core_gong() {
	register_module core "gong"
}
libretro_gong_name="Gong"
libretro_gong_git_url="https://github.com/libretro/gong.git"
libretro_gong_build_makefile="Makefile.libretro"

include_core_jaxe() {
	register_module core "jaxe"
}
libretro_jaxe_name="JAXE"
libretro_jaxe_git_url="https://github.com/kurtjd/jaxe.git"
libretro_jaxe_build_makefile="Makefile.libretro"
libretro_jaxe_git_submodules="yes"

include_core_jumpnbump() {
	register_module core "jumpnbump"
}
libretro_jumpnbump_name="Jump n Bump"
libretro_jumpnbump_git_url="https://github.com/libretro/jumpnbump-libretro.git"

include_core_redbook() {
	register_module core "redbook"
}
libretro_redbook_name="redbook"
libretro_redbook_git_url="https://github.com/libretro/redbook.git"

include_core_pascal_pong() {
	register_module core "pascal_pong"
}
libretro_pascal_pong_name="pascal_pong"
libretro_pascal_pong_git_url="https://github.com/libretro/pascal-pong-libretro.git"

include_core_superbroswar() {
	register_module core "superbroswar"
}
libretro_superbroswar_name="superbroswar"
libretro_superbroswar_git_url="https://github.com/libretro/superbroswar-libretro.git"
libretro_superbroswar_build_makefile="Makefile.libretro"
libretro_superbroswar_git_submodules="yes"

include_core_vaporspec() {
	register_module core "vaporspec"
}
libretro_vaporspec_name="Vapor Spec"
libretro_vaporspec_git_url="https://github.com/minkcv/vm.git"
libretro_vaporspec_build_subdir="machine"
libretro_vaporspec_build_makefile="Makefile.libretro"
libretro_vaporspec_git_submodules="yes"

include_core_bk() {
	register_module core "bk"
}
libretro_bk_name="bk"
libretro_bk_git_url="https://github.com/libretro/bk-emulator.git"
libretro_bk_build_makefile="Makefile.libretro"

include_core_onscripter() {
	register_module core "onscripter"
}
libretro_onscripter_name="ONScripter"
libretro_onscripter_git_url="https://github.com/iyzsong/onscripter-libretro.git"
libretro_onscripter_git_submodules="yes"
libretro_onscripter_post_fetch_cmd="./update-deps.sh"
libretro_onscripter_build_makefile="Makefile"

include_core_virtualxt() {
	register_module core "virtualxt"
}
libretro_virtualxt_name="VirtualXT"
libretro_virtualxt_git_url="https://github.com/andreas-jonsson/virtualxt.git"
libretro_virtualxt_post_fetch_cmd="git checkout release"
libretro_virtualxt_build_subdir="tools/package/libretro"


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
# For the generic makefile build rule:
#
# build_makefile			Name of makefile
#								If unset, GNU make has rules for default makefile names
#
# build_subdir				The subdir containing the makefile, if any
#
# build_args				Any extra arguments to pass to make
#
# build_platform			Set to override the default platform
#								(e.g., $FORMAT_COMPILER_TARGET_ALT)
#
# build_opengl				Set to "optional" to use OpenGL/GLES if available
#								Set to "yes" if the core requires it
#
# build_cores				String containing the core(s) produced
#								Defaults to "<core>"
#
# build_products			Directory build products are located in
#								bsnes puts cores in "out" for some reason
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
