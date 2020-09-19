#!/bin/bash

#--
# Install composer (getcomposer.org). If no parameter is given ask for action
# or execute default action (install composer if missing otherwise update) after
# 10 sec. 
#
# @param [install|update|remove] (empty = default = update or install)
#--
function _composer {
	local action global_comp local_comp cmd
	global_comp=$(command -v composer)
	action="$1"

	test -f 'composer.phar' && local_comp=composer.phar

	if [[ -z "$global_comp" && -z "$local_comp" ]]; then
		_composer_install
		test "$action" = 'q' && return
	fi

	if test -z "$action"; then
		_composer_ask
		test "$action" = 'q' && return
	fi

	if test -n "$local_comp"; then
		cmd='php composer.phar'
	elif test -n "$global_comp"; then
		cmd='composer'
	fi

	if test -f composer.json; then
		if test "$action" = 'i'; then
			$cmd install
		elif test "$action" = 'u'; then
			$cmd update
		elif test "$action" = 'a'; then
			$cmd dump-autoload -o
		fi
	fi
}


#--
# Install composer globally or as ./composer.phar
# @global global_comp local_comp action
#--
function _composer_install {
	ASK_DESC="[g] = Global installation as /usr/local/bin/composer\n[l] = Local installation as ./composer.phar"
	_ask 'Install composer' '<g|l>'

	if test "$ANSWER" = 'g'; then
		echo 'install composer as /usr/local/bin/composer - Enter root password if asked'
		_composer_phar /usr/local/bin/composer
	elif test "$ANSWER" = 'l'; then
		echo 'install composer as ./composer.phar'
		_composer_phar
	else
		action='q'
	fi
}


#--
# @global action 
# shellcheck disable=SC2034
#--
function _composer_ask {
	if ! test -f 'composer.json'; then
		action='q'
		return
	fi

	ask='<i'
	ASK_DESC="[i] = install packages from composer.json"
	ASK_DEFAULT='i'

	if test -d 'vendor'; then
		ASK_DESC="$ASK_DESC\n[u] = update packages from composer.json\n[a] = update vendor/composer/autoload*"
		ASK_DEFAULT='u'
		ask="$ask|u|a"
	fi

	if test -f 'composer.phar'; then
		ask="$ask|r"
		ASK_DESC="$ASK_DESC\n[r] = remove local composer.phar"
	fi

	ASK_DESC="$ASK_DESC\n[q] = quit"
	_ask 'Composer action?' "$ask|q>" 1
	action=$ANSWER

	if test "$action" = "r"; then
		echo "remove composer"
		_rm "composer.phar vendor composer.lock ~/.composer"
		action='q'
	fi
}

