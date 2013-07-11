set -e

# Parses the commandline options
nsync="$0"
pull_only="false"
read_only="false"
annex_get_all="false"
verbose="false"
submodule=""
subargs=""
parallel="8"
until [ -z "$1" ]
do
    case $1 in
	"--pull")
	    pull_only="true"
	    subargs="$subargs --pull"
	    ;;
	"--annex-get-all")
	    annex_get_all="true"
	    subargs="$subargs --annex-get-all"
	    ;;
	"--verbose")
	    verbose="true"
	    subargs="$subargs --verbose"
	    ;;
	"--submodule")
	    submodule="$2"
	    shift
	    ;;
        "--read-only")
            read_only="true"
	    subargs="$subargs --read-only"
            ;;
	"--parallel")
	    parallel="$2"
	    shift
	    ;;
	*)
	    echo "Unknown option $1"
	    exit 1
	    ;;
    esac
	
    shift
done

# If there isn't a config file then just use the default for everything
if test -e .nsyncrc
then
    config="$(readlink -f .nsyncrc)"
else
    config="/dev/null"
fi

if [[ "$submodule" == "" ]]
then
    cat $config | grep "^SUBMODULE " | cut -d' ' -f2 | \
	parallel -j $parallel "$nsync" $subargs --submodule 

    # Runs make if there's a makefile here
    if test -e Makefile
    then
	make
    fi

    exit 0
fi

# In this case we must have been given a submodule argument, find the
# matching submodule and process it now
cat $config | grep "^SUBMODULE $submodule " | while read line
do
    # Parses the submodule format
    submodule=`echo "$line" | cut -d ' ' -f 1`
    path=`echo "$line" | cut -d ' ' -f 2`
    remote=`echo "$line" | cut -d ' ' -f 3`

    # If the submodule doesn't exist then clone it from the source
    if test ! -e $path
    then
	echo "Cloning $path from $remote"
	git clone $remote $path
    fi

    # Re-runs the given command in this submodule
    echo "SUBMODULE $path"
    cd $path

    if [[ $(cat $config | grep "^NOPULL $path$" | wc -l) == "0" ]]
    then
	if [[ "$verbose" == "true" ]]; then echo -e "\tPULL"; fi
	git pull --quiet
    else
	if [[ "$verbose" == "true" ]]; then echo -e "\tNO PULL"; fi
    fi

    # If there's an updated git-config then use it
    if test -e .git-config
    then
	if [[ "$verbose" == "true" ]]; then echo -e "\tCONFIG"; fi
	cp .git-config .git/config

	hostname=$(hostname)
	if [[ "$(cat $config | grep "^UUID $path" | wc -l)" != "0" ]]
	then
	    hostname="$(cat $config | grep "^UUID $path" -m1 | cut -d' ' -f 3)"
	    if [[ "$verbose" == "true" ]]; then echo -e "\t\tHN $hostname"; fi
	fi

	sed s/@@hostname@@/$hostname/ -i .git/config
    fi

    # Merges (and potentially gets) the git-annex stuff
    if [[ $(cat $config | grep "^ANNEX $path$" | wc -l) != "0" ]]
    then
	if [[ "$verbose" == "true" ]]; then echo -e "\tANNEX"; fi
	git annex merge --quiet
	
	if [[ "$annex_get_all" == "true" ]]
	then
	    if [[ "$verbose" == "true" ]]; then echo -e "\tANNEX GET"; fi
	    git annex get . --quiet
	fi
    fi

    # Checks if there are any changes
    if [[ "$read_only" == "false" ]]
    then
	if [[ "$(git ls-files --others --exclude-standard)" != "" ]]
	then
	    echo -e "\tUntracked files"
	fi
	if [[ "$(git diff-files)" != "" ]]
	then
	    echo -e "\tUnstaged changes"
	fi
	if [[ "$(git diff-index --cached HEAD)" != "" ]]
	then
	    echo -e "\tUncomitted changes"
	fi
    fi

    # Pushes all the changes
    if [[ $(cat $config | grep "^NOPUSH$" | wc -l) == "0" ]]
    then
        if [[ "$read_only" == "false" ]]
        then
	    if [[ "$verbose" == "true" ]]; then echo -e "\tPUSH"; fi
	    git push --quiet
        fi
    else
	if [[ "$verbose" == "true" ]]; then echo -e "\tNO PUSH"; fi
    fi

    # Returns to the path we care about
    cd - >& /dev/null
done
