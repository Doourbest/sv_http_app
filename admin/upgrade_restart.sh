#!/bin/bash

# perform restart during package upgrade

source $(dirname ${BASH_SOURCE[0]})/common.bashrc

get_process_pid 1>/dev/null
ret=$?
if [ "$ret" != "0" ]
then
	echo "Process not running, no need to perform graceful restart"
	exit 0
fi

echo "Process is running, perform graceful restart for upgrade"
graceful_restart_process

