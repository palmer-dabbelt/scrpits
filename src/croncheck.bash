HOSTS=""
HOSTS="$HOSTS palmer@berkeley.dabbelt.com"
HOSTS="$HOSTS palmer@weston.dabbelt.com"
HOSTS="$HOSTS lulu@berkeley.dabbelt.com"
HOSTS="$HOSTS lulu@weston.dabbelt.com"

for host in $(echo $HOSTS)
do
    ssh $host "if test -f dead.letter; then echo $(whoami)@$(hostname); head dead.letter; fi"
done
