run="$1"
if [[ "$1" == "" ]]
then
	run="xterm"
fi

echo "#!/bin/bash" > ~/.xstartups/__exec
echo $run >> ~/.xstartups/__exec
chmod +x ~/.xstartups/__exec

startx -- :1 $2

