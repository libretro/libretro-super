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

# --- SNES emulator cores ---
include_core_snes9x2002
include_core_snes9x2005
include_core_snes9x2010
include_core_snes9x
include_core_bsnes_accuracy
include_core_bsnes_balanced
include_core_bsnes_performance
include_core_bsnes_cplusplus98
include_core_bsnes_mercury_accuracy
include_core_bsnes_mercury_balanced
include_core_bsnes_mercury_performance
include_core_mednafen_snes

# --- Dreamcast emulator cores ---
include_core_flycast
include_core_redream

# --- Genesis emulator cores ---
include_core_genesis_plus_gx
include_core_picodrive
include_core_blastem

# --- Master System cores ---
include_core_gearsystem

# --- Arcade emulator cores ---
include_core_fbneo
include_core_fbalpha2012
include_core_fbalpha2012_cps1
include_core_fbalpha2012_cps2
include_core_fbalpha2012_neogeo

# --- GBA emulator cores ---
include_core_vba_next
include_core_vbam
include_core_gpsp
include_core_meteor
include_core_mgba
include_core_mednafen_gba
include_core_tempgba

# --- NES emulator cores ---
include_core_fceumm
include_core_nestopia
include_core_quicknes
include_core_bnes
include_core_mesen

# --- Nintendo DS emulator cores ---
include_core_desmume
include_core_desmume2015
include_core_melonds

# --- Nintendo 3DS emulator cores ---
include_core_citra
include_core_citra_canary

# --- Game Boy/Color emulator cores ---
include_core_gambatte
include_core_sameboy
include_core_tgbdual
include_core_gearboy

# --- Atari 2600 emulator cores ---
include_core_stella
include_core_stella2014

# --- Atari 800 emulator cores ---
include_core_atari800

# --- Commodore 64 emulator cores ---
include_core_frodo
include_core_vice_x64
include_core_vice_x128
include_core_vice_xvic
include_core_vice_xplus4
# --- PlayStation1 emulator cores ---
include_core_mednafen_psx
include_core_pcsx_rearmed
include_core_pcsx1
include_core_rustation

# --- PlayStation2 emulator cores ---
#include_core_play

# --- MSX emulator cores ---
include_core_bluemsx
include_core_fmsx

# --- UAE ---
include_core_fsuae
include_core_puae

# --- Saturn cores ---
include_core_mednafen_saturn
include_core_kronos
include_core_yabause

# --- Atari Lynx emulator cores ---
include_core_mednafen_lynx
include_core_handy

# --- SNK Neo Geo Pocket/Color ---
include_core_mednafen_ngp

# --- NEC PC-Engine emulator cores ---
include_core_mednafen_pce_fast
include_core_mednafen_supergrafx

# --- NEC PC-FX emulator cores ---
include_core_mednafen_pcfx

# --- Bandai WonderSwan emulator cores ---
include_core_mednafen_wswan

# --- Virtual Boy emulator cores ---
include_core_mednafen_vb

# --- Atari Jaguar emulator cores ---
include_core_virtualjaguar

# --- DOS/PC/MAC emulator cores ---
include_core_basilisk2
include_core_dosbox
include_core_dosbox_svn
include_core_pcem

# --- MAME cores ---
include_core_mame2000
include_core_mame2003
include_core_mame2003_plus
include_core_mame2010
include_core_mame2015
include_core_mame2016
include_core_mame

# --- N64 emulator cores ---
include_core_mupen64plus
include_core_mupen64plus_next
include_core_parallext
include_core_parallel_n64

# --- Nintendo Gamecube/Wii cores ---
include_core_dolphin
include_core_ishiiruka

# --- Nintendo Pokemon Mini cores ---
include_core_pokemini

# --- Game & Watch cores ---
include_core_gw

# --- PPSSPP cores ---
include_core_ppsspp

# --- Atari ProSystem 7800 emulator cores ---
include_core_prosystem

# --- Odyssey 2 emulator cores ---
include_core_o2em

# --- 3DO emulator cores ---
include_core_4do

# --- ZX Spectrum emulator cores ---
include_core_fuse
include_core_81

# --- NEC PC-88 emulator cores ---
include_core_quasi88

# --- NEC PC-98 emulator cores ---
include_core_nekop2
include_core_np2kai

# --- Fairchild ChannelF cores ---
include_core_freechaf

# --- Sharp X-68000 emulator cores ---
include_core_px68k

include_core_hatari
include_core_emux
include_core_lutro
include_core_uzem

# --- Vectrex emulator cores ---
include_core_vecx

# --- Media player ---
include_core_ffmpeg

# --- Streaming ---
include_core_remotejoy

# --- Game engine cores ---
include_core_cannonball
include_core_reminiscence
include_core_easyrpg
include_core_tyrquake
include_core_prboom
include_core_xrick
include_core_openlara
include_core_nxengine
include_core_craft
include_core_mrboom
include_core_daphne
include_core_dinothawr
include_core_3dengine
include_core_2048
include_core_stonesoup
include_core_scummvm
include_core_chailove
include_core_thepowdertoy
include_core_tic80

# --- Miscellaneous cores ---
include_core_video_processor
include_core_gme
include_core_pocketcdg
include_core_crocods
include_core_cap32
include_core_mu
include_core_squirreljme
include_core_minivmac
include_core_oberon

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
include_devkit_sdl

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

