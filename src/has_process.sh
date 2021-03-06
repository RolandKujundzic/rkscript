#!/bin/bash

declare -A PROCESS

#--
# Export PROCESS[pid|start|command]. Second parameter is 2^n flag:
#
#  - 2^0 = $1 is bash script (search for /[b]in/bash.+$1.sh)
#  - 2^1 = logfile PROCESS[log] must exists
#  - 2^2 = abort if process does not exists
#  - 2^3 = abort if process exists 
#  - 2^4 = logfile has PID=PROCESS_ID in first three lines or contains only pid
#
# If flag containts 2^1 search for logged process id.
#
# @param command (e.g. "convert", "rx:node https.js", "bash:/tmp/test.sh")
# @param flag optional 2^n value
# @option PROCESS[log]=$1.log if empty and (flag & 2^1 = 2) or (flag & 2^4 = 16)
# @export PROCESS[pid|start|command]
# shellcheck disable=SC2009,SC2154 
#--
function _has_process {
	local rx flag process logfile_pid
	flag=$(($2 + 0))

	case $1 in
		bash:*)
			rx="/[b]in/bash.+${1#*:}";;
		rx:*)
			rx="${1#*:}";;
		*)
			rx=" +[0-9\:]+ +[0-9\:]+ +.+[b]in.*/$1"
	esac

	if test $((flag & 1)) = 1; then
		rx="/[b]in/bash.+$1.sh"
	fi

	if [[ -z "${PROCESS[log]}" && ($((flag & 2)) = 2 || $((flag & 16)) = 16) ]]; then
		PROCESS[log]="$1.log"
	fi

	if test $((flag & 2)) = 2 && ! test -f "${PROCESS[log]}"; then
		_abort "no such logfile ${PROCESS[log]}"
	fi

	if test $((flag & 16)) = 16; then
		if test -s "${PROCESS[log]}" || test $((flag & 2)) = 2; then
			logfile_pid=$(head -3 "${PROCESS[log]}" | grep "PID=" | sed -e "s/PID=//" | grep -E '^[1-9][0-9]{0,4}$')

			if test -z "$logfile_pid"; then
				logfile_pid=$(grep -E '^[1-9][0-9]{0,4}$' "${PROCESS[log]}")
			fi

			if test -z "$logfile_pid"; then
				_abort "missing PID of [$1] in logfile ${PROCESS[log]}"
			fi
		else
			logfile_pid=-1
		fi
	fi
		
	if test -z "$logfile_pid"; then
		process=$(ps -aux | grep -E "$rx")
	else
		process=$(ps -aux | grep -E "$rx" | grep " $logfile_pid ")
	fi

	if [[ $((flag & 4)) = 4 && -z "$process" ]]; then
		_abort "no $1 process (rx=$rx, old_pid=$logfile_pid)"
	elif [[ $((flag & 8)) = 8 && -n "$process" ]]; then
		_abort "process $1 is already running (rx=$rx, old_pid=$logfile_pid)"
	fi
	
	PROCESS[pid]=$(echo "$process" | awk '{print $2}')
	PROCESS[start]=$(echo "$process" | awk '{print $9, $10}')
	PROCESS[command]=$(echo "$process" | awk '{print $11, $12, $13, $14, $15, $16, $17, $18, $19, $20}')

	# reset option
	PROCESS[log]=
}

