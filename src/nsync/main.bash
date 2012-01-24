local="$(hostname)"
user="$(whoami)"
binary="unison -ui text"

set -e

if [[ "$user" == "lulu" ]]
then
    cwd=`pwd`

    cd ~/school/11fall
    git pull
    git push

    cd ~/school/12IAP
    git pull
    git push

    cd ~/research/11fall/notes
    git pull
    git push

    cd ~/.local/share/latex/school
    git pull
    git push

    cd ~/.local/share/latex/school-personal
    git pull
    git push

    cd "$pwd"
fi

if [[ "$user" == "palmer" ]]
then
    cwd=`pwd`

    cd ~/files/finances/ 2> /dev/null || cd ~/finances/
    git pull
    git push

    cd ~/.passwords/
    git pull
    git push

    cd ~/work/resume/
    git pull
    git push

    cd ~/public_html
    git pull
    git push

    cd ~/.local/share/latex/school
    git pull
    git push

    cd ~/.local/share/latex/school-personal
    git pull
    git push

    cd ~/.pim
    git pull
    git push

    cd "$pwd"
fi

if [[ "$local" == "desktop.palmer.dabbelt.com" ]]
then
	echo "desktop.palmer.dabbelt.com <==> server.dabbelt.com"
	
	ionice -n 7 -c 2 $binary desktop-palmer-dabbelt-com
fi

if [[ "$local" == "desktop.lulu.dabbelt.com" ]]
then
	echo "desktop.lulu.dabbelt.com <==> server.dabbelt.com"
	
	ionice -n 7 -c 2 $binary desktop-lulu-dabbelt-com
fi

if [[ "$local" == "laptop.palmer.dabbelt.com" ]]
then
	echo "laptop.palmer.dabbelt.com <==> server.dabbelt.com"
	
	ionice -n 7 -c 2 $binary laptop-palmer-dabbelt-com
fi

if [[ "$local" == "tilera-laptop.palmer.dabbelt.com" ]]
then
	echo "tilera-laptop.palmer.dabbelt.com <==> server.dabbelt.com"
	
	ionice -n 7 -c 2 $binary tilera-laptop-palmer-dabbelt-com
fi

