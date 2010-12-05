jobname=`basename "$1"`
jobname=$jobname".job"

echo "#!/bin/bash" > $jobname
echo "videocomp \"$1\" \"$2\" >/dev/null 2>/dev/null" >> $jobname
out1=`dirname "$1"`
out2=`basename "$1"`
echo "mv \"$1\" \"$out1/.converted/$out2\"" >> $jobname

id=`qsub -q batch $jobname`
qrun $id 2>/dev/null
rm $jobname
echo $id
