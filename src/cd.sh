#!/bin/bash

#------------------------------------------------------------------------------
# Change to directory $1. If parameter is empty and _cd was executed before 
# change to last directory.
#
# @param path
# @export LAST_DIR
# @require _abort 
#------------------------------------------------------------------------------
function _cd {
	local has_realpath=`which realpath`

	if ! test -z "$has_realpath" && ! test -z "$1"; then
		local curr_dir=`realpath "$PWD"`
		local goto_dir=`realpath "$1"`

		if test "$curr_dir" = "$goto_dir"; then
			return
		fi
	fi

	echo "cd '$1'"

	if test -z "$1"
	then
		if ! test -z "$LAST_DIR"
		then
			_cd "$LAST_DIR"
			return
		else
			_abort "empty directory path"
		fi
	fi

	if ! test -d "$1"; then
		_abort "no such directory [$1]"
	fi

	LAST_DIR="$PWD"

	cd "$1" || _abort "cd '$1' failed"
}

