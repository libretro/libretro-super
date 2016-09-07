# vim: set ts=3 sw=3 noet ft=sh : bash

register_module() {
	mod_type="$1"
	mod_name="$2"
	shift 2

	case "$mod_type" in
		core|devkit|player|lutro)
			if [ -n "$mod_name" ]; then
				build_plats=""
				skip_plats=""
				while [ -n "$1" ]; do
					if [[ "$1" = -* ]]; then
						skip_plats="$skip_plats,$1"
					else
						build_plats="$build_plats,$1"
					fi
					shift
				done

				build_plats="${build_plats#,}"
				skip_plats="${skip_plats#,}"

				eval "libretro_${mod_type}s=\"\$libretro_${mod_type}s $mod_name:${build_plats:=any}:$skip_plats\""
				libretro_modules="$libretro_modules $mod_name:$build_plats:$skip_plats"
			else
				echo "register_module:Trying to register a $mod_type without a name"
				exit 1
			fi
			;;
		*)
			echo "register_module:Unknown module type \"$mod_type\""
			exit 1
			;;
	esac
}

can_build_module() {
	[ -n "$force" ] && return 0

	if [[ "$1" != *:*:* ]]; then
		# Not in <name>:<build>:<skip> format, assume error
		return 1
	fi

	build_plats="${1#*:}"
	build_plats="${build_plats%:*}"
	skip_plats="${1##*:}"

	if [ "$build_plats" != "any" ]; then
		# Module is exclusive to certain platforms
		if [[ "$platform" != *${build_plats}* ]]; then
			# And this isn't one of them.
			return 1
		fi
	fi

	if [[ "$skip_plats" = *${platform}* ]]; then
		# Module is disabled on this particular platform
		return 1
	fi

	return 0
}

find_module() {
	needle="$1"
	shift

	for haystack in $@; do
		if [[ "$needle" == $haystack:* ]]; then
			echo "$needle"
		fi
	done
}
