#!/bin/bash

#--
# Update/Create git project. Use subdir (js/, php/, ...) for other git projects.
# For git parameter (e.g. [-b master --single-branch]) use global variable GIT_PARAMETER.
#
# Example: git_checkout rk@git.tld:/path/to/repo test
# - if test/ exists: cd test; git pull; cd ..
# - if ../../test: ln -s ../../test; call again (goto 1st case)
# - else: git clone rk@git.tld:/path/to/repo test
#
# @param git url
# @param local directory (optional, default = basename $1 without .git)
# @param after_checkout (e.g. "./run.sh build")
# @global CONFIRM_CHECKOUT (if =1 use positive confirm if does not exist) GIT_PARAMETER
# shellcheck disable=SC2086
#--
function _git_checkout {
	local curr git_dir
	curr="$PWD"
	git_dir="${2:-$(basename "$1" | sed -E 's/\.git$//')}"

	if test -d "$git_dir"; then
		_confirm "Update $git_dir (git pull)?" 1
	elif ! test -z "$CONFIRM_CHECKOUT"; then
		_confirm "Checkout $1 to $git_dir (git clone)?" 1
	fi

	if test "$CONFIRM" = "n"; then
		echo "Skip $1"
		return
	fi

	if test -d "$git_dir"; then
		_cd "$git_dir"
		echo "git pull $git_dir"
		git pull
		test -s .gitmodules && git submodule update --init --recursive --remote
		test -s .gitmodules && git submodule foreach "(git checkout master; git pull)"
		_cd "$curr"
	elif test -d "../../$git_dir/.git" && ! test -L "../../$git_dir"; then
		_ln "../../$git_dir" "$git_dir"
		_git_checkout "$1" "$git_dir"
	else
		echo -e "git clone $GIT_PARAMETER '$1' '$git_dir'\nEnter password if necessary"
		git clone $GIT_PARAMETER "$1" "$git_dir"

		if ! test -d "$git_dir/.git"; then
			_abort "git clone failed - no $git_dir/.git directory"
		fi

		if test -s "$git_dir/.gitmodules"; then
			_cd "$git_dir"
			test -s .gitmodules && git submodule update --init --recursive --remote
			test -s .gitmodules && git submodule foreach "(git checkout master; git pull)"
			_cd ..
		fi

		if ! test -z "$3"; then
			_cd "$git_dir"
			echo "run [$3] in $git_dir"
			$3
			_cd ..
		fi
	fi

	GIT_PARAMETER=
}

