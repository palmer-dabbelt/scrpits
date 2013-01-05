set -e

cd $HOME/work/paperwork/time_sheet
./generate.bash
tek
make -j

temp=$(mktemp -d)

current_time=$(date +%s)
current_dow=$(date -d @$current_time +%u)
end_time=$(($current_time + (5 - $current_dow) * 24 * 60 * 60))
end_date_pretty=$(date -d @$end_time +%D)
end_date_path=$(date -d @$end_time +%Y-%m-%d)

cat >$temp/message <<EOF
From:   Palmer Dabbelt <pdabbelt@tilera.com>
To:     Richard Schooler <rschooler@tilera.com>
CC:     Cristy Agbayani <cagbayani@tilera.com>
Subject: Timesheet for $end_date_pretty

EOF


for dif in $(seq 6 -1 0)
do
    time=$(($end_time - 24 * 60 * 60 * $dif))
    date=$(date -d @$time +%Y-%m-%d)
    file="$HOME/work/logs/$date"

    if test ! -e $file
    then
	continue
    fi

    cat $file >> $temp/message
    echo "" >> $temp/message
done

$EDITOR $temp/message

sed s@"^Subject:.*$"@'\0\nMime-Version: 1.0\nContent-Type: multipart/mixed; boundary="MP_/5s0_jRRGmnHwNY+xHhksdig"\n\n--MP_/5s0_jRRGmnHwNY+xHhksdig\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: 7bit\nContent-Disposition: inline'@ -i $temp/message

cat >>$temp/message <<EOF

--MP_/5s0_jRRGmnHwNY+xHhksdig
Content-Type: application/pdf
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=pdabbelt-$end_date_path.pdf

EOF

cat ~/work/paperwork/time_sheet/$end_date_path.pdf | base64 >> $temp/message

cat >>$temp/message <<EOF

--MP_/5s0_jRRGmnHwNY+xHhksdig--
EOF

cat $temp/message | mhng-pipe-compose

rm -rf $temp
