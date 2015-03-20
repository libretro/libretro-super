# vim: set ts=3 sw=3 noet ft=sh : bash

# CPU identification
#
# All of these functions can be overridden by $1 for use in buildbots, etc.
# The rest are meant to replace test or [ in if statements.


# Use with $() syntax
host_cpu() {
	echo ${1:-`uname -m`}
}



iscpu_64bit() {
	case ${1:-`uname -m`} in
		x86_64|amd64) return 0 ;;
	esac
	return 1
}

iscpu_x86() {
   case ${1:-`uname -m`} in
      i386|i486|i586|i686|x86_64) return 0 ;;
      *) [ "${PROCESSOR_ARCHITEW6432}" = "AMD64" ] && return 0 ;;
   esac
	return 1
}

iscpu_x86_64() {
   case ${1:-`uname -m`} in
		x86_64|amd64) return 0 ;;
	esac
	return 1
}

iscpu_arm() {
   case ${1:-`uname -m`} in
      armv*) return 0 ;;
   esac
	return 1
}

iscpu_armv5() {
   [ "${1:-`uname -m`}" = "armv5tel" ] && return 0
	return 1
}

# Consider using armv6* here?
iscpu_armv6() {
	case ${1:-`uname -m`} in
		armv6l|armv6) return 0 ;;
	esac
	return 1
}

# Consider using armv7* here?
# armv7s is Apple A6 chip
iscpu_armv7() {
	case ${1:-`uname -m`} in
		armv7l|armv7|armv7s) return 0 ;;
	esac
	return 1
}
