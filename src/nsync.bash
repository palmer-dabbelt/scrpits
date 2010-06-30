local="$(hostname)"
binary="unison"

if [[ "$local" == "desktop.palmer.dabbelt.com" ]]
then
	echo "desktop.palmer.dabbelt.com <==> server.dabbelt.com"
	
	ssh server.dabbelt.com nsync
	
	ionice -n 7 -c 2 $binary desktop
	
	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=laptop/Resource=desktop/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

if [[ "$local" == "laptop.palmer.dabbelt.com" ]]
then
	echo "laptop.palmer.dabbelt.com <==> server.dabbelt.com"

	ssh server.dabbelt.com nsync

	ionice -n 7 -c 2 $binary laptop
	
	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=desktop/Resource=laptop/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

rm dead.letter 2> /dev/null
rm ~/.unison/*.log 2> /dev/null

pwd=`pwd`
cd ~/prog/
make
cd "$pwd"
