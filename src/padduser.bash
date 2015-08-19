name=""
uid=""
cat /etc/pusers.conf | grep "^$1 " | while read pair
do
    if [[ "$name" != "" ]]
    then
        echo "$name appears twice in /etc/pusers.conf"
        exit 1
    fi

    name="$(echo "$pair" | cut -d' ' -f1)"
    uid="$(echo "$pair" | cut -d' ' -f1)"
done

useradd -u $uid -g $uid $name

