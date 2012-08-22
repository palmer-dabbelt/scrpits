last_message=$(folder --last-message inbox)

fetchmail || [ $? -eq 1 ]
if [[ "$?" == "0" ]]
then
    show inbox $(($last_message + 1)) >& /dev/null
    scan --start-from $(($last_message + 1))
fi
