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
    echo "App Process not exist" 1>&2
    return 2
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

        echo "gracefully stopping...[kill -s SIGTERM $pid]" 1>&2

        kill -s SIGTERM $pid
        # check stop result
        if [[ $? != 0 ]]
        then
            exit 2
        fi
        cnt=0
        while true
        do
            usleep 100000
            if [[ ! -d /proc/$pid ]]
            then
                echo "stopping success." 1>&2
                # truncate pid file
                : > $pidFile
                exit 0
            fi

            cnt=$((cnt+1))
            if [[ $cnt -ge 30 ]]
            then
                echo "stop [$pid] failed." 1>&2
                exit 2
            fi
        done

    else
        echo "!!!Warning: process [$pid] not exist" 1>&2
    fi

fi

