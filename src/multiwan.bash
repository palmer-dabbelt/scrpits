# The list of interfaces to manage, given by their OpenWRT names
INTERFACES="wan sonic"

# Sets a bound on ping so it can't block forever.
PING_COUNT="10"
PING_TIMEOUT="30"

# The amount that should be added to the configured metric in order to
# disable a route.
DISABLE_METRIC_OFFSET="100"

logger -s "multiwan: Checking for WAN connectivity"

for interface in $(echo $INTERFACES)
do
    # Look up the kernel name for this interface, as that's what
    # everything else uses.
    kernel="$(ifstatus $interface | grep \"device\": | cut -d: -f2 | cut -d\" -f2)"
    logger -s "multiwan: $interface is $kernel"

    # Check to see if this interface is even enabled, if it's not then
    # there's no reason to bother doing anything with it at all --
    # nothing will be routed to it since it's not in the routing
    # tables!
    if [[ "$(ifstatus $interface | grep '\"up\": true')" == "" ]]
    then
        logger -s "multiwan: $interface ($kernel) has not connected, skipping"
        continue
    fi

    # Check every gateway this interface is configured to route
    # through to make sure they are up.
    gateways="$(route -n | grep "^0.0.0.0" | grep "$kernel$" | sed 's/  \+/ /g' | cut -d' ' -f2 | head -n1)"
    reachable="true"
    for gateway in $(echo $gateways)
    do
        loss="$(ping -c$PING_COUNT -w$PING_TIMEOUT -I $kernel $gateway | grep " 0% packet loss" | wc -l)"
        if test "$loss" != "1"
        then
            logger -s "multiwan: $interface ($kernel) is not functioning correctly"
            reachable="false"
        fi
    done

    # Determine the metric that was configured in the web interface,
    # which is the metric that will be used when this interface is
    # enabled.
    configured_metric="$(ifstatus $interface | grep \"metric\": | cut -d: -f2 | cut -d, -f1 | sed 's/^ //g')"

    # Figure out what metric should be set to, based on the current
    # state of the network.
    target_metric="$configured_metric"
    if test "$reachable" != "true"
    then
        target_metric="$((configured_metric + DISABLE_METRIC_OFFSET))"
    fi

    # Determine the actual current metric that the kernel is using to
    # route so we can check if it is correct or not.
    current_metric="$(route -n | grep "^0.0.0.0" | grep "$kernel$" | sed 's/  \+/ /g' | cut -d' ' -f5 | head -n1)"

    # If the kernel's current metric is different than what we want it
    # to be then change the kernel's routing tables
    if test "$target_metric" != "$current_metric"
    then
        logger -s "multiwan: Changing metric for $interface ($kernel) from $current_metric to $target_metric"
        route add default gw $gateways metric $target_metric dev $kernel
        route del default gw $gateways metric $current_metric dev $kernel
    fi
done
