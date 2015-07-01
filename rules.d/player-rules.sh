# vim: set ts=3 sw=3 noet ft=sh : bash

register_module player retroarch
libretro_retroarch_name="RetroArch"
libretro_retroarch_dir="retroarch"
libretro_retroarch_git_url="https://github.com/libretro/RetroArch.git"
libretro_retroarch_post_fetch_cmd="./fetch-submodules.sh"
