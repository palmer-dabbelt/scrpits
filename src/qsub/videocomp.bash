jobname=`basename "$1" | cut -c 1-12`

stat "$1" > /dev/null
if [[ "$?" != "0" ]]
then
	exit 1
fi

THREADS="2"
INFILE="$(readlink "$1")"
OUTFILE="${INFILE}.mkv"

jobdir=`mktemp -d`
mkdir -p $jobdir

export TMPDIR="/home/scratch/$USER/tmp"
mkdir -p $TMPDIR
tempdir=`mktemp -d`
mkdir -p $tempdir

job_audio="$jobdir/$jobname"_a
cat >$job_audio <<EOF
#!/bin/bash
#PBS -q batch
#PBS -l nodes=1:ppn=2
#PBS -l nice=19

mkfifo $tempdir/audiopipe
mplayer "$INFILE" -vo null -ao pcm:file=$tempdir/audiopipe:fast -quiet &
oggenc $tempdir/audiopipe -o $tempdir/audio.ogg -q 1 --quiet
rm -f $tempdir/audiopipe
EOF

job_video="$jobdir/$jobname"_v
cat >$job_video <<EOF
#!/bin/bash
#PBS -q batch
#PBS -l nodes=1:ppn=$THREADS
#PBS -l nice=19

mencoder "$INFILE" -o $tempdir/video.avi -oac mp3lame -lameopts preset=64 -ovc x264 -x264encopts crf=20:bframes=8:b-adapt=2:b-pyramid=normal:ref=8:direct=auto:me=tesa:subme=10:trellis=2:threads=$THREADS -quiet
EOF

job_mux="$jobdir/$jobname"_m
echo >$job_mux <<EOF
#!/bin/bash
#PBS -q disk
#PBS -l nodes=1:ppn=1
#PBS -l nice=19

mkvmerge -D $tempdir/audio.ogg -A $tempdir/video.avi "$OUTFILE"
rm -rf $tempdir
EOF

jobid_audio=`qsub -h $job_audio`
jobid_video=`qsub -h $job_video`
jobid_mux=`qsub -W depend=afterany:$jobid_audio:$jobid_video $job_mux`
qalter $jobid_audio -h n
qalter $jobid_video -h n

rm -rf $jobdir
