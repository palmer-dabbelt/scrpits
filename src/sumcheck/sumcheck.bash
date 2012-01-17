of=".sha256sums"

# Makes sure the file exists
touch "$of"

# Adds everything that hasn't yet been added to the directory listing
find . -maxdepth 1 -type f ! -iname "$of" -print0 | while read -d $'\0' file
do
    out=$(cat "$of" | cut -c 67- | grep "^$file$")
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
    sha256sum -c "$of"
    if [[ "$?" == 0 ]]
    then
	out=1
    fi
fi

# Collects the errors
exit $out
