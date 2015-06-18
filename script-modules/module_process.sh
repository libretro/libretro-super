# vim: set ts=3 sw=3 noet ft=sh : bash

###################################################################
#
# MODULE PROCESSING
#
###################################################################


# All of the module_* vars are set here before calling any other module
# processing actions
module_set_vars() {
	module_varname="$1"
	eval "module_name=\${libretro_${1}_name:-$1}"
	eval "module_dir=\${libretro_${1}_dir:-libretro-$1}"

	for func in configure preclean prepackage; do
		if [ "$(type -t libretro_${1}_$func 2> /dev/null)" = "function" ]; then
			eval "module_$func=libretro_${1}_$func"
		else
			eval "module_$func=do_nothing"
		fi
	done

	eval "module_fetch_rule=\${libretro_${1}_fetch_rule:-git}"
	case "$module_fetch_rule" in
		git)
			eval "git_url=\$libretro_${1}_git_url"
			eval "git_submodules=\$libretro_${1}_git_submodules"
			;;

		none) ;;

		*)
			echo "Unknown fetch rule for $1: \"$module_fetch_rule\"."
			;;
	esac

	eval "module_build_rule=\${libretro_${1}_build_rule:-generic_makefile}"

	# TODO: Do OpenGL better
	eval "module_build_opengl=\$libretro_${1}_build_opengl"
	module_opengl_type=""
	if [ -n "$module_build_opengl" ]; then
		if [ -n "$ENABLE_GLES" ]; then
			module_opengl_type="-gles"
		else
			module_opengl_type="-opengl"
		fi
	fi

	module_build_subdir=""
	case "$module_build_rule" in
		generic_makefile)
			eval "module_build_makefile=\$libretro_${1}_build_makefile"
			eval "module_build_subdir=\$libretro_${1}_build_subdir"
			eval "module_build_makefile_targets=\"\$libretro_${1}_build_makefile_targets\""
			eval "module_build_args=\$libretro_${1}_build_args"

			# TODO: change how $platform is done
			eval "module_build_platform=\${libretro_${1}_build_platform:-$FORMAT_COMPILER_TARGET}$opengl_type"

			eval "module_build_cores=\${libretro_${1}_build_cores:-$1}"
			eval "module_build_products=\$libretro_${1}_build_products"

			# TODO: this too...
			eval "module_build_compiler=\$libretro_${1}_build_compiler"
			;;

		legacy)
			eval "module_build_legacy=\$libretro_${1}_build_legacy"
			;;

		none) ;;

		*)
			echo "Unknown build rule for $1: \"$module_build_rule\"."
			;;
	esac

	module_build_dir="$WORKDIR/$module_dir${module_build_subdir:+/$module_build_subdir}"
}

module_fetch() {
	lsecho "Fetching ${module_varname}..."

	case "$module_fetch_rule" in
		git)
			if [ -z "$git_url" ]; then
				echo "module_fetch: No URL set to fetch $1 via git."
				exit 1
			fi
			fetch_git "$git_url" "$module_dir" "$git_submodules"
			;;

		none)
			# This module doesn't get fetched
			;;

		*)
			secho "module_fetch: Unknown fetch rule for $module_varname: \"$module_fetch_rule\"."
			return 1
			;;
	esac
}

module_clean() {
	if [ -z "$force" ] && ! can_build_module $1; then
		lsecho "Skipping clean, $module_varname is disabled on ${platform}..."
		return 0
	fi

	case "$module_build_rule" in
		generic_makefile)
			lsecho "Cleaning ${module_varname}..."
			echo_cmd "cd \"$module_build_dir\""

			make_cmdline="$MAKE"
			if [ -n "$module_build_makefile" ]; then
				make_cmdline="$make_cmdline -f $module_build_makefile"
			fi

			# TODO: Do $platform type stuff better (requires modding each core)
			make_cmdline="$make_cmdline platform=\"$module_build_platform\""

			[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"
			echo_cmd "$make_cmdline $module_build_args clean"
			return $?
			;;

		legacy)
			lsecho "Legacy rules cannot be cleaned separately, skipping..."
			;;

		none) 
			lsecho "No rule to clean ${module_varname}."
			;;

		*) ;;
	esac
}

