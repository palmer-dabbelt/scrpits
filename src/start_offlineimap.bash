# Wait until there aren't any more instances running
while [[ "$(ps ux | grep offlineimap | grep -v grep | grep -v start_)" != "" ]]
do
    # Ask all currently running offlineimap instances to terminate
    pkill -USR2 offlineimap
    sleep 5s
done

# Actually ask offlineimap to start up, this time in the background
offlineimap >&/dev/null &
