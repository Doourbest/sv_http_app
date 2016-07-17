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
    echo "NOTICE: App Process not exist" 1>&2
    ${appHome}/admin/start.sh
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
        echo "gracefully restarting...[kill -s SIGHUP $pid]" 1>&2
        kill -s SIGHUP $pid
        # check start result
        if [[ $? != 0 ]]
        then
            exit 2
        fi
        cnt=0
        while true
        do
            usleep 100000
            if [[ -n "$(cat $pidFile)" ]] && [[ "$(cat $pidFile)" != "$pid" ]]
            then
                echo "restart success pid[$(cat $pidFile)]"
                exit 0
            fi
            cnt=$((cnt+1))
            if [[ $cnt -ge 10 ]]
            then
                echo "restart failed."
                exit 2
            fi
        done

    else
        echo "!!!Warning: process [$pid] not exist, starting it now..." 1>&2
        ${appHome}/admin/start.sh
    fi

fi

