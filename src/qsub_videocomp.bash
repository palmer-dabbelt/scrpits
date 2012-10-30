jobname=`basename "$1" | cut -c 1-12`

stat "$1" > /dev/null
if [[ "$?" != "0" ]]
then
	exit 1
fi

THREADS="2"
INFILE="$(readlink -f $1)"
OUTFILE="${INFILE}.mkv"

export TMPDIR="/home/scratch/$USER/tmp/qsub_videocomp"
mkdir -p $TMPDIR
tempdir=`mktemp -d`
mkdir -p $tempdir
date > $tempdir/qsub_videocomp_date

job_audio="$tempdir/$jobname"_a
cat >$job_audio <<EOF
#!/bin/bash
#PBS -q batch
#PBS -l nodes=1:ppn=2
#PBS -l nice=19
#PBS -o $tempdir/${jobname}_a.out
#PBS -e $tempdir/${jobname}_a.err

mkfifo $tempdir/audiopipe
mplayer "$INFILE" -vo null -ao pcm:file=$tempdir/audiopipe:fast -quiet &
oggenc $tempdir/audiopipe -o $tempdir/audio.ogg -q 1 --quiet
rm -f $tempdir/audiopipe
EOF

job_video="$tempdir/$jobname"_v
cat >$job_video <<EOF
#!/bin/bash
#PBS -q batch
#PBS -l nodes=1:ppn=$THREADS
#PBS -l nice=19
#PBS -o $tempdir/${jobname}_v.out
#PBS -e $tempdir/${jobname}_v.err

mencoder "$INFILE" -o $tempdir/video.avi -oac mp3lame -lameopts preset=64 -ovc x264 -x264encopts crf=20:bframes=8:b-adapt=2:b-pyramid=normal:ref=8:direct=auto:me=tesa:subme=10:trellis=2:threads=$THREADS -quiet
EOF

job_mux="$tempdir/$jobname"_m
cat >$job_mux <<EOF
#!/bin/bash
#PBS -q disk
#PBS -l nodes=1:ppn=1
#PBS -l nice=19
#PBS -o $tempdir/${jobname}_m.out
#PBS -e $tempdir/${jobname}_m.err

mkvmerge -D $tempdir/audio.ogg -A $tempdir/video.avi -o "$OUTFILE"
rm -rf $tempdir
EOF

jobid_audio=`qsub $job_audio`
jobid_video=`qsub $job_video`
jobid_mux=`qsub -W depend=afterany:$jobid_audio:$jobid_video $job_mux`

