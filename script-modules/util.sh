# vim: set ts=3 sw=3 noet ft=sh : bash

echo_cmd() {
	eval 'echo "$@"'
	eval "$@"
	return $?
}
