#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

BASE_DIR=$(pwd)
RARCH_DIR=$BASE_DIR/dist
RARCH_DIST_DIR=$RARCH_DIR/xdk1
FORMAT=_xdk
FORMAT_EXT=lib
MSVC_NAME=msvc-2003-xbox1
RELEASE_LTCG=Release_LTCG
RELEASE=Release

die()
{
	echo $1
	#exit 1
}

build_libretro_fba_cps1()
{
	cd $BASE_DIR
	if [ -d "libretro-fbalpha2012_cps1" ]; then
		echo "=== Building Final Burn Alpha Cores (CPS1) ==="
		cd libretro-fbalpha2012_cps1/
		cd projectfiles/visualstudio-2003-libretro-xbox1
		cmd.exe /k $MSVC_NAME.bat
		cp $RELEASE_LTCG/fbalpha2012_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fbalpha2012_cps1_libretro$FORMAT.${FORMAT_EXT}
	fi
}

build_libretro_fba_cps2()
{
	cd $BASE_DIR
	if [ -d "libretro-fbalpha2012_cps2" ]; then
		echo "=== Building Final Burn Alpha Cores (CPS2) ==="
		cd libretro-fbalpha2012_cps2/
		cd projectfiles/visualstudio-2003-libretro-xbox1
		cmd.exe /k $MSVC_NAME.bat
		cp $RELEASE_LTCG/libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fbalpha2012_cps2_libretro$FORMAT.${FORMAT_EXT}
	fi
}


build_libretro_fba_neogeo()
{
	cd $BASE_DIR
	if [ -d "libretro-fbalpha2012_neogeo" ]; then
		echo "=== Building Final Burn Alpha Cores (NeoGeo) ==="
		cd libretro-fbalpha2012_neogeo/
		cd projectfiles/visualstudio-2003-libretro-xbox1
		cmd.exe /k $MSVC_NAME.bat
		cp $RELEASE_LTCG/libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fbalpha2012_neogeo_libretro$FORMAT.${FORMAT_EXT}
	fi
}

build_libretro_fba()
{
	cd $BASE_DIR
	if [ -d "libretro-fbalpha2012" ]; then
		echo "=== Building Final Burn Alpha ==="
		cd libretro-fbalpha2012/
		cd svn-current/trunk
		cd projectfiles/visualstudio-2003-libretro-xbox1
		cmd.exe /k $MSVC_NAME.bat
		cp $RELEASE_LTCG/fbalpha2012_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR

		build_libretro_fba_cps1
		build_libretro_fba_cps2
		build_libretro_fba_neogeo
	else
		echo "Final Burn Alpha not fetched, skipping ..."
	fi
}

source $BASE_DIR/libretro-build-common-xdk.sh

if [ $1 ]; then
	$1
else
	build_libretro_2048
	build_libretro_4do
	#build_libretro_beetle_lynx
	#build_libretro_beetle_gba
	build_libretro_beetle_ngp
	#build_libretro_beetle_pce_fast
	#build_libretro_beetle_supergrafx
	#build_libretro_beetle_pcfx
	#build_libretro_mednafen_psx
	#build_libretro_beetle_vb
	#build_libretro_beetle_wswan
	#build_libretro_beetle_bsnes
	#build_libretro_snes9x2010
	build_libretro_snes9x
	#build_libretro_genesis_plus_gx
	#build_libretro_fba
	build_libretro_vba_next
	build_libretro_fceumm
	build_libretro_tgbdual
	build_libretro_quicknes
	#build_libretro_gambatte
	#build_libretro_nx
	build_libretro_o2em
	build_libretro_pocketcdg
	build_libretro_pokemini
	build_libretro_prosystem
	build_libretro_stella
	build_libretro_prboom
	build_libretro_nestopia
	#build_libretro_tyrquake
	build_libretro_vecx
fi
