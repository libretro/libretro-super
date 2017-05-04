# vim: set ts=3 sw=3 noet ft=sh : bash

# -------------------------------------------------------------------------------------------------
# Configure which cores to fetch/build/install
# -------------------------------------------------------------------------------------------------
# Uncomment each line to enable core fetch / Comment to disable
#
# Format: include_[core|devkit|lutro]_[core_name]

# -------------------------------------------------------------------------------------------------
# Console cores (rules.d/core-rules)
# -------------------------------------------------------------------------------------------------

# --- BSNES cores (Nintendo SNES emulator) ---
include_core_bsnes_accuracy
include_core_bsnes_balanced
include_core_bsnes_performance

include_core_easyrpg
include_core_gme

# --- Snex9x cores ---
include_core_snes9x2002
include_core_snes9x2005
include_core_snes9x2010
include_core_snes9x

# --- Reicast ---
include_core_reicast

# --- Genesis Plus GX ---
include_core_genesis_plus_gx

include_core_mgba
include_core_video_processor
include_core_pocketcdg

# --- Final Burn (arcade) ---
include_core_fbalpha
include_core_fbalpha2012
include_core_fbalpha2012_cps1
include_core_fbalpha2012_cps2
include_core_fbalpha2012_neogeo

include_core_blastem

# --- VBA cores ---
include_core_vba_next
include_core_vbam

include_core_handy
include_core_cap32

# --- UAE ---
include_core_fsuae
include_core_puae

include_core_openlara

include_core_bnes
include_core_fceumm
include_core_gambatte
include_core_sameboy
include_core_meteor
include_core_nxengine
include_core_prboom
include_core_mrboom
include_core_crocods
include_core_xrick
include_core_vice_x64
include_core_vice_x128
include_core_stella
include_core_desmume
include_core_melonds
include_core_quicknes
include_core_nestopia
include_core_craft
include_core_pcem
include_core_tyrquake
include_core_pcsx_rearmed
include_core_pcsx1

# --- Mednafen cores ---
include_core_mednafen_gba
include_core_mednafen_lynx
include_core_mednafen_ngp
include_core_mednafen_pce_fast
include_core_mednafen_supergrafx
include_core_mednafen_psx
include_core_mednafen_saturn
include_core_mednafen_pcfx
include_core_mednafen_snes
include_core_mednafen_vb
include_core_mednafen_wswan

include_core_rustation
include_core_scummvm
include_core_yabause
include_core_dosbox
include_core_virtualjaguar

# --- MAME cores ---
include_core_mame2000
include_core_mame2003
include_core_mame2010
include_core_mame2014
include_core_mame

include_core_ffmpeg
include_core_bsnes_cplusplus98
include_core_bsnes_mercury_accuracy
include_core_bsnes_mercury_balanced
include_core_bsnes_mercury_performance

# --- Picodrive ---
include_core_picodrive

include_core_tgbdual

# --- Mupen64 Plus cores ---
include_core_mupen64plus
include_core_parallel_n64

include_core_dinothawr
include_core_3dengine
include_core_remotejoy
include_core_bluemsx
include_core_fmsx
include_core_2048
include_core_vecx

# --- PPSSPP cores ---
include_core_ppsspp
include_core_psp1

include_core_prosystem
include_core_o2em
include_core_4do
include_core_stonesoup
include_core_hatari
include_core_tempgba
include_core_gpsp
include_core_emux
include_core_fuse
include_core_gw
include_core_81
include_core_lutro
include_core_nekop2
include_core_px68k
include_core_uzem

# -------------------------------------------------------------------------------------------------
# Devkits
# -------------------------------------------------------------------------------------------------
include_devkit_manifest
include_devkit_dat_pull
include_devkit_ari64_dynarec
include_devkit_common
include_devkit_samples
include_devkit_deps
include_devkit_retroluxury

# -------------------------------------------------------------------------------------------------
# Lutro
# -------------------------------------------------------------------------------------------------
include_lutro_sienna
include_lutro_platformer
include_lutro_pong
include_lutro_tetris
include_lutro_snake
include_lutro_iyfct
include_lutro_game_of_life
