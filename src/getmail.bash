orig=$(folder --last-message +inbox)

fetchmail
if [[ "$?" == "0" ]]
then
    fin=$(folder --last-message +inbox)
    show +inbox $(($orig + 1)) >& /dev/null
    scan +inbox $(seq $(($orig + 1)) $fin)
fi
