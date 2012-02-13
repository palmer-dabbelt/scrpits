export WINEDBG=-all
export WINEPREFIX="$HOME/.local/share/wineprefix/wingsoliberty"

cd "$HOME/.local/share/wineprefix/wingsoliberty/drive_c/Program Files (x86)/StarCraft II"
schedtool -a 1 -e wine "StarCraft II.exe" >& /dev/null
