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
