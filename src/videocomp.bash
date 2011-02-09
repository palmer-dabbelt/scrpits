input="$1"
output="$2"

stat "$input"
if [[ "$?" != "0" ]]
then
	exit $?
fi

tmpdir=`mktemp --directory`

# Names
audiopipe="$tmpdir/audiopipe"
oggfile="$tmpdir/audio.ogg"
x264file="$tmpdir/video.avi"

# Discovers information
input_video_codec=`midentify "$input" | grep ID_VIDEO_CODEC | tail -1 | cut -d '=' -f 2`

# Encodes audio
mkfifo $audiopipe
nice -n 19 mplayer "$input" -cache 100000 -vo null -ao pcm:file=$audiopipe:fast &
nice -n 19 oggenc $audiopipe -o $oggfile -q 0 --quiet
rm -f $audiopipe

# Encodes video
nice -n 19 mencoder "$input" -o $x264file -nosound -ovc x264 -x264encopts crf=20:bframes=8:b-adapt=2:b-pyramid=normal:ref=8:direct=auto:me=tesa:subme=10:trellis=2:threads=1 

# Merges the video
nice -n 19 mkvmerge $oggfile $x264file -o "$output"
rm -rf $tmpdir
