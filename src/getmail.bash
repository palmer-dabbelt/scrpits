orig=$(mhng-pipe-folder_info --last-message +inbox)

cat .fetchmailrc \
    | grep -i ^poll \
    | cut -d ' ' -f 2 \
    | sed 's/.*/fetchmail-\0-pid \0/' \
    | parallel -C ' ' fetchmail --pidfile

if [[ "$?" == "0" ]]
then
    fin=$(mhng-pipe-folder_info --last-message +inbox)
    show +inbox $(($orig + 1)) >& /dev/null
    scan +inbox $(seq $(($orig + 1)) $fin)
fi
