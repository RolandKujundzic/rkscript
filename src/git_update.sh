#!/bin/bash

#--
# @deprecated use _git_update_php
# @param int flag (2^N, default=3)
# @require _msg _git_update_php
#--
function _git_update {
	_msg "DEPRECATED: use _git_update_php"
  _git_update_php $1
}

