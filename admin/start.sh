#!/bin/bash

appHome=$(readlink -f $(dirname ${BASH_SOURCE[0]})/..)
appName=$(basename "$appHome")

pidFile=$appHome/data/${appName}.pid

if [[ -f "$pidFile" ]]
then
    pid="$(cat $pidFile)"
    if [[ $? != "0" ]]
    then
        echo "pidfile exists but read pid file [$pidFile] failed." 1>&2
        exit 1
    fi
fi

function start_process() {

    expectedExe="$(readlink -f "${appHome}/bin/${appName}")"
    expectedExe2="$(readlink -f "${appHome}/${appName}")"
    if [ -f "$expectedExe" ]
    then
        exe="$expectedExe"
    elif [ -f "$expectedExe2" ]
    then
        exe="$expectedExe2"
    else
        echo "Error, [$expectedExe] not exist" 1>&2
        exit 3
    fi

	echo "starting ..."
    nohup $exe serve -pid_file=${appHome}/data/${appName}.pid 1>>$appHome/log/default.log 2>>$appHome/log/default.log &
    disown
}


if [[ -z "$pid" ]]
then
    start_process
else

    if [[ -d /proc/$pid ]]
    then
        linkExe="$(readlink /proc/$pid/exe)"
        linkExe="${linkExe% (deleted)}"
    fi
    expectedExe="$(readlink -f "${appHome}/bin/${appName}")"
    expectedExe2="$(readlink -f "${appHome}/${appName}")"

    if [[ -d /proc/$pid ]] && [ "$linkExe" == "$expectedExe" -o "$linkExe" == "$expectedExe2" ]
    then
        echo "Error: Process already running[$pid]" 1>&2
        exit 2
    else
        start_process
    fi

fi

