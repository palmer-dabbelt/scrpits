if [[ "$1" == "cscz" ]]
then
	nvidia-settings -a "LogAnisoAppControlled=0"
	nvidia-settings -a "FSAAAppEnhanced=0"
	nvidia-settings -a "FSAAAppControlled=0"
	nvidia-settings -a "FSAA=7"
	nvidia-settings -a "LogAniso=2"
	
	cd "/home/palmer/.wineprefix/counter-strike-cz/drive_c/Valve/Condition Zero"
	WINEPREFIX="/home/palmer/.wineprefix/counter-strike-cz/" WINEDEBUG=-all wine czero.exe
	exit $?
fi

if [[ "$1" == "l4d" ]]
then
	nvidia-settings -a "LogAnisoAppControlled=0"
	nvidia-settings -a "FSAAAppEnhanced=0"
	nvidia-settings -a "FSAAAppControlled=0"
	nvidia-settings -a "FSAA=0"
	nvidia-settings -a "LogAniso=0"
	nvidia-settings -a "OpenGLImageSettings=3"
	
	cd "/home/palmer/.wineprefix/left4dead/drive_c/Program Files/Left4Dead"
	WINEPREFIX="/home/palmer/.wineprefix/left4dead/" WINEDEBUG=-all wine RUN_L4D.exe 
	exit $?
fi

if [[ "$1" == "bfv" ]]
then
	nvidia-settings -a "LogAnisoAppControlled=0"
	nvidia-settings -a "FSAAAppEnhanced=0"
	nvidia-settings -a "FSAAAppControlled=0"
	nvidia-settings -a "FSAA=0"
	nvidia-settings -a "LogAniso=0"
	nvidia-settings -a "OpenGLImageSettings=0"
	
	cd "/home/palmer/.wineprefix/battlefield-vietnam/drive_c/Program Files/EA GAMES/Battlefield Vietnam"
	WINEPREFIX="/home/palmer/.wineprefix/battlefield-vietnam" WINEDEBUG=-all wine bfvietnam.exe 
	exit $?
fi

if [[ "$1" == "ut2k4" ]]
then
	nvidia-settings -a "LogAnisoAppControlled=0"
	nvidia-settings -a "FSAAAppEnhanced=0"
	nvidia-settings -a "FSAAAppControlled=0"
	nvidia-settings -a "FSAA=0"
	nvidia-settings -a "LogAniso=0"
	nvidia-settings -a "OpenGLImageSettings=0"
	
	cd "/home/palmer/.wineprefix/ut2004/drive_c/UT2004/System/"
	WINEPREFIX="/home/palmer/.wineprefix/ut2004" WINEDEBUG=-all wine UT2004.exe
	exit $?
fi

if [[ "$1" == "aswarm" ]]
then
	nvidia-settings -a "LogAnisoAppControlled=0"
	nvidia-settings -a "FSAAAppEnhanced=0"
	nvidia-settings -a "FSAAAppControlled=0"
	nvidia-settings -a "FSAA=0"
	nvidia-settings -a "LogAniso=0"
	nvidia-settings -a "OpenGLImageSettings=0"
	
	cd "/home/palmer/.wineprefix/ut2004/drive_c/UT2004/AlienSwarm"
	WINEPREFIX="/home/palmer/.wineprefix/ut2004/" WINEDEBUG=-all wine AlienSwarm.exe
	exit $?
fi

if [[ "$1" == "steam" ]]
then
	nvidia-settings -a "LogAnisoAppControlled=0"
	nvidia-settings -a "FSAAAppEnhanced=0"
	nvidia-settings -a "FSAAAppControlled=0"
	nvidia-settings -a "FSAA=0"
	nvidia-settings -a "LogAniso=0"
	nvidia-settings -a "OpenGLImageSettings=0"
	
	cd "/home/palmer/.wineprefix/steam/drive_c/Program Files/Steam"
	WINEPREFIX="/home/palmer/.wineprefix/steam/" WINEDEBUG=-all wine Steam.exe
	exit $?
fi

echo "Count not find '$1'"
exit 1
