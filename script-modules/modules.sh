# vim: set ts=3 sw=3 noet ft=sh : bash

register_module() {
	case "$1" in
		core|devkit|player)
			if [ -n "$2" ]; then
				eval "libretro_${1}s=\"\$libretro_${1}s $2::\""
			else
				echo "register_module:Trying to register a $1 without a name"
				exit 1
			fi
			;;
		*)
			echo "register_module:Unknown module type \"$1\""
			exit 1
			;;
	esac
}

register_core() {
	register_module core $@
}
