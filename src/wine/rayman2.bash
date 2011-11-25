export WINEDBG=-all
export WINEPREFIX=$HOME/.wineprefix/rayman2/

mount /mnt/isos/rayman2

cd $WINEPREFIX/drive_c/UbiSoft/Rayman2
wine Rayman2.exe

umount /mnt/isos/rayman2
