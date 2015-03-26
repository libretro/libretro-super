# vim: set ts=3 sw=3 noet ft=sh : bash

echo_cmd() {
	eval 'echo "$@"'
	eval "$@"
	return $?
}

find_tool() {
	while [ -n "$1" ]; do
		if [ -n "$1" ] && command -v "$1" > /dev/null; then
			echo "$1"
			return
		fi
		shift
	done
}

color() {
	[ -n "$NO_COLOR" ] && return

	echo -n "[0;${1:-0}m"
}


if [ ! -t 1 ]; then
	if [ -z "$FORCE_COLOR" ]; then
		NO_COLOR=1
	fi
fi
