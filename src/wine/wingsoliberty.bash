export WINEDBG=-all
export WINEPREFIX=$HOME/.wineprefix/wingsoliberty/

cd $WINEPREFIX/drive_c/Program\ Files/StarCraft\ II/
wine "StarCraft II.exe" >& /dev/null
