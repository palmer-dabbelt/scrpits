# Read every mail folder
for folder in $(mhng-pipe-folder_info --folders)
do
    bash -x -c "scan +$folder" > /dev/null
done

echo "+ xfrun4"
xfrun4 >& /dev/null &
sleep 5s
xfrun4 -q

echo "+ firefox"
firefox >& /dev/null &
sleep 10s
wmctrl -c Firefox

echo "+ emacs"
emacs -batch

echo "+ terminal"
terminal -x echo "exit" \| bash
