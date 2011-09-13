jobname=`basename "$1" | cut -c 1-12`

stat "$1" > /dev/null
if [[ "$?" != "0" ]]
then
	exit 1
fi

THREADS="4"

jobdir=`mktemp -d`
mkdir -p $jobdir

export TMPDIR="/home/scratch/$USER/qsub_video"
mkdir -p $TMPDIR
tempdir=`mktemp -d`
mkdir -p $tempdir

job_copy="$jobdir/$jobname"_c
echo "#!/bin/bash" > $job_copy
echo "#PBS -q disk" >> $job_copy
echo "#PBS -l nodes=1:ppn=1" >> $job_copy
echo "#PBS -l nice=19" >> $job_copy
echo "" >> $job_copy
echo "cp \"$1\" $tempdir/input" >> $job_copy

job_audio="$jobdir/$jobname"_a
echo "#!/bin/bash" > $job_audio
echo "#PBS -q batch" >> $job_audio
echo "#PBS -l nodes=1:ppn=2" >> $job_audio
echo "#PBS -l nice=19" >> $job_audio
echo "" >> $job_audio
echo "mkfifo $tempdir/audiopipe" >> $job_audio
echo "mplayer \"$1\" -vo null -ao pcm:file=$tempdir/audiopipe:fast -quiet &" \
    >> $job_audio
echo "oggenc $tempdir/audiopipe -o $tempdir/audio.ogg -q 1 --quiet" \
    >> $job_audio
echo "rm -f $tempdir/audiopipe" >> $job_audio

job_video="$jobdir/$jobname"_v
echo "#!/bin/bash" > $job_video
echo "#PBS -q batch" >> $job_video
echo "#PBS -l nodes=1:ppn=$THREADS" >> $job_video
echo "#PBS -l nice=19" >> $job_video
echo "" >> $job_video
echo "mencoder \"$1\" -o $tempdir/video.avi -nosound -ovc x264 -x264encopts crf=20:bframes=8:b-adapt=2:b-pyramid=normal:ref=8:direct=auto:me=tesa:subme=10:trellis=2:threads=$THREADS -quiet" >> $job_video

job_mux="$jobdir/$jobname"_m
echo "#!/bin/bash" > $job_mux
echo "#PBS -q disk" >> $job_mux
echo "#PBS -l nodes=1:ppn=1" >> $job_mux
echo "#PBS -l nice=19" >> $job_mux
echo "" >> $job_mux
echo "mkvmerge $tempdir/audio.og $tempdir/video.avi \"$2\"" >> $job_mux
echo "rm -rf $tempdir" >> $job_mux

jobid_copy=`qsub -h $job_copy`
jobid_audio=`qsub -W depend=afterany:$jobid_copy $job_audio`
jobid_video=`qsub -W depend=afterany:$jobid_copy $job_video`
jobid_mux=`qsub -W depend=afterany:$jobid_audio:$jobid_video $job_mux`
qalter $jobid_copy -h n
