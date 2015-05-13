#!/bin/bash

xrandr --output eDP1 --mode 640x480
xrandr --output eDP1 --set "scaling mode" full_aspect

xrandr --output DP1 --mode 640x480
xrandr --output DP1 --set "scaling mode" full_aspect

xrandr --output DP2 --mode 640x480
xrandr --output DP2 --set "scaling mode" full_aspect

setxkbmap us

xset m 1/4 1

export WINEPREFIX=$HOME/.local/share/wineprefix/broodwar/
cd $WINEPREFIX/drive_c
cd Program\ Files/StarCraft
wine StarCraft.exe
