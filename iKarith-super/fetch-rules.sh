# vim: set ts=3 sw=3 noet ft=sh : bash

# FIXME: This doesn't belong here, move it
echo_cmd() {
	echo "$@"
	"$@"
}


# fetch_git
# Clones or pulls updates from a git repository into a local directory
#
# $1	The URI to fetch
# $2	The local directory to fetch to (relative)
# $3  The pretty name for the === Fetching line ("" to print nothing)
# $4	Set to clone --recursive
# $5	Set to pull --recursive
#
# NOTE: git _now_ has a -C argument that would replace the cd commands in
#       this rule, but this is a fairly recent addition to git, so we can't
#       use it here.  --iKarith
fetch_git() {
	fetch_dir="$WORKDIR/$2"
	[ -n "$3" ] && echo "=== Fetching $3 ==="
	if [ -d "$fetch_dir/.git" ]; then
		echo_cmd cd "$fetch_dir"
		echo_cmd git pull
		[ -n "$5" ] && echo_cmd git submodule foreach git pull origin master
	else
		echo_cmd cd "$WORKDIR"
		echo_cmd git clone "$1"
		if [ -n "$4" ]; then
			echo_cmd cd "$fetch_dir"
			echo_cmd git submodule update --init
		fi
	fi
}

# revision_git <local directory>
# Output the hash of the last commit in a git repository
revision_git() {
	git -C "$WORKDIR/$1" log -n 1 --pretty=format:%H
}

