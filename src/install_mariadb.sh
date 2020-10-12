#!/bin/bash

#--
# Install mariadb server and client and php-mysql
# shellcheck disable=SC2119
#--
function _install_mariadb {
	_apt_update
	_apt_install 'mariadb-server mariadb-client php-mysql'
}
	
