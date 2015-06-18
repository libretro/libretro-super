# vim: set ts=3 sw=3 noet ft=sh : bash

register_module devkit "manifest" any
libretro_manifest_name="Devkit: libretro-manifest"
libretro_manifest_dir="libretro-devkit/libretro-manifest"
libretro_manifest_git_url="https://github.com/libretro/libretro-manifest.git"

register_module devkit "libretrodb" any
libretro_libretrodb_name="Devkit: libretrodb"
libretro_libretrodb_dir="libretro-devkit/libretrodb"
libretro_libretrodb_git_url="https://github.com/libretro/libretrodb.git"

register_module devkit "dat_pull" any
libretro_dat_pull_name="Devkit: libretro-dat-pull"
libretro_dat_pull_dir="libretro-devkit/libretro-dat-pull"
libretro_dat_pull_git_url="https://github.com/libretro/libretro-dat-pull.git"

register_module devkit "common" any
libretro_common_name="Devkit: libretro-common"
libretro_common_dir="libretro-devkit/libretro-common"
libretro_common_git_url="https://github.com/libretro/libretro-common.git"
