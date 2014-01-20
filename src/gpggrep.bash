find . -iname "*.gpg" | while read f
do
    out="$(gpgcat "$f" | grep "$@" -)"
    if [[ "$out" != "" ]]
    then
        echo "$out" | while read l
        do
            echo $f: $l
        done
    fi
done
