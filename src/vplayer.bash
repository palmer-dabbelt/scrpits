mplayer="mplayer -volume 50 -cache 100000 -cache-min 1 -cache-seek-min 1"
addons=""

codec=`midentify "$1" | grep ID_VIDEO_CODEC | tail -1 | cut -d '=' -f '2'`
if [[ "$codec" == "ffh264" ]]
then
	vstring=`glxinfo | grep "GL_NV_vdpau_interop"`

	if [[ "$vstring" != "" ]]
	then
		addons="-vc ffh264vdpau"
	fi
fi

$mplayer "$1" $addons &
wait
exit $?
