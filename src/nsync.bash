local="$(hostname)"
user="$(whoami)"
binary="unison -ui text"

if [[ "$local" == "desktop.palmer.dabbelt.com" ]]
then
	echo "desktop.palmer.dabbelt.com <==> server.dabbelt.com"
	
	ionice -n 7 -c 2 $binary desktop-palmer-dabbelt-com
fi

if [[ "$local" == "desktop.lulu.dabbelt.com" ]]
then
	echo "desktop.lulu.dabbelt.com <==> server.dabbelt.com"
	
	ionice -n 7 -c 2 $binary desktop-lulu-dabbelt-com
fi

