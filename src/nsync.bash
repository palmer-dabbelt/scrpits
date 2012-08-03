set -e

# Parses the commandline options
pull_only="false"
annex_get_all="false"
verbose="false"
until [ -z "$1" ]
do
    case $1 in
	"--pull")
	    pull_only="true"
	    ;;
	"--annex-get-all")
	    annex_get_all="true"
	    ;;
	"--verbose")
	    verbose="true"
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
	sed s/@@hostname@@/$(hostname)/ -i .git/config
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

    # Pushes all the changes
    if [[ $(cat $config | grep "^NOPUSH$" | wc -l) == "0" ]]
    then
	if [[ "$verbose" == "true" ]]; then echo -e "\tPUSH"; fi
	git push --quiet
    else
	if [[ "$verbose" == "true" ]]; then echo -e "\tNO PUSH"; fi
    fi

    # Returns to the path we care about
    cd - >& /dev/null
done

# Runs make if there's a makefile here
if test -e Makefile
then
    make
fi
