#!/bin/bash

#--
# Load sql dump $1 (ask). Based on rks-db - implement custom _sql_load if missing.
# If flag=1 load dump without confirmation.
#
# @param sql dump
# @param flag
# shellcheck disable=SC2034
#--
function _sql_load {
	_require_program "rks-db"
	_require_file "$1"

	test "$2" = "1" && AUTOCONFIRM=y
	_confirm "load sql dump '$1'?" 1
	test "$CONFIRM" = "y" && rks-db load "$1" --q1=n --q2=y >/dev/null
}

