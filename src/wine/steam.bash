export WINEDBG=-all
export WINEPREFIX=$HOME/.wineprefix/steam/

cd "$WINEPREFIX/drive_c/Program Files/Steam"
wine "Steam.exe" &> /dev/null
