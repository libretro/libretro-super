# vim: set ts=3 sw=3 noet ft=sh : bash

# FIXME: This doesn't belong here, move it
echo_cmd() {
	echo "$@"
	"$@"
}


# fetch_git <repository> <local directory>
# Clones or pulls updates from a git repository into a local directory
#
# $1	The URI to fetch
# $2	The local directory to fetch to (relative)
# $3	Set to clone --recursive
# $4	Set to pull --recursive
fetch_git() {
	fetch_dir="$WORKDIR/$2"
	echo "=== Fetching $2 ==="
	if [ -d "$fetch_dir/.git" ]; then
		echo_cmd git -C "$fetch_dir" pull
		[ -n "$4" ]&& echo_cmd git -C "$fetch_dir" submodule foreach git pull origin master
	else
		echo_cmd git clone "$1" "$fetch_dir"
		[ -n "$3" ]&& 	echo_cmd git -C "$fetch_dir" submodule update --init
	fi
}

# revision_git <local directory>
# Output the hash of the last commit in a git repository
revision_git() {
	git -C "$WORKDIR/$1" log -n 1 --pretty=format:%H
}

