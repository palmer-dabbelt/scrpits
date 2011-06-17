run="$1"
if [[ "$1" == "" ]]
then
	run="xterm"
fi

echo "#!/bin/bash" > ~/.xstartups/__exec
echo $run >> ~/.xstartups/__exec
chmod +x ~/.xstartups/__exec

if [[ "$(ps aux | grep X | grep :1)" == "" ]]
then
	startx -- :1 $2
else
	startx -- :2 $2
fi
