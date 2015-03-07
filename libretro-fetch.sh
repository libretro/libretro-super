#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR="$PWD"

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
else
	if [[ "$0" != /* ]]; then
		# Make the path absolute
		BASE_DIR="$WORKDIR/$BASE_DIR"
	fi
fi

. "$BASE_DIR/libretro-config.sh"
. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/modules.sh"

# Rules for fetching things are in these files:
. "$BASE_DIR/rules.d/core-rules.sh"
. "$BASE_DIR/rules.d/player-rules.sh"
. "$BASE_DIR/rules.d/devkit-rules.sh"
# TODO: Read these programmatically


# libretro_fetch: Download the given core using its fetch rules
#
# $1	Name of the core to fetch
libretro_fetch() {
	local module_name
	local module_dir
	local fetch_rule
	local post_fetch_cmd

	eval "module_name=\$libretro_${1}_name"
	[ -z "$module_name" ] && module_name="$1"
	echo "$(color 34)=== $(color 1)$module_name$(color)"

	eval "fetch_rule=\$libretro_${1}_fetch_rule"
	[ -z "$fetch_rule" ] && fetch_rule=git

	eval "module_dir=\$libretro_${1}_dir"
	[ -z "$module_dir" ] && module_dir="libretro-$1"

	case "$fetch_rule" in
		git)
			local git_url
			local git_submodules
			eval "git_url=\$libretro_${1}_git_url"
			if [ -z "$git_url" ]; then
				echo "libretro_fetch:No URL set to fetch $1 via git."
				exit 1
			fi

			eval "git_submodules=\$libretro_${1}_git_submodules"

			# TODO: Don't depend on fetch_rule being git
			echo "Fetching ${1}..."
			fetch_git "$git_url" "$module_dir" "$git_submodules"
			;;
	
		multi_git)
			local num_git_urls
			local git_url
			local git_subdir
			local git_submodules
			local i

			eval "num_git_urls=\${libretro_${1}_mgit_urls:-0}"
			if [ "$num_git_urls" -lt 1 ]; then
				echo "Cannot fetch \"$num_git_urls\" multiple git URLs"
				return 1
			fi

			[ "$module_dir" != "." ] && echo_cmd "mkdir -p \"$WORKDIR/$module_dir\""
			for (( i=0; i < $num_git_urls; ++i )); do
				eval "git_url=\$libretro_${1}_mgit_url_$i"
				eval "git_subdir=\$libretro_${1}_mgit_dir_$i"
				eval "git_submodules=\$libretro_${1}_mgit_submodules_$i"
				fetch_git "$git_url" "$module_dir/$git_subdir" "$git_submodules"
			done
			;;

		*)
			echo "libretro_fetch:Unknown fetch rule for $1: \"$fetch_rule\"."
			exit 1
			;;
	esac

	eval "post_fetch_cmd=\$libretro_${1}_post_fetch_cmd"
	if [ -n "$post_fetch_cmd" ]; then
		echo_cmd "cd \"$WORKDIR/$module_dir\""
		echo_cmd "$post_fetch_cmd"
	fi
}

if [ -n "$1" ]; then
	no_more_args=""
	while [ -n "$1" ]; do
		if [ -z "$no_more_args" ]; then
			case "$1" in
				--)
					no_more_args="1"
					;;

				*)
					# New style (just cores for now)
					libretro_fetch $1
					;;
			esac
		else
			libretro_fetch $1
		fi
		shift
	done
else
	libretro_fetch retroarch
	libretro_fetch devkit

	for a in $libretro_cores; do
		libretro_fetch "${a%%:*}"
	done
fi
