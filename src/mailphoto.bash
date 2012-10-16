# Guesses the From and To address
if [[ "$(whoami)" == "palmer" ]]
then
    from="palmer"
    to="lulu"
elif [[ "$(whoami)" == "lulu" ]]
then
    from="lulu"
    to="palmer"
else
    echo "You're not either palmer or lulu, what do I do!?"
    exit 1
fi

# If an argument was given then that's the image we want to use, otherwise
# try and grab one from the webcam
if [[ "$1" != "" ]]
then
    imgname="$(basename $1)"
    imgpath="$1"
    webcam="false"
else
    imgname="$from.jpeg"
    imgpath="$temp/$from.jpeg"
    webcam="true"
fi

# There's a significant amount of temporary files that need to be created
temp=$(mktemp -d)

# If it's necessary to get a webcam photo then go ahead and get a good one
if [[ "$webcam" == "true"]]
then
    good="no"
    while [[ "$good" != "yes" ]]
    do
	v4l2img $temp/$from.jpeg
	ristretto $temp/$from.jpeg
	
	echo "Is this OK?"
	read good
    done
fi

# Write the header for this message
cat >$temp/message <<EOF
From:    $from
To:      $to
Subject: 

EOF

# Edit that header (ideally with a message)
$EDITOR $temp/message

# Add the MIME bits required to put the inside a mail message
# FIXME: Make this support non-JPEG images
sed s@"^Subject:.*$"@'\0\nMime-Version: 1.0\nContent-Type: multipart/mixed; boundary="MP_/5s0_jRRGmnHwNY+xHhksdig"\n\n--MP_/5s0_jRRGmnHwNY+xHhksdig\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: 7bit\nContent-Disposition: inline'@ -i $temp/message

cat >>$temp/message <<EOF

--MP_/5s0_jRRGmnHwNY+xHhksdig
Content-Type: image/jpeg
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=$imgname

EOF

cat $temp/$from.jpeg | base64 >> $temp/message

cat >>$temp/message <<EOF

--MP_/5s0_jRRGmnHwNY+xHhksdig--
EOF

# Write the message out to my draft folder
cat $temp/message | mhng-pipe-compose

# Clean up
rm -rf $temp
