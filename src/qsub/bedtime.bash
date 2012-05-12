systems=""
systems="$systems berkeley.dabbelt.com"
systems="$systems desktop.palmer.dabbelt.com"
systems="$systems desktop.lulu.dabbelt.com"

unset ignore_nice_load
nice_load_file="/sys/devices/system/cpu/cpufreq/ondemand/ignore_nice_load"
while [ -n "$1" ]
do
    case "$1" in
	"--on")
	    ignore_nice_load="1"
	    ;;
	"--off")
	    ignore_nice_load="0"
	    ;;
    esac

    shift
done

for system in $systems
do
    echo $system

    ssh root@$system "echo $ignore_nice_load > $nice_load_file"
done
