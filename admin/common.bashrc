#!/bin/bash

g_appHome="$(readlink -f $(dirname ${BASH_SOURCE[0]})/..)"
g_appName="$(basename "$g_appHome")"
g_pidFile="${g_appHome}/data/${g_appName}.pid"

# return 0 process running, with pid output to stdout
# return 1 cannot detect process status
# return 2 process has stopped
# return 3 process has terminated unexpectedly
function get_process_pid() {

	if [[ -f "$g_pidFile" ]]
	then
		local pid="$(cat $g_pidFile)"
		if [[ $? != "0" ]]
		then
			echo "Read pid file [$g_pidFile] failed." 1>&2
			return 1
		fi
	else
		# pid file does not exist, it has been deleted
		# stopped
		return 2
	fi

	# should not be empty
	if [[ -z "$pid" ]]
	then
		return 3
	fi

	if [[ ! -d /proc/$pid ]]
	then
		return 3
	fi

	local linkExe="$(readlink /proc/$pid/exe)"
	local linkExe="${linkExe% (deleted)}"

	local expectedExe="$(readlink -f "${g_appHome}/bin/${g_appName}")"
	local expectedExe2="$(readlink -f "${g_appHome}/${g_appName}")"

	if [ "$linkExe" == "$expectedExe" -o "$linkExe" == "$expectedExe2" ]
	then
		echo "$pid"
		return 0
	else
		return 3
	fi
}

# return 1, unexpected error
function stop_process() {

	echo "stopping..." 1>&2

	local pid
	local stat
	pid=$(get_process_pid)
	stat=$?
	# echo "pid:[$pid] stat[$stat]" 1>&2

	# pid file should be writable
	if [ -f $g_pidFile -a ! -w $g_pidFile ]
	then
		echo "stop failed: pid file [$g_pidFile] is not writable" 1>&2
		return 1
	fi

	if [[ "$stat" == 1 ]]
	then
		echo "stop failed: cannot detect process status" 1>&2
		return 1
	elif [[ "$stat" == 2 ]]
	then
		echo "stop failed: process has stopped" 1>&2
		return 2
	elif [[ "$stat" == 3 ]]
	then
		echo "stop failed: process has terminated unexpectedly" 1>&2
		return 2
	fi

	kill -s SIGTERM "$pid"
	if [[ $? != 0 ]]
	then
		echo "stop failed: kill -s SIGTERM $pid" 1>&2
		return 1
	fi

	local cnt=0
	local cntMax=30
	while [[ $cnt -lt $cntMax ]]
	do
		usleep 100000
		if [[ ! -d /proc/$pid ]]
		then
			echo "stop ok!" 1>&2
			rm -f $g_pidFile
			return 0
		fi
		cnt=$((cnt+1))
	done
	# check stop result

	echo "stop [$pid] failed. you could kill it manually" 1>&2
	return 1

}

function get_exe() {
    expectedExe="$(readlink -f "${g_appHome}/bin/${g_appName}")"
    expectedExe2="$(readlink -f "${g_appHome}/${g_appName}")"
	if [ -f "$expectedExe" -a -f "$expectedExe2" ]
	then
		echo "[$expectedExe] and [$expectedExe2] both exist, this is a bad thing" 1>&2
		return 1
	elif [ -f "$expectedExe" ]
	then
		echo "$expectedExe"
		return 0
	elif [ -f "$expectedExe2" ]
	then
		echo "$expectedExe2"
		return 0
	else
		echo "[$expectedExe] not exist" 1>&2
		return 1
	fi
}

function start_process() {

	echo "starting..." 1>&2

	local exe
	exe="$(get_exe)"
	if [[ $? == 1 ]]
	then
		echo "start failed: cannot find application executable" 1>&2
		return 1
	fi

	local pid
	local stat
	pid=$(get_process_pid)
	stat="$?"

	# pid file should be writable
	touch $g_pidFile
	if [ ! -w $g_pidFile ]
	then
		echo "start failed: pid file [$g_pidFile] is not writable" 1>&2
		return 1
	fi

	if [[ "$stat" == 1 ]]
	then
		echo "start failed: cannot detect process status" 1>&2
		return 1
	elif [[ "$stat" == 0 ]]
	then
		echo "start failed: process is already running ..." 1>&2
		return 2
	fi

    nohup "$exe" serve -pid_file=${g_appHome}/data/${g_appName}.pid 1>>$g_appHome/log/default.log 2>>$g_appHome/log/default.log &
	local newPid=$!
    disown
	
	local cnt=0
	local cntMax=30
	while [ $cnt -lt $cntMax ]
	do
		if [ "$(get_process_pid)" == "$newPid" ]
		then
			# process survive for 500ms
			usleep 500000
			if [ "$(get_process_pid)" == "$newPid" ]
			then
				echo "start sucdess!" 1>&2
				return
			else
				echo "start failed!" 1>&2
				break
			fi
		fi
	done
	echo "start failed!" 1>&2

}

