origdir=`pwd`
retval=0

find . -type d -print0 | while read -d $'\0' dir
do
    echo "Runing sumcheck in \"$dir\""
    cd "$dir"
    sumcheck
    if [[ "$?" != 0 ]]
    then
	retval=1
    fi
    cd "$origdir"
done

exit $retval
