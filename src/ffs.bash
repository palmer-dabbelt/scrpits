Xephyr -screen 1671x1022 -keybd ephyr,,,,xkblayout=dvorak :1 &
sleep 5s
DISPLAY=:1 twm
DISPLAY=:1 firefox