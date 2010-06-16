local="$(hostname)"
binary="unison"

if [[ "$local" == "desktop.palmer.dabbelt" ]]
then
	echo "desktop.palmer.dabbelt <==> dabbelt.zapto.org"
	ionice -n 7 -c 2 $binary desktop
	
	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=laptop/Resource=desktop/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

if [[ "$local" == "laptop.palmer.dabbelt" ]]
then
	echo "laptop.palmer.dabbelt <==> dabbelt.zapto.org"
	ionice -n 7 -c 2 $binary laptop
	
	temp=`mktemp`
	cat ~/.kde4/share/config/kopeterc | sed s/Resource=desktop/Resource=laptop/ > $temp
	mv $temp ~/.kde4/share/config/kopeterc
fi

if [[ "$local" == "vbox.nuvixa.palmer.dabbelt" ]]
then
	echo "vbox.nuvixa.palmer.dabbelt <==> dabbelt.zapto.org"
	ionice -n 7 -c 2 $binary vbox_nuvixa
fi

if [[ "$HOME" == "/home/engr/dabbelt1" ]]
then
	echo "EWS Machine <==> dabbelt.zapto.org"
	$binary ews
fi

