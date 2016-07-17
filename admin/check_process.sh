#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/common.bashrc

pid="$(get_process_pid)"
stat=$?

# return 0 process running, with pid output to stdout
# return 1 cannot detect process status
# return 2 process has stopped
# return 3 process has terminated unexpectedly

if [ "$stat" != 1 -a "$stat" != 3 ]
then
	echo "Process [$pid] OK!"
	exit 0
fi

echo "Process not OK!"

# TODO: 进程状态异常，这里增加告警部分的代码



