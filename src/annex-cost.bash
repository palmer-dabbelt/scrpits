host="$1"

# If no host was given, then try very hard not to use it
if [[ "$host" == "" ]]
then
    echo 1000
    exit 0
fi

# Our current host has no cost at all, but it's probably also not that
# interesting.
if [[ "$host" == "$(hostname)" ]]
then
    echo 0
    exit 0
fi

# Hosts that don't resolve probably aren't good
if [[ "$(host $host | cut -d' ' -f 4)" == "0.0.0.0" ]]
then
    echo 100
    exit 0
fi

# If the host isn't even up then try not to use it
ping -W1 -c1 "$host" >& /dev/null
if [[ "$?" != "0" ]]
then
    echo 100
    exit 0
fi

# If the host is behind a firewall then don't bother with it
ssh "$host" hostname >& /dev/null
if [[ "$?" != "0" ]]
then
    echo 100
    exit 0
fi

# If the host is on our local subnet then it's very cheap
if [[ "$(traceroute -m3 $host |& wc -l)" == "2" ]]
then
    # Laptops are slightly more expensive
    if [[ "$(echo $host | grep -c laptop)" != "0" ]]
    then
	echo 20
    else
	echo 10
    fi

    exit 0
fi

# Otherwise the host is _somewhere_ on the internet.  
echo $((50 + $(traceroute $host | wc -l)))
exit 0
