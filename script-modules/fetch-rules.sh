# vim: set ts=3 sw=3 noet ft=sh : bash

# fetch_git: Clones or pulls updates from a git repository into a local directory
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
		echo "cd \"$fetch_dir\""
		cd "$fetch_dir"
		echo "git pull"
		git pull
		if [ -n "$5" ]; then
			echo "git submodule foreach git pull origin master"
			git submodule foreach git pull origin master
		fi
	else
		echo "git clone \"$1\" \"$WORKDIR/$2\""
		git clone "$1" "$WORKDIR/$2"
		if [ -n "$4" ]; then
			echo "cd \"$fetch_dir\""
			cd "$fetch_dir"
			echo "git submodule update --init"
			git submodule update --init
		fi
	fi
}

# revision_git: # Output the hash of the last commit in a git repository
#
# $1	Local directory to run git in
revision_git() {
	cd "$WORKDIR/$1"
	git log -n 1 --pretty=format:%H
}

