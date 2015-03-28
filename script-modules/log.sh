# vim: set ts=3 sw=3 noet ft=sh : bash

color() {
	[ -n "$use_color" ] && echo -n "[0;${1:-0}m"
}

lecho() {
	if [ -n "$LIBRETRO_LOG_SUPER" ]; then
		echo "$@" >> $log_super
	fi
}


LIBRETRO_LOG_DIR="${LIBRETRO_LOG_DIR:-$WORKDIR/log}"
LIBRETRO_LOG_CORE="${LIBRETRO_LOG_CORE:-%s.log}"
LIBRETRO_LOG_SUPER="${LIBRETRO_LOG_SUPER:-libretro-super.log}"
if [ -n "$LIBRETRO_LOG_SUPER" ]; then
	log_super="$LIBRETRO_LOG_DIR/$LIBRETRO_LOG_SUPER"
	[ -z "$LIBRETRO_LOG_APPEND" ] && : > $log_super
fi
# Core log can't be handled here

mkdir -p "$LIBRETRO_LOG_DIR"

if [[ -n $FORCE_COLOR || -t 1 && -z "$NO_COLOR" ]]; then
	want_color=1
	use_color=1
else
	want_color=""
	use_color=""
fi
