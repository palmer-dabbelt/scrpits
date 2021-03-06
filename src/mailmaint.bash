syncmail "(auto) mailmaint: start"

# Removes old messages (older than 90 days)
current_date=`date +%s`
for folder in $(echo trash sent)
do
    mhng-pipe-time_scan +$folder | while read line
    do
	message_id=`echo $line | cut -d ' ' -f 1`
	message_date=`echo $line | cut -d ' ' -f 2`

	date_difference=$(($current_date - $message_date))
	if [[ "$date_difference" -gt "7776000" ]]
	then
	    rmm +$folder $message_id
	else
	    break
	fi
    done
done

syncmail "(auto) mailmaint: clean"

# Compacts the folders
for folder in $(mhng-pipe-folder_info --folders)
do
    cd $(mhpath +$folder)

    dest="1"
    mhng-pipe-time_scan +$folder | while read line
    do
	cur=`echo $line | cut -d ' ' -f 1`

	if [[ "$dest" != "$cur" ]]
	then
	    mv "$cur" "$dest"
	fi

	dest=$(($dest + 1))
    done
done

syncmail "(auto) mailmaint: compact"

# Goes back to the inbox
folder +inbox

syncmail "(auto) mailmaint: end"
