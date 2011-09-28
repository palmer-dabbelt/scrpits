Xephyr -screen 1671x1022 -keybd ephyr,,,,xkblayout=dvorak :1 &
sleep 1s
DISPLAY=:1 metacity &
DISPLAY=:1 firefox &