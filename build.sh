#1/bin/bash

cd $(dirname ${BASH_SOURCE[0]})

appSrcDir=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
appName=$(basename "$appSrcDir")

# build server
echo "go build -o bin/$appName"
go build -o bin/$appName
if [[ $? != 0 ]]
then
    exit 1
fi

# build commands
if [ -d ./cmd ]
then
	cmds="$(find './cmd' -maxdepth 1 -type f -name '*.go') $(find './cmd' -mindepth 1 -maxdepth 1 -type d )"
	for cmd in $cmds
	do
		echo $cmd
		if [ -f $cmd ]
		then
			echo go build -o bin/$(basename ${cmd%.go} ) $cmd 
			go build -o bin/$(basename ${cmd%.go} ) $cmd 
			if [[ $? != 0 ]]
			then
				exit 1
			fi
		fi
		if [ -d $cmd ]
		then
			echo "(cd $cmd && go build -o ../../bin/$(basename $cmd))"
			(cd $cmd && go build -o ../../bin/$(basename $cmd))
			if [[ $? != 0 ]]
			then
				exit 1
			fi
		fi
	done
fi


rpmbuild -bb --define="app_source_dir $(pwd)" --define="app_name $appName" ./package/rpm.spec

