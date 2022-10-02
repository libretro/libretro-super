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

# --- Utility functions ---
. "$BASE_DIR/libretro-config.sh"
. "$BASE_DIR/script-modules/log.sh"
. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"
. "$BASE_DIR/script-modules/module_base.sh"

# --- Rules for fetching things are in these files ---
. "$BASE_DIR/rules.d/core-rules.sh"
. "$BASE_DIR/rules.d/player-rules.sh"
. "$BASE_DIR/rules.d/devkit-rules.sh"
. "$BASE_DIR/rules.d/lutro-rules.sh"
. "$BASE_DIR/build-config.sh"

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
				if [[ "$SKIP_UNKNOWN_URL_FETCH" -ne 1 ]]; then
					exit 1
				else
					echo "libretro_fetch:Skipping core $1"
				fi
			fi

			eval "git_submodules=\$libretro_${1}_git_submodules"

			# TODO: Don't depend on fetch_rule being git
			echo "Fetching ${1}..."
			fetch_git "$git_url" "$module_dir" "$git_submodules"
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

libretro_players="retroarch"

if [ -n "$1" ]; then
	no_more_args=""
	while [ -n "$1" ]; do
		if [[ "$1" = -* && -z "$no_more_args" ]]; then
			case "$1" in
				--) no_more_args=1 ;;
				--shallow) export SHALLOW_CLONE=1;;
				--cores) fetch_cores="$libretro_cores" ;;
				--devkit) fetch_devkits="$libretro_devkits" ;;
				--lutro) fetch_lutros="$libretro_lutros" ;;
				--players) fetch_players="$libretro_players" ;;
				--retroarch) fetch_players="retroarch" ;;
				*) ;;
			esac
			shift
			continue
		fi

		fetch_cores="$fetch_cores $1"
		# Handle non-commands
		shift
	done
else
	# Make libretro-fetch.sh with no args behave traditionally by default
	fetch_cores="$libretro_cores"
	fetch_players="$libretro_players"
	fetch_devkit="$libretro_devkits"
fi

for a in $fetch_players; do
	libretro_fetch "${a%%:*}"
done

for a in $fetch_lutros; do
	libretro_fetch "${a%%:*}"
done

for a in $fetch_devkits; do
	libretro_fetch "${a%%:*}"
done

for a in $fetch_cores; do
	libretro_fetch "${a%%:*}"
done
