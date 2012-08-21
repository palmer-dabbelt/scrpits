last_message=$(scan inbox | tail -1 | xargs echo | cut -d ' ' -f 1)

fetchmail || [ $? -eq 1 ]
if [[ "$?" == "0" ]]
then
    show $(($last_message + 1)) >& /dev/null
    scan
fi