module_compile() {
	if [ -z "$force" ] && ! can_build_module $1; then
		lsecho "Skipping compile, $module_varname is disabled on ${platform}..."
		return 0
	fi

	case "$module_build_rule" in
		generic_makefile)
			lsecho "Compiling ${module_varname}..."
			echo_cmd "cd \"$module_build_dir\""

			make_cmdline="$MAKE"
			if [ -n "$module_build_makefile" ]; then
				make_cmdline="$make_cmdline -f $module_build_makefile"
			fi

			# TODO: Do $platform type stuff better (requires modding each core)
			make_cmdline="$make_cmdline platform=\"$module_build_platform\""

			[ -n "$JOBS" ] && make_cmdline="$make_cmdline -j$JOBS"

			# TODO: Do this better too (only affects a few cores)
			if [ -n "$module_build_compiler" ]; then
				make_cmdline="$make_cmdline $module_build_compiler"
			else
				make_cmdline="$make_cmdline ${CC:+CC=\"$CC\"} ${CXX:+CXX=\"$CXX\"}"
			fi

			if [ -n "$module_build_makefile_targets" ]; then
				for target in $module_build_makefile_targets; do
					echo_cmd "$make_cmdline $module_build_args $target"
				done
			else
				echo_cmd "$make_cmdline $module_build_args"
			fi
			if [ $? -gt 0 ]; then
				build_fail="$build_fail$module_build_cores "
				return 1
			fi

			modules_copied=""
			for module in $module_build_cores; do
				module_src="${module_build_products:+$module_build_products/}$module$CORE_SUFFIX"
				module_dest="$module$CORE_SUFFIX"
				if [ -f "$module_src" ]; then
					build_success="$build_success$module "
					echo_cmd "cp \"$module_src\" \"$RARCH_DIST_DIR/$module_dest\""
					modules_copied="$modules_copied $module_dest"
				else
					build_fail="$build_fail$module "
				fi
			done
			return 0
			;;

		legacy)
			if [ -n "$module_build_legacy" ]; then
				lsecho "Warning: $module_varname hasn't been ported to a modern build rule yet."
				lsecho "Compiling $module_varname using legacy \"$module_build_legacy\"..."
				$module_build_legacy
				return $?
			else
				lsecho "module_compile: No legacy build rule for ${module_varname}."
				return 1
			fi
			;;

		none)
			lsecho "No rule to compile ${module_varname}."
			;;

		*) ;;
	esac
}

module_package() {
	if [ -n "$modules_copied" ]; then
		lsecho "Packaging ${module_varname}..."
		cd "$RARCH_DIST_DIR"
		# TODO: Packaging other than zip (deb, etc?)
		for module in $modules_copied; do
			zip -m9 "${module}.zip" $module
		done
	fi
}

module_process() {
	local module_changed

	if [[ "$libretro_modules" != *$1* ]]; then
		secho "$(color 34)=== $(color 1)$1 $(color 31)not found$(color)"
		lecho "=== $1 not found"
		lsecho ""
		return 1
	fi
	if module_set_vars ${1%%:*}; then
		secho "$(color 34)=== $(color 1)$module_name$(color)"
		lecho "=== $module_name"
	else
		secho "$(color 34)=== $color 1)$1 $(color 31)rule error$(color)"
		lecho "=== $1 rule error"
		return 1
	fi

	log_module_start $module_varname

	if [[ "$actions" = *fetch* ]]; then
		module_revision_old="$(module_get_revision)"
		if ! module_fetch $1; then
			log_module_stop "module_process: Unable to fetch ${module_varname}."
			return 1
		fi
	else
		module_revision_old="ASSUMED DIFFERENT"
	fi
	module_revision="$(module_get_revision 1)"
	if [ "0$skip_unchanged" -eq 1 ]; then
		if [ "$module_revision_old" != "$module_revision" ]; then
			module_changed=1
		else
			module_changed=""
		fi
	else
		module_changed=1
	fi

	if [[ -n "$module_changed" && "$actions" = *clean* ]]; then
		if ! $module_preclean; then
			log_module_stop "module_process: module_preclean for $module_varname failed."
			return 1
		fi
		if ! module_clean $1; then
			log_module_stop "module_process: Unable to clean ${module_varname}."
			return 1
		fi
	fi

	if [[ -n "$module_changed" && "$actions" = *compile* ]]; then
		if ! $module_configure; then
			log_module_stop "module_process: module_configure for $module_varname failed."
			return 1
		fi
		if ! module_compile $1; then
			log_module_stop "module_process: Unable to compile ${module_varname}."
			return 1
		fi
	fi

	if [[ -n "$module_changed" && "$actions" = *package* ]]; then
		if ! $module_prepackage; then
			log_module_stop "module_process: module_prepackage for $module_varname failed."
			return 1
		fi
		if ! module_package $1; then
			log_module_stop "module_process: Unable to package ${module_varname}."
			return 1
		fi
	fi

	log_module_stop
}
