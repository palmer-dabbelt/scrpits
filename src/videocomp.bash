#!/bin/sh

tmpdir=`mktemp --directory`
input="$1"
output="$2"

# Names
audiopipe="$tmpdir/audiopipe"
oggfile="$tmpdir/audio.ogg"
x264file="$tmpdir/video.avi"

# Encodes audio
mkfifo $audiopipe
nice -n 19 mplayer "$input" -vo null -ao pcm:file=$audiopipe $3 &
nice -n 19 oggenc $audiopipe -o $oggfile -q 0 --quiet $4
rm -f $audiopipe

# Encodes video
nice -n 19 mencoder "$input" -o $x264file -nosound -ovc x264 -x264encopts crf=20:bframes=8:b-adapt=2:b-pyramid=normal:ref=8:direct=auto:me=tesa:subme=10:trellis=2:threads=1 
$5

# Merges the video
nice -n 19 mkvmerge $oggfile $x264file -o "$output"
rm -rf $tmpdir
