local="$(hostname)"
user="$(whoami)"
binary="unison"

if [[ "$local" == "desktop.palmer.dabbelt.com" ]]
then
	echo "desktop.palmer.dabbelt.com <==> server.dabbelt.com"
	
	ssh server.dabbelt.com nsync
	ionice -n 7 -c 2 $binary desktop
	ssh server.dabbelt.com nsync

	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=nuvixa/Resource=desktop/ > $temp
	cp $temp ~/.kde4/share/config/kopeterc
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=laptop/Resource=desktop/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

if [[ "$local" == "laptop.palmer.dabbelt.com" ]]
then
	echo "laptop.palmer.dabbelt.com <==> server.dabbelt.com"

	ssh server.dabbelt.com nsync
	ionice -n 7 -c 2 $binary laptop
	ssh server.dabbelt.com nsync

	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=nuvixa/Resource=laptop/ > $temp
	cp $temp ~/.kde4/share/config/kopeterc
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=desktop/Resource=laptop/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

if [[ "$local" == "nuvixa.palmer.dabbelt.com" ]]
then
	echo "nuvixa.palmer.dabbelt.com <==> server.dabbelt.com"

	ssh server.dabbelt.com nsync
	ionice -n 7 -c 2 $binary laptop
	ssh server.dabbelt.com nsync

	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=desktop/Resource=nuvixa/ > $temp
	cp $temp ~/.kde4/share/config/kopeterc
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=laptop/Resource=nuvixa/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

if [[ "$local" == "lululi" ]]
then
	echo "lululi <==> server.dabbelt.com"
	
	ssh server.dabbelt.com nsync
	ionice -n 7 -c 2 $binary laptop
	ssh server.dabbelt.com nsync
fi

if [[ "$user" == "palmer" ]]
then
	rm dead.letter 2> /dev/null
	rm ~/.unison/*.log 2> /dev/null

	pwd=`pwd`
	cd ~/prog/
	make 2> /dev/null > /dev/null
	cd "$pwd"
fi

if [[ "$user" == "lulu" ]]
then
	rm ~/.unison/*.log 2> /dev/null
	
	pwd=`pwd`
	for x in $(/bin/ls ~/.programs/ | grep -v bin)
	do
		cd ~/.programs/$x
		make 2> /dev/null > /dev/null
	done
	cd $pwd
fi
