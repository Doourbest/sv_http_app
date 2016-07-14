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

if [[ -z "$pid" ]]
then
    echo "App Process not started yet," 1>&2
    exit 0
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
        echo "process running" 1>&2
        exit 0
    else
        echo "Process not exist!!!" 1>&2
        # TODO
        # 这里需要增加告警代码
        ${appHome}/admin/start.sh
    fi

fi

