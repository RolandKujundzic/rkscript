#!/bin/bash

#--
# Print $1 $2. If length $2 > 40 print [$1 $2:0:30 ... $2:-10].
# 
# @param string
# @param string
#--
function _print {
	if test ${#2} -gt 40; then
		echo "$1 ${2:0:30} ... ${2: -10}"
	else
		echo "$1 $2"
	fi
}

