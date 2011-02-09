jobname=`basename "$1"`
jobname=$jobname".job"

stat "$1" > /dev/null
if [[ "$?" != "0" ]]
then
	exit 1
fi

mem=`du "$1" | cut -f 1`

input_video_codec=`midentify "$1" | grep ID_VIDEO_CODEC | tail -1 | cut -d '=' -f 2`
if [[ "$input_video_codec" == "ffh264" ]]
then
	mem=`dc -e "$mem 2 * p"`
fi

echo "#!/bin/bash" > $jobname
echo "videocomp \"$1\" \"$2\" >/dev/null 2>/dev/null" >> $jobname
out1=`dirname "$1"`
out2=`basename "$1"`
echo "mv \"$1\" \"$out1/.converted/$out2\"" >> $jobname

id=`qsub -q batch -l mem="$mem"kb $jobname`
qrun $id 2>/dev/null
rm $jobname
echo $id
