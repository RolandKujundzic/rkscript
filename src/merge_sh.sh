#!/bin/bash

#--
# Merge "$APP"_ into $APP (concat "$APP""_/*.inc.sh").
#
# @global APP
# @require _require_file _require_dir _chmod _md5 _rm
#--
function _merge_sh {
	_require_file "$APP"
	local SH_DIR="$APP"'_'
	local TMP_APP="$APP"'__'
	_require_dir "$SH_DIR"

	local MD5_OLD=`_md5 "$APP"`
  echo -n "merge $SH_DIR into $APP ... "

	echo '#!/bin/bash' > "$TMP_APP"

	local a
	for a in "$SH_DIR"/*.inc.sh; do
		tail -n+2 "$a" >> "$TMP_APP"
  done

	local MD5_NEW=`_md5 "$TMP_APP"`

	if test "$MD5_OLD" = "$MD5_NEW"; then
		echo "no change"
		_rm "$TMP_APP" >/dev/null
	else
		echo "update"
		_mv "$TMP_APP" "$APP"
  	_chmod 755 "$APP"
	fi
}
