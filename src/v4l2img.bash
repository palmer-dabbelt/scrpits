if [[ "$1" == "" ]]
then
    echo "$0 <filename>"
    exit 1
fi

temp=`mktemp -d`
v4l2ppm "$temp"/v4l2.ppm
convert "$temp"/v4l2.ppm "$1"
rm -rf "$temp"

echo "$1"
