# vim: set ts=3 sw=3 noet ft=sh : bash

# fetch_git: Clones or pulls updates from a git repository into a local directory
#
# $1	The URI to fetch
# $2	The local directory to fetch to (relative)
# $3	Recurse submodules (yes, no, clone)
#
# NOTE: git _now_ has a -C argument that would replace the cd commands in
#       this rule, but this is a fairly recent addition to git, so we can't
#       use it here.  --iKarith
fetch_git() {
	fetch_dir="$WORKDIR/$2"
	if [ -d "$fetch_dir/.git" ]; then
		echo_cmd "cd \"$fetch_dir\""
		echo_cmd "git pull"
		if [ "$3" = "yes" ]; then
			echo_cmd "git submodule foreach git pull origin master"
		fi
	else
		clone_type=
		[ -n "$SHALLOW_CLONE" ] && depth="--depth 1 "
		echo_cmd "git clone $depth\"$1\" \"$WORKDIR/$2\""
		if [[ "$3" = "yes" || "$3" = "clone" ]]; then
			echo_cmd "cd \"$fetch_dir\""
			echo_cmd "git submodule update --init --recursive"
		fi
	fi
}

# fetch_revision_git: Output the hash of the last commit in a git repository
#
# $1	Local directory to run git in
fetch_revision_git() {
	[ -n "$1" ] && cd "$1"
	git log -n 1 --pretty=format:%H
}

local_files_git() {
	git diff-files --quiet --ignore-submodules
	return $?
}

# fetch_revision: Output SCM-dependent revision string of a module
#                 (currently just calls fetch_revision_git)
#
# $1	The directory of the module
fetch_revision() {
	   fetch_revision_git $1
}

module_get_revision() {
	if [ -d "$WORKDIR/$module_dir" ]; then
		cd "$WORKDIR/$module_dir"
		case "$module_fetch_rule" in
			git)
				if [ -n "$1" ]; then
					git diff-files --quiet --ignore-submodules || echo -n "changed from "
				fi
				git log -n 1 --pretty=format:%H
				;;
			*) ;;
		esac
	fi
}
