# vim: set ts=3 sw=3 noet ft=sh : bash

echo_cmd() {
	eval 'echo "$@"'
	eval "$@"
	return $?
}

color() {
	[ -n "$NO_COLOR" ] && return

	echo -ne "[0;${1:-0}m"
}


if [ ! -t 1 ]; then
	if [ -z "$FORCE_COLOR" ]; then
		NO_COLOR=1
	fi
fi
