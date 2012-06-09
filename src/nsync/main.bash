set -e

# We need to re-run exactly what we've been given many times
nsync_args="$@"
if test -x "$0"
then
    nsync=$(readlink -f $0)
else
    nsync=$(which $0)
fi

# Parses the commandline options
pull_only="false"
annex_get_all="false"
until [ -z "$1" ]
do
    case $1 in
	"--pull")
	    pull_only="true"
	    ;;
	"--annex-get-all")
	    annex_get_all="true"
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
    config=".nsyncrc"
else
    config="/dev/null"
fi

# First we need to pull in order to make sure we've got the latest modules
if [[ $(cat $config | grep "^NOPULL$" | wc -l) == "0" ]]
then
    git pull --quiet
fi

# Runs nsync in every submodule
cat $config | grep "^SUBMODULE " | while read line
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
    $nsync $nsync_args
    cd - >& /dev/null
done

# If there's a git-annex then we should merge it now
if test -d ".git/annex/"
then
    git annex merge --quiet

    if [[ "$annex_get_all" == "true" ]]
    then
	git annex get . --quiet
    fi
fi

# Pushes all the changes
if [[ $(cat $config | grep "^NOPUSH$" | wc -l) == "0" ]]
then
    git push --quiet
fi

# Runs make if there's a makefile here
if test -e Makefile
then
    make -j$(cat /proc/cpuinfo | grep -c '^processor')
fi
