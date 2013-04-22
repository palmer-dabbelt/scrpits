# Wait until there aren't any more instances running
for x in $(seq -w 1 10)
do
    if [[ "$(ps ux | grep offlineimap | grep -v grep | grep -v start_)" != "" ]]
    then
        # Ask all currently running offlineimap instances to terminate
	pkill -USR2 offlineimap
	sleep $x
    fi
done

# If it really didn't die, then just go ahead and kill it -- this
# hangs a lot on my laptop.
if [[ "$(ps ux | grep offlineimap | grep -v grep | grep -v start_)" != "" ]]
then
    # Ask all currently running offlineimap instances to terminate
    pkill -9 offlineimap
    sleep 1s
fi

# Actually ask offlineimap to start up, this time in the background
offlineimap >&/dev/null &
