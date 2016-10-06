# vim: set ts=3 sw=3 noet ft=sh : bash

color() {
	[ -n "$use_color" ] && echo -n "[0;${1:-0}m"
}

secho() {
	echo "$@"
	[ -n "$log_file_only" ] && echo "$@" >&6
}

lecho() {
	[ -n "$LIBRETRO_LOG_SUPER" ] && echo "$@" >> $log_super
}

lsecho() {
	echo "$@"
	[ -n "$log_file_only" ] && echo "$@" >&6
	[ -n "$LIBRETRO_LOG_SUPER" ] && echo "$@" >> $log_super
}

echo_cmd() {
	eval 'echo "$@"'
	eval "$@"
	return $?
}

LIBRETRO_LOG_DIR="${LIBRETRO_LOG_DIR:-$WORKDIR/log}"
LIBRETRO_LOG_MODULE="${LIBRETRO_LOG_MODULE:-%s.log}"
LIBRETRO_LOG_SUPER="${LIBRETRO_LOG_SUPER:-libretro-super.log}"

libretro_log_init() {
	if [ -z "$LIBRETRO_LOG_SUPER" -a -z "$LIBRETRO_LOG_MODULE" ]; then
		return
	fi

	mkdir -p "$LIBRETRO_LOG_DIR"

	if [ -n "$LIBRETRO_LOG_SUPER" ]; then
		log_super="$LIBRETRO_LOG_DIR/$LIBRETRO_LOG_SUPER"
		# Redirecting : avoids dependency on trunc(1)
		[ -z "$LIBRETRO_LOG_APPEND" ] && : > $log_super
	fi
	# Module logs are truncated as they're opened in log_module_start
}

log_module_start() {
	if [ -n "$LIBRETRO_LOG_MODULE" ]; then
		printf -v log_module "$LIBRETRO_LOG_DIR/$LIBRETRO_LOG_MODULE" "$1"

		# Save stdout and stderr to fds 6 and 7
		exec 6>&1 7>&2

		# Redirecting : avoids dependency on trunc(1)
		[ -z "$LIBRETRO_LOG_APPEND" ] && : > $log_module

		# Output to screen and logfile in developer mode (if possible)
		if [[ -n "$LIBRETRO_DEVELOPER" && -n "${log_tee:=$(find_tool "tee")}" ]]; then
			exec >> $($log_tee -a $log_module) 2>&1
		else
			exec >> $log_module 2>&1
			log_file_only=1
		fi
	fi
}

log_module_stop() {
	if [ -n "$1" ]; then
		# There's a reason we're stopping
		lsecho "$@"
	fi
	if [ -n "$LIBRETRO_LOG_MODULE" ]; then
		# Restore stdout/stderr and close our copies
		exec 1>&6 2>&7 6>&- 7>&-
		log_file_only=""
	fi
	lsecho ""
}

# TODO: Move this into libretro_log_init once libretro-fetch is fixed
if [[ -n $FORCE_COLOR || -t 1 && -z "$NO_COLOR" ]]; then
	want_color=1
	use_color=1
else
	want_color=""
	use_color=""
fi
