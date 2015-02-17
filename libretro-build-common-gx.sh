# vim: set ts=3 sw=3 noet ft=sh : bash

build_libretro_fba()
{
	build_libretro_fb_alpha
	build_libretro_fba_cps1
	build_libretro_generic_makefile_subcore "fb_alpha" "fba_cores_cps2" "svn-old/trunk/fbacores/cps2" "makefile.libretro" ${FORMAT_COMPILER_TARGET}
	build_libretro_fba_neogeo
}
