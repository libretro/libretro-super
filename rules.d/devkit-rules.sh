# vim: set ts=3 sw=3 noet ft=sh : bash

include_devkit_manifest () {
	register_module devkit "manifest" any
}
libretro_manifest_name="Devkit: libretro-manifest"
libretro_manifest_dir="libretro-devkit/libretro-manifest"
libretro_manifest_git_url="https://github.com/libretro/libretro-manifest.git"

include_devkit_dat_pull () {
	register_module devkit "dat_pull" any
}
libretro_dat_pull_name="Devkit: libretro-dat-pull"
libretro_dat_pull_dir="libretro-devkit/libretro-dat-pull"
libretro_dat_pull_git_url="https://github.com/libretro/libretro-dat-pull.git"

include_devkit_ari64_dynarec () {
	register_module devkit "ari64_dynarec" any
}
libretro_ari64_dynarec_name="Devkit: Ari64-dynarec"
libretro_ari64_dynarec_dir="libretro-devkit/libretro-ari64"
libretro_ari64_dynarec_git_url="https://github.com/libretro/ari64.git"

include_devkit_common () {
	register_module devkit "common" any
}
libretro_common_name="Devkit: libretro-common"
libretro_common_dir="libretro-devkit/libretro-common"
libretro_common_git_url="https://github.com/libretro/libretro-common.git"

include_devkit_samples () {
	register_module devkit "samples" any
}
libretro_samples_name="Devkit: libretro-samples"
libretro_samples_dir="libretro-devkit/libretro-samples"
libretro_samples_git_url="https://github.com/libretro/libretro-samples.git"

include_devkit_deps () {
	register_module devkit "deps" any
}
libretro_deps_name="Devkit: libretro-deps"
libretro_deps_dir="libretro-devkit/libretro-deps"
libretro_deps_git_url="https://github.com/libretro/libretro-deps.git"

include_devkit_retroluxury () {
	register_module devkit "retroluxury" any
}
libretro_retroluxury_name="Devkit: retroluxury"
libretro_retroluxury_dir="libretro-devkit/retroluxury"
libretro_retroluxury_git_url="https://github.com/libretro/retroluxury.git"

include_devkit_sdl () {
	register_module devkit "sdl" any
}
libretro_sdl_name="Devkit: sdl"
libretro_sdl_dir="libretro-devkit/sdl"
libretro_sdl_git_url="https://github.com/libretro/sdl-libretro.git"
