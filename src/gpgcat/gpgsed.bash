#!/bin/bash

PASSDIR="$HOME/.local/share/passwords/"

if [[ "$1" == "$2" ]]
then
    echo "Chose two different filenames" 1>&2
    exit 1
fi

cp "$1" "$2"

find "$PASSDIR" -iname "*.gpg" | sed "s@^$PASSDIR@@" | while read f
do
    if [[ "$(grep "$f" "$1" | wc -l)" != "0" ]]
    then
	sed "s|@@$f@@|$(gpgcat $PASSDIR/$f)|" -i "$2"
    fi
done
