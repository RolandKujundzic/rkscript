#!/bin/bash

#--
# Remove (purge) apt packages.
#
# @param $* package list
# @global RKBASH_DIR
# shellcheck disable=SC2048
#--
function _apt_remove {
	_run_as_root

	for a in $*; do
		_confirm "Run apt -y remove --purge $a" 1
		if test "$CONFIRM" = "y"; then
			apt -y remove --purge "$a" || _abort "apt -y remove --purge $a"
			_rm "$RKBASH_DIR/apt/$a"
		fi
	done

	_apt_clean
}

