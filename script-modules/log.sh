# vim: set ts=3 sw=3 noet ft=sh : bash

color() {
	[ -n "$use_color" ] && echo -n "[0;${1:-0}m"
}

lecho() {
	if [ -n "$LIBRETRO_LOG_SUPER" ]; then
		echo "$@" >> $super_log
	fi
}


LIBRETRO_LOG_DIR="${LIBRETRO_LOG_DIR:-$WORKDIR/log}"
LIBRETRO_LOG_SUPER="${LIBRETRO_LOG_SUPER:-libretro-super.txt}"
LIBRETRO_LOG_CORE="${LIBRETRO_LOG_CORE:-%s.txt}"
mkdir -p "$LIBRETRO_LOG_DIR"
if [ -n "$LIBRETRO_LOG_SUPER" ]; then
	super_log="$LIBRETRO_LOG_DIR/$LIBRETRO_LOG_SUPER"
fi

if [[ -t 1 || -n $FORCE_COLOR ]]; then
	want_color=1
	use_color=1
else
	want_color=""
	use_color=""
fi
