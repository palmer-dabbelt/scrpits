#!/bin/bash

set -e

ORIGDIR=`pwd`
NSYNC="$0"
CONFIG="${HOME}/.nsyncrc"

if [ "$1" = "" ]
then
    cd "$HOME"

    # Recurses in every submodule, potentially doing some extra work
    git submodule foreach --quiet env SUBMODULE=\$path "$NSYNC" --submodule

    # Adds every submodule, as we just want to keep them always updated
    git submodule foreach --quiet "cd $ORIGDIR ; git add \$path"

    # Done with submodules
    echo "HOME $HOME"
    echo "git pull"
    git pull --quiet

    # Some things can just be automatically added
    grep "^add " "$CONFIG" | sed s/'^add '/''/ | while read file
    do
	if test -e "$file"
	then
	    git add "$file"
	fi
    done

    # If there are uncomitted files then add them 
    if [ "$(git status --porcelain | wc -l)" != '0' ]
    then
        # Asks for a commit message but also supplies one
	echo "git commit"
	git commit -m "nsync auto add" -e
    fi

    # Pushes all our changes
    echo "git push"
    git push --quiet

    cd "$ORIGDIR"
elif [ "$1" = "--submodule" ]
then
    echo "SUBMODULE $SUBMODULE"

    if [ "$(grep -c "^nopull $SUBMODULE$" "$CONFIG")" = "0" ]
    then
	echo "git pull"
	git pull --quiet
    fi

    if [ "$(grep -c "^addall $SUBMODULE$" "$CONFIG")" = "1" ]
    then
	echo "git add ."
	git add .
    fi

    if [ "$(grep -c "^commit $SUBMODULE$" "$CONFIG")" = "1" ]
    then
	if [ "$(git status --porcelain | wc -l)" != '0' ]
	then
            echo "git commit"
            git commit -m "nsync auto add" -e
	fi
    fi

    if [ "$(grep -c "^nopush $SUBMODULE$" "$CONFIG")" = "0" ]
    then
	echo "git push"
        git push --quiet
    fi

    echo ""
fi
