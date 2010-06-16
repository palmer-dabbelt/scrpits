codec=`midentify "$1" | grep ID_VIDEO_CODEC | tail -1 | cut -d '=' -f '2'`

if [[ "$codec" == "ffh264" ]]
then
	mplayer "$1" -vc ffh264vdpau
	exit $?
fi

mplayer "$1"
