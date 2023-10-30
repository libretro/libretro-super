default: upgrade fetch build

upgrade:
	@./libretro-upgrade.sh

fetch:
	@./libretro-fetch.sh

build:
	@./libretro-build.sh

install:
	@./libretro-install.sh

.PHONY: default