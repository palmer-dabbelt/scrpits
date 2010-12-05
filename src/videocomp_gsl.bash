nice -n 19 mencoder "$1" -o "$2" -mc 1 -ovc  -oac mp3lame -lameopts preset=256
