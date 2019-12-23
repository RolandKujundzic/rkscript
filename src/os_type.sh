#!/bin/bash

#--
# Return linux, macos, cygwin if $1 is empty. 
# If $1 is set and != os_type abort otherwise return 0.
#
# @print string (abort if set and os_type != $1)
# @require _abort _require_program
# @print linux|macos|cygwin if $1 is empty
# @return bool
#--
function _os_type {
	local os=

	_require_program uname

	if [ "$(uname)" = "Darwin" ]; then
		os="macos"        
	elif [ "$OSTYPE" = "linux-gnu" ]; then
		os="linux"
	elif [ $(expr substr $(uname -s) 1 5) = "Linux" ]; then
		os="linux"
	elif [ $(expr substr $(uname -s) 1 5) = "MINGW" ]; then
		os="cygwin"
	fi

	if test -z "$1"; then
		echo $os
	elif test "$1" != "$os"; then
		_abort "$1 required (this is $os)"
	fi

	return 0
}
