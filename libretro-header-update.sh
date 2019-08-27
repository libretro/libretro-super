#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

update_header()
{
	if [ -d "$1" ]; then
		if [ ! -f "$1/libretro.h" ]; then
			echo "=== ERROR updating $2 ==="
		else
			echo "=== Updating $2 ==="
			cp "libretro-arb/libretro.h" "$1/libretro.h"
			cd "$1"
			git add libretro.h
			git commit -m "Update libretro.h"
			git push
			cd -
		fi
	else
		echo "=== Skipping $2 because it is not checked out ==="
	fi
}

update_header_batch()
{
	if [ ! -f "$1/libretro.h" ]; then
		echo "=== ERROR updating $2 ==="
	else
		cp "libretro-arb/libretro.h" "$1/libretro.h"
		cd "$1"
		git add libretro.h
		cd -
	fi
}

fetch_project()
{
	echo "=== Fetching $3 ==="
	if [ -d "$2/.git" ]; then
		cd "$2"
		git pull
		cd ..
	else
		git clone "$1" "$2"
	fi
	echo "=== Fetched ==="
}

fetch_project "https://github.com/libretro/RetroArch.git" "retroarch" "libretro/libretro ARB"

update_header "retroarch" "RetroArch (1/55)"
#ignore bsnes; it's not on github, so we can't push to it
update_header "libretro-snes9x/libretro" "libretro/SNES9x (2/55)"
update_header "libretro-snes9x2010/libretro" "libretro/SNES9x-Next (3/55)"
update_header "libretro-genesis_plus_gx/libretro" "libretro/Genplus GX (4/55)"
update_header_batch "libretro-fbalpha2012/svn-current/trunk/src/burner/libretro"
update_header_batch "libretro-fbalpha2012_neogeo/src/burner/libretro"
update_header_batch "libretro-fbalpha2012_cps2/src/burner/libretro"
update_header_batch "libretro-fbalpha2012_neogeo/src/burner/libretro"
update_header "libretro-vba_next/libretro" "libretro/VBA Next (6/55)"
update_header "libretro-vbam/src/libretro" "libretro/VBA-M (7/55)"
update_header "libretro-handy/libretro" "libretro/Handy (8/55)"
update_header "libretro-bnes/libretro" "libretro/bNES (9/55)"
update_header "libretro-fceumm/src/drivers/libretro" "libretro/FCEUmm (10/55)"
update_header "libretro-gambatte/libgambatte/libretro" "libretro/Gambatte (11/55)"
update_header "libretro-meteor/libretro" "libretro/Meteor (12/55)"
update_header "libretro-nxengine/nxengine-1.0.0.4/libretro" "libretro/NX (12/55)"
update_header "libretro-prboom/libretro" "libretro/PRBoom (13/55)"
update_header "libretro-stella" "libretro/Stella (14/55)"
update_header "libretro-desmume/desmume/src/libretro" "libretro/Desmume (15/55)"
update_header "libretro-quicknes/libretro" "libretro/QuickNES (16/55)"
update_header "libretro-nestopia/libretro" "libretro/Nestopia (17/55)"
update_header "libretro-tyrquake/include" "libretro/tyrquake (18/55)"
update_header "libretro-pcsx_rearmed/frontend" "libretro/pcsx_rearmed (19/55)"
update_header "libretro-mednafen_gba" "libretro/Beetle GBA (20/55)"
update_header "libretro-mednafen_lynx" "libretro/Beetle Lynx (21/55)"
update_header "libretro-mednafen_ngp" "libretro/Beetle NGP (22/55)"
update_header "libretro-mednafen_pce_fast" "libretro/Beetle PCE Fast (23/55)"
update_header "libretro-mednafen_supergrafx" "libretro/Beetle SuperGrafx (24/55)"
update_header "libretro-mednafen_psx" "libretro/Beetle PSX (25/55)"
update_header "libretro-mednafen_pcfx" "libretro/Beetle PCFX (26/55)"
update_header "libretro-mednafen_snes" "libretro/Beetle bSNES (27/55)"
update_header "libretro-mednafen_vb" "libretro/Beetle VB (28/55)"
update_header "libretro-mednafen_wswan" "libretro/Beetle WSwan (29/55)"
update_header "libretro-scummvm/backends/platform/libretro" "libretro/scummvm (30/55)"
update_header "libretro-dosbox/libretro" "libretro/dosbox (32/55)"
update_header "libretro-virtualjaguar" "libretro/virtualjaguar (33/55)"
update_header "libretro-mame2003/src/libretro" "libretro/mame078 (34/55)"
update_header "libretro-mame2010/src/osd/retro" "libretro/mame139 (35/55)"
update_header "libretro-mame" "libretro/mame (36/55)"
update_header "libretro-ffmpeg/libretro" "libretro/FFmpeg (37/55)"
update_header "libretro-bsnes_cplusplus98/snes/libretro" "libretro/bsnes-cplusplus98 (38/55)"
update_header "libretro-bsnes_mercury/target-libretro" "libretro/bsnes-mercury (39/55)"
update_header "libretro-picodrive/platform/libretro" "libretro/picodrive (40/55)"
update_header "libretro-tgbdual/libretro" "libretro/tgbdual (41/55)"
update_header "libretro-mupen64plus/libretro" "libretro/mupen64plus (42/55)"
update_header "libretro-dinothawr" "libretro/Dinothawr (43/55)"
update_header "libretro-hatari/libretro" "libretro/Hatari (44/55)"
update_header "libretro-uae/sources/src/od-retro" "libretro/UAE (45/55)"
update_header "libretro-3dengine" "libretro/3DEngine (46/55)"
update_header "libretro-remotejoy/libretro" "libretro/RemoteJoy (47/55)"
update_header "libretro-bluemsx" "libretro/blueMSX (48/55)"
update_header "libretro-fmsx" "libretro/fmsx (49/55)"
update_header "libretro-2048" "libretro/2048 (50/55)"
update_header "libretro-vecx/libretro" "libretro/vecx (51/55)"
#ignoring libretro-manifest because it's not a core
update_header "libretro-ppsspp/libretro" "libretro/ppsspp (52/55)"
update_header "libretro-prosystem" "libretro/prosystem (53/55)"
update_header "libretro-o2em" "libretro/o2em (54/55)"
update_header "libretro-4do" "libretro/4do (55/55)"
