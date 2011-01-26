if [[ "$1" == "--all" ]]
then
	for x in $(/bin/ls *.tgz)
	do
		tarm $x || exit $?
	done
	
	exit 0
fi

tar -xvzpf "$1" && sync && rm "$1" && exit 0 
