# If given with any arguments then get mail from that maildrop
if [[ "$1" != "" ]]
then
    # Actually run fetchmail, potientially in parallel
    fetchmail --pidfile "fetchmail-$1-pid" "$1"

    # Invert the exit code here, because of how GNU parallel works
    if [[ "$?" == "0" ]]
    then
	exit 1
    else
	exit 0
    fi
fi

# There was no argument given so instead check every maildrop for messages

# Store the current last message, if any mail comes in then the new message
# will be "$(($orig + 1))".
orig=$(mhng-pipe-folder_info --last-message +inbox)

# Actually check for new mail, in parallel.  The "-u" flag will allow
# fetchmail to print progress information more quickly (as opposed to
# all at the end).  Note that "getmail $MAILDROP" has inverted exit
# status: if there's no mail then it will exit with failure.  
cat ~/.fetchmailrc | grep -i ^poll | cut -d ' ' -f 2 | parallel -u "$0"
# By default GNU parallel will exit with the number of failed jobs, so
# in this case we'll end up with the number of maildrops that had
# mail.

# If any maildrop had mail then advance to the first fetched message
if [[ "$?" != "0" ]]
then
    fin=$(mhng-pipe-folder_info --last-message +inbox)
    show +inbox $(($orig + 1)) >& /dev/null
    scan +inbox $(seq $(($orig + 1)) $fin)
fi
