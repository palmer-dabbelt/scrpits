of=".sha256sums"
temp=`mktemp`
dir=$(basename "$(pwd)")

# Makes sure the file exists
touch "$of"

# Adds everything that hasn't yet been added to the directory listing
find . -maxdepth 1 -type f ! -iname "$of" -print0 | while read -d $'\0' file
do
    escfile=$(echo "$file" | sed s@'\['@'\\\['@ | sed s@'\]'@'\\\]'@)
    out=$(cat "$of" | cut -c 67- | grep "^$escfile$")
    if [[ "$out" != "$file" ]]
    then
	shortfile=$(echo "$file" | cut -c 3-)
	echo "Updating sum for \"$shortfile\""
	sha256sum "$file" >> "$of"
    fi
done

# Actually preforms the verification
files=$(cat .sha256sums | wc -l)
out=0
if [[ "$files" != 0 ]]
then
    sha256sum -c "$of" 2>&1 | tee $temp
    if [[ "$?" == 0 ]]
    then
	out=1
    fi
fi

# Sends a mail if the checksumming failed
if [[ "$out" != "0" ]]
then
    if [[ "$1" == "--mail" ]]
    then
	mail -s "sumcheck failed in $dir" "$1" < $temp
    fi
fi

rm $temp

# Collects the errors
exit $out
