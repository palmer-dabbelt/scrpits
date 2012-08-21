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

temp=$(mktemp -d)

cat >$temp/message <<EOF
From:   $from
To:     $to
Subject: 

EOF

$EDITOR $temp/message

sed s@"^Subject:.*$"@'\0\nMime-Version: 1.0\nContent-Type: multipart/mixed; boundary="MP_/5s0_jRRGmnHwNY+xHhksdig"\n\n--MP_/5s0_jRRGmnHwNY+xHhksdig\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: 7bit\nContent-Disposition: inline'@ -i $temp/message

cat >>$temp/message <<EOF

--MP_/5s0_jRRGmnHwNY+xHhksdig
Content-Type: image/jpeg
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=$from.jpeg

EOF

good="no"
while [[ "$good" != "yes" ]]
do
    v4l2img $temp/$from.jpeg
    ristretto $temp/$from.jpeg

    echo "Is this OK?"
    read good
done

cat $temp/$from.jpeg | base64 >> $temp/message

cat >>$temp/message <<EOF

--MP_/5s0_jRRGmnHwNY+xHhksdig--
EOF

cat $temp/message | mhng-pipe-compose

rm -rf $temp
