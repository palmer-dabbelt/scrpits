process=""
fd=""
for x in $(lsof -Fpfn /tmp/)
do
    tst=`echo "$x" | cut -c1`
    if [[ "$tst" == "p" ]]
    then
	process=`echo "$x" | cut -c2-80`
	process=`echo "$process"`
    fi

    if [[ "$tst" == "f" ]]
    then
	fd=`echo "$x" | cut -c2-80`
	fd=`echo "$fd"`
    fi

    if [[ "$tst" == "n" ]]
    then
	name=`echo "$x" | cut -c 2-80 | cut -d ' ' -f 1`
	name=`echo "$name"`
	tst=`echo "$name" | cut -c 1-10`
	
	if [[ "$tst" == "/tmp/Flash" ]]
	then
	    echo /proc/"$process"/fd/"$fd"
	fi
    fi
done
