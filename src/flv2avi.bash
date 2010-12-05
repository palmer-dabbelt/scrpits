nice -n 19 mencoder "$1" -o "$1"-fixed.avi -ovc xvid -xvidencopts fixed_quant=3:turbo -oac mp3lame -lameopts preset=128
