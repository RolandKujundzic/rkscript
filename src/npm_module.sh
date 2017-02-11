#!/bin/bash

#------------------------------------------------------------------------------
# Install npm module $1 (globally if $2 = -g)
#
# @sudo
# @param package_name
# @param npm_param (e.g. -g, --save-dev)
#------------------------------------------------------------------------------
function _npm_module {
	local EXTRA_PARAM=

	if test "$1" = "ios-deploy"; then
		EXTRA_PARAM="--unsafe-perm=true --allow-root"
	fi

	if test "$2" = "-g"
	then
		if test -d /usr/local/lib/node_modules/$1
		then
			echo "node module $1 is already globally installed - updating"
			sudo npm update $EXTRA_PARAM -g $1
			return
		else
			echo "install node module $1 globally"
			sudo npm install $EXTRA_PARAM -g $1
			return
		fi
	fi

	if test -d node_modules/$1
	then
		echo "node module $1 is already installed - updating"
		npm update $EXTRA_PARAM $1
	return
	fi

	npm install $EXTRA_PARAM $1 $2
}
