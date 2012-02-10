export WINEDBG=-all
export WINEPREFIX="$HOME/.local/share/wineprefix/wingsoliberty"

cd "$HOME/.local/share/wineprefix/wingsoliberty/drive_c/Program Files (x86)/StarCraft II"
wine "StarCraft II.exe" >& /dev/null
