export WINEDBG=-all
export WINEPREFIX=$HOME/.wineprefix/steam/

cd "$WINEPREFIX/drive_c/Program Files/Steam"
wine "Steam.exe" -applaunch 10 >& /dev/null &

count="0"
while [[ "$count" == "0" ]]
do
    sleep 10s
    count=`ps x | grep -- "-game cstrike" | grep -v "grep" | wc -l`
done

echo "counterstrike is running"

while [[ "$count" != "0" ]]
do
    sleep 10s
    count=`ps x | grep -- "-game cstrike" | grep -v "grep" | wc -l`
done

echo "counterstrike is stopped"
wine "Steam.exe" -shutdown
