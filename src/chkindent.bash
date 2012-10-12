dir="$1"
fix="$2"

if [[ "$dir" == "--fix" ]]
then
    dir=""
    fix="--fix"
fi

if [[ "$dir" == "" ]]
then
    dir="."
fi

if test -f "$dir"
then
    if [[ "$fix" == "--fix" ]]
    then
	indent "$dir"	
    else
	cat "$dir" | indent | diff - $dir
    fi
    
    exit $?
fi

options=""
if test -f ".chkindentrc"
then
    options=`head -n1 .chkindentrc`
fi

return="0"
for f in `find "$dir" $options -name "*.[ch]" -print`
do
    if [[ `stat "$f" --format %F` == "regular file" ]]
    then
	cat "$f" | indent | diff - $f > /dev/null
	if [[ "$?" != "0" ]]
	then
	    return="1"
	    echo $f
	    if [[ "$fix" == "--fix" ]]
	    then
		indent "$f"
	    fi
	fi
    fi
done

exit $return
